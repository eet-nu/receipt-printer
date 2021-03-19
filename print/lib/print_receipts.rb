require 'tempfile'
require 'yaml'
require 'uri'
require 'net/http'
require 'json'

class PrintReceipts

  def self.fetch_and_print
    new.fetch_and_print
  end

  def fetch_and_print
    receipt_paths.each do |path|
      system("lp", path)
    end
  end

  private

  def receipt_paths
    response = get_url(configuration['url'])
    paths = []
    JSON.parse(response.body)['results'].each do |url|
      paths << save_url_as_file(url)
    end
    paths
  end

  def save_url_as_file(url)
    response = get_url(url)
    tempfile = Tempfile.new(["temp","pdf"], binmode: true)
    tempfile.write(response.body)
    tempfile.close
    
    tempfile.path
  end

  def get_url(url)
    uri = URI(url)
    request = Net::HTTP::Get.new uri.request_uri
    
    request.basic_auth access_key, secret if auth?(uri)
    
    if env == 'development'
      OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
      OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE) 
    end
    
    response = Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https', 
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      
      http.request request
    end

    case response
    when Net::HTTPSuccess then
      response
    when Net::HTTPRedirection then
      puts "redirect to: " + response['location']
      return get_url(response['location'])
    else
      raise "problem fetching #{url} - #{response.message}"
    end
  end

  def access_key
    @access_key ||= File.read("#{rails_root}/config/access_key").strip
  end

  def secret
    @secret ||= File.read("#{rails_root}/config/secret").strip
  end
  
  def auth?(uri)
    uri.host == URI(configuration['url']).host
  end
  
  def configuration
    YAML.load_file("#{rails_root}/config/application.yml")[env]
  end
  
  def env
    env = ENV['RAILS_ENV'] || 'development'
  end
  
  def rails_root
    File.expand_path("..", __dir__)
  end
end
