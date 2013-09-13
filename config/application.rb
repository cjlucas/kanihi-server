require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'rabl'
require 'time'

require 'digest/sha1'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

JOBS_DIR = File.expand_path('../../app/jobs', __FILE__)
$LOAD_PATH.unshift(JOBS_DIR)

Dir[File.join(JOBS_DIR, '*rb')].each { |fpath| require File.basename(fpath) }

require 'uri/file'
require 'cjutils/path'

require 'fileutils'
PID_DIR = File.expand_path('../../tmp/pids', __FILE__)
FileUtils.mkdir_p(PID_DIR) unless File.exists?(PID_DIR)

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module MusicServer
  class Application < Rails::Application
    VERSION = '0.0.1'

    config.middleware.use "CompressResponse"
    config.middleware.use "ResizeImage"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # show sql statements in console
    config.logger = Logger.new(STDOUT) if $0.eql?('irb')

    config.after_initialize do
      AppConfig.configure(:model => Setting)
      if Setting.table_exists?
        AppConfig.load

        default_settings = {
          :debug        => false,
          :host         => '0.0.0.0',
          :port         => 8080,
          :auth_user    => nil,
          :auth_pass    => nil,
        }

        should_save = false
        default_settings.each do |setting, value|
          unless AppConfig.exist?(setting)
            AppConfig[setting] = value
            should_save = true
          end
        end

        AppConfig.save if should_save
      end
    end
  end
end
