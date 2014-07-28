# -*- ruby -*-
require "bundler/setup"
require "sequel"

# Monkeypatch Object so we have blank?
class Object
  def blank?
    self.nil? || to_s.empty?
  end
end

namespace :db do

  desc "Create the necessary database structures."
  task :setup do
    require "logger"

    unless ENV["DB_URI"]
      $stderr.puts "No DB_URI set. Please set it to something like sqlite://your_db.db"
      exit 1
    end

    print "Connecting to database with DB_URI '#{ENV['DB_URI']}'... "
    db = Sequel.connect(ENV["DB_URI"], :logger => Logger.new($stdout))
    puts "done."

    puts "Creating users table..."
    db.create_table :users do
      primary_key :id
      String :nickname
      String :email
      String :encrypted_password
      TrueClass :activated, :default => false
      Time :registered_at
    end

    puts "Creating registration tokens table..."
    db.create_table :registration_tokens do
      primary_key :id
      String :token
      Integer :user_id
      Time :expires_at
    end

    puts "Creating levels table..."
    db.create_table :levels do
      primary_key :id
      String :name
      String :description, :text => true
      String :version
      String :smc_version_requirement
      Integer :user_id
      Time :uploaded_at
    end
  end

end

desc "Drops you into a console with everything loaded."
task :console do
  require_relative "app"
  ARGV.clear
  require "irb"
  IRB.start
end
