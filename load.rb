# encoding: utf-8

$LOAD_PATH.unshift 'lib'
require 'trello'
require 'rubygems'
require "csv"
require 'yaml'

include Trello
include Trello::Authorization

CSV_FILE_PATH = File.join(File.dirname(__FILE__), "2013.SpainJS.C4P.2013.05.17.csv")
Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

CONFIG = YAML::load(File.open("config.yml")) unless defined? CONFIG

credential = OAuthCredential.new CONFIG['public_key'], CONFIG['private_key']
OAuthPolicy.consumer_credential = credential

OAuthPolicy.token = OAuthCredential.new CONFIG['access_token_key'], nil

puts "Finding board..."
board = Board.find("51983302706741e77e0080b8")

if board.has_lists?
	todo_list = board.lists.first
	puts "Retrieving #{todo_list.name}"
	 
end 


lines = 0

puts "Reading file #{CSV_FILE_PATH}"
#Timestamp,Name,Description,Title,Email,Your Bio,Your Twitter Account,Type,Level
CSV.foreach(CSV_FILE_PATH) do |line|
  if lines > 1
    name = line[1] 
    description = line[2]
    title = line[3]
    email = line[4]
    bio = line[5]
    twitter = line[6]
    type = line[7]
    level = line[8]

    puts "Creating card #{name} - #{email}"
  
    card = Card.create(:name=>"#{type} - #{level} - #{title}",:description=>"# #{name} - #{email} - @#{twitter} 
  	#{description}",:list_id=>todo_list.id)
  end
  lines = lines+1
end

puts "Finished process. #{lines} cards inserted"

