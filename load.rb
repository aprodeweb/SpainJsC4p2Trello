# encoding: utf-8

$LOAD_PATH.unshift 'lib'
require 'trello'
require 'rubygems'
require "csv"
require 'yaml'

include Trello
include Trello::Authorization

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

CONFIG = YAML::load(File.open("config.yml")) unless defined? CONFIG

credential = OAuthCredential.new CONFIG['public_key'], CONFIG['private_key']
OAuthPolicy.consumer_credential = credential

OAuthPolicy.token = OAuthCredential.new CONFIG['access_token_key'], nil

puts "Finding board..."
boards = {}
boards[:talks]      = Board.find("5199e8c3c0df829a78011b49")
boards[:workshops]  = Board.find("5199ee54e06fe5897800a5a7")

lists = {}

boards.each do |k,board|
  if board.has_lists?
    lists[k] = board.lists.first
    puts "Retrieving #{lists[k].name}"
  end
end

lines = 0

def line_to_row(line)
  hash = {}
  [:time, :name, :description, :title, :email, :bio, :twitter, :type, :level].each_with_index do |k,i|
    hash[k] = line[i]
  end
  hash
end

def description_from_row(row)
  text = <<-EOF
Details
-------

- **Name:** #{row[:name]}
- **Email:** #{row[:email]}
- **Twitter:** #{row[:twitter]}
- **Level:** #{row[:level]}

Description
-----------

#{row[:description]}

Bio
---

#{row[:bio]}
EOF
  text
end

puts "Reading from STDIN"
#Timestamp,Name,Description,Title,Email,Your Bio,Your Twitter Account,Type,Level
CSV($stdin) do |csv|
  csv.each do |line|
    if lines > 1
      row = line_to_row(line)

      list = lists[row[:type] == "Talk" ? :talks : :workshops]

      print "Creating card #{row[:name]} - #{row[:email]}: "
      card = Card.create(
        :name        => "#{row[:title]}, by #{row[:name]} (#{row[:level]})",
        :description => description_from_row(row),
        :list_id     => list.id
      )
      puts card.id.to_s
    end
    lines += 1
  end
end

puts "Finished process. #{lines-1} cards inserted"

