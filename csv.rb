# encoding: utf-8

# Deletes all cards of a list.count
$LOAD_PATH.unshift 'lib'
require 'trello'
require 'rubygems'
#require 'simple_xlsx'
#require_relative 'filewriter'
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
board = Board.find("51963af6417516c57e0059ab")

if board.has_lists?
  todo_list = board.lists.first
  puts todo_list.cards.count
  todo_list.cards.each  do |card|
    card.delete
  end
end 
