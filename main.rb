require 'nokogiri'
require 'net/http'
require 'byebug'
require 'active_record'
require 'activerecord-import'
require_relative 'app/models/march_madness_previous_bracket.rb'

STDOUT.sync = true

module Main
  def self.root
    @root ||= File.join(__dir__)
  end

  def self.kill_file
    @kill_file ||= File.join(Main.root, 'tmp', 'stop')
  end
end

Dir[File.join(Main.root, 'app', '*', '*.rb')].each { |file| require file }

start_bracket = 1
final_bracket = nil
ARGV.each_slice(2) do |arg|
  case arg[0]
  when '-s'
    start_bracket = arg[1].to_i
  when '-f'
    final_bracket = arg[1].to_i
  else
    puts "Arguemnts not used: #{arg}"
  end
end
if File.file?(Main.kill_file)
  start_bracket = File.read(Main.kill_file).to_i
  File.delete(Main.kill_file)
end

#--------Connect to DB-------
puts "Setting up db connection..."
def db_configuration
  db_configuration_file = File.join(Main.root, 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end
ActiveRecord::Base.establish_connection(db_configuration['development'])


#B2018.delete_all
puts "Initializing bracket..."
bracket_2018 = Brackets2018.new(start_bracket: start_bracket, final_bracket: final_bracket)
puts "Running bracket..."
bracket_2018.run
