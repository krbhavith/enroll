Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = false
  config.cache_store = :memory_store

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static file server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :cache

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
  config.action_mailer.cache_settings = { :location => "#{Rails.root}/tmp/cache/action_mailer_cache_delivery#{ENV['TEST_ENV_NUMBER']}.cache" }

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.acapi.app_id = "enroll"
  HbxIdGenerator.slug!

  config.action_mailer.default_url_options = {
    :host => "127.0.0.1",
    :port => 3000
  }

  #Environment URL stub
  config.checkbook_services_base_url = "https://checkbook_url"
  config.checkbook_services_ivl_path = "/ivl/"
  config.checkbook_services_shop_path = "/shop/"
  config.checkbook_services_congress_url = "https://checkbook_url/congress/"
  config.checkbook_services_remote_access_key = "9876543210"
  config.checkbook_services_reference_id = "0123456789"
  config.wells_fargo_api_url = "https://xyz:442/"
  config.wells_fargo_api_key = "abdnh3-43nd-4ngemm-3432tf-45325365g"
  config.wells_fargo_biller_key = "2345q"
  config.wells_fargo_api_secret = "abscd 200"
  config.wells_fargo_api_version = " 201s"
  config.wells_fargo_private_key_location = "#{Rails.root.join("spec", "test_data")}" + "/test_wfpk.pem"
  config.wells_fargo_api_date_format = "%Y-%m-%dT%H:%M:%S.0000000%z"


  #Queue adapter
  config.active_job.queue_adapter = :test

  Mongoid.logger.level = Logger::ERROR
  Mongo::Logger.logger.level = Logger::ERROR
end
