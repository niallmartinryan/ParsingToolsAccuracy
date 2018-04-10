#!/usr/bin/ruby
require 'mongo'
require 'rubygems'
require 'json'
require 'anystyle/parser'
Mongo::Logger.logger.level = ::Logger::FATAL

puts "Hello World!"

# connecting to the db
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'real')
client.collections.each { |coll| puts coll.name}
# client.close
docs = client[:articles1].find
puts "There are #{docs.count} documents"

#docs.each{
#  |doc| puts doc
#  break
#}

#client[:articles1].find(:skip => 1).each do |doc|
#  puts doc
#end

cursor = client[:articles1].find({}, { :projection => {:_id => 0, :citation => 1} })

cursor.each {|doc|  
  parsed = JSON.parse(doc.to_json())
  parsed["citation"].each do |citation|
    #puts citation["annotatedBib"]
    open('training.txt', 'a'){ |f|
      f.puts citation["annotatedBib"] + "\n"
    }
  end
  
}


#Anystyle.parse 


#client[:articles1].find.each {
#  |doc| puts doc
#  puts "There are #{docs.count} documents"
#  break
#}


client.close

