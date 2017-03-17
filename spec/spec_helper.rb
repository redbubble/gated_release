require "bundler/setup"
require "active_record"
require "database_cleaner"

# Load the dummy app
require File.expand_path("../dummy/config/environment.rb", __FILE__)

# Create an in-memory database and run our template migration
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.verbose = false

require_relative './../lib/generators/templates/create_gated_release_gates'
CreateGatedReleaseGates.new.change


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
