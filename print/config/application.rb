require_relative "boot"

require 'rails/all'
require 'net/http'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ReceiptPrinter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.application = config_for(:application)

    config.autoload_paths += %W[
      lib
      app/jobs
    ].map {|path| "#{config.root}/#{path}"}

    I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
    I18n.available_locales = [:nl]
    I18n.default_locale = :nl
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
