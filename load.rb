# encoding: utf-8

$LOAD_PATH.unshift 'lib'
require 'trello'
require 'rubygems'
require 'simple_xlsx'
#require_relative 'filewriter'
require 'yaml'

include Trello
include Trello::Authorization

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

CONFIG = YAML::load(File.open("config.yml")) unless defined? CONFIG

credential = OAuthCredential.new CONFIG['public_key'], CONFIG['private_key']
OAuthPolicy.consumer_credential = credential

OAuthPolicy.token = OAuthCredential.new CONFIG['access_token_key'], nil

puts "Finding board..."
board = Board.find("51963af6417516c57e0059ab")

if board.has_lists?
	todo_list = board.lists.first
end 
puts "Creating card in #{todo_list.id}"
card = Card.create(:name=>"Prueba",:list_id=>todo_list.id)

