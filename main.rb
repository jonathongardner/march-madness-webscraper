require 'httparty'
require 'nokogiri'
require 'byebug'
require 'active_record'
require_relative 'app/models/march_madness_previous_bracket.rb'

module Main
  def self.root
    @root ||= File.join(__dir__)
  end
end

Dir[File.join(Main.root, 'app', '*', '*.rb')].each { |file| require file }

#--------Connect to DB-------
def db_configuration
  db_configuration_file = File.join(Main.root, 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end
ActiveRecord::Base.establish_connection(db_configuration['development'])

B2018.delete_all
# B2018.create(unique_game_number: 1)
# puts B2018.pluck(:unique_game_number)
# ws = WebScrapper.new
# puts ws.unique_game_number(1)
