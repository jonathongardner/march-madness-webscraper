require 'httparty'
require 'nokogiri'
require 'byebug'
require_relative 'lib/id_not_found'
require_relative 'lib/web_scrapper'

ws = WebScrapper.new
puts ws.unique_game_number(1)
