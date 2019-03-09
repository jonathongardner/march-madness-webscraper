require 'httparty'
require 'nokogiri'
require 'byebug'
require 'active_record'
require 'activerecord-import'
require_relative 'app/models/march_madness_previous_bracket.rb'

module Main
  def self.root
    @root ||= File.join(__dir__)
  end
end

Dir[File.join(Main.root, 'app', '*', '*.rb')].each { |file| require file }

#--------Connect to DB-------
puts "Setting up db connection..."
def db_configuration
  db_configuration_file = File.join(Main.root, 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end
ActiveRecord::Base.establish_connection(db_configuration['development'])

# B2018.delete_all
puts "Initializing bracket..."
bracket_2018 = Brackets2018.new
puts "Running bracket..."
bracket_2018.run
