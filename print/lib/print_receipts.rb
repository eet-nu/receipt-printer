require 'tempfile'
require 'yaml'
require 'uri'
require 'net/http'
require 'json'

class PrintReceipts
  def self.run
    while true do
      start_time = Time.now.to_f

      poll_and_print

      remaining_time = (start_time + time_between_polls) - Time.now.to_f
      sleep remaining_time if remaining_time > 0
    end
  end

  def self.poll_and_print
    new.poll_and_print
  end

  def poll_and_print
    uri = URI(configuration['url'])

    if env == 'development'
      OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
      OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
    end

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      request.basic_auth access_key, secret if authenticate?(uri)

      http.request request do |response|
        content_type = response.header['Content-Type'] ||
                       response.header['content-type']
        case content_type
        when 'text/event-stream'
          response.read_body do |chunk|
            chunk.split("\n").each do |line|
              next unless line =~ /^data: /
              parse_json_and_fetch line[6..-1]
            end
          end
        else
          parse_json_and_fetch response.body
        end
      end
    end
  end

  def parse_json_and_fetch(json)
    json = JSON.parse(json)
    json['results'].each do |url|
      fetch_and_print(url)
    end
  end

  def fetch_and_print(url)
    uri = URI(url)

    request = Net::HTTP::Get.new uri.request_uri
    request.basic_auth access_key, secret if authenticate?(uri)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request) do |response|
        case response
        when Net::HTTPSuccess
          # write directly to the printer bypassing memory and disk
          IO.popen('lp', 'r+') do |process|
            response.read_body do |chunk|
              process.write(chunk)
            end
            process.close_write
          end
        when Net::HTTPRedirection
          fetch_and_print(response['location'])
        else
          raise "problem fetching #{url} - #{response.to_hash}"
        end
      end
    end
  end

  def self.time_between_polls
    @@time_between_polls ||= (new.configuration['time_between_polls'] || 5).to_i
  end

  def access_key
    @access_key ||= File.read("#{rails_root}/config/access_key").strip
  end

  def secret
    @secret ||= File.read("#{rails_root}/config/secret").strip
  end

  def authenticate?(uri)
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
