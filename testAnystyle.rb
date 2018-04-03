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

#cursor = client[:articles1].find({}, { :projection => {:_id => 0, :citation => 1} })
cursor = client[:articles1].find({}, {})

# Should probably create a csv with the accuracy values so they are easy to
# evaluate
# and possibly just keep track of the evaluation on the fly
# in order to make comparisons and double checks
#
# NEED TO CREATE SOME GLOBAL COUNTERS!!


j =0
cursor.each {|doc|  
  if j < 10 
    j = j+1
    next
  end
  parsed = JSON.parse(doc.to_json())
  # this may print out a LOT OF KEYS
  keys =  parsed.keys
  # search through the keys for words that match..e.g. author.. editor..
  #
  # getting the fields that anystyle generates
  anyStyleFields = Anystyle.parser.model.labels
  
  #puts parsed
  parseTitle = parsed["title"]
  parseAuthors = parsed["author"]
  #puts parseTitle
  #puts parseAuthors
  #break
  parsed["citation"].each do |citation|
    puts citation["bib"]
    myString = Anystyle.parse(citation["bib"], :hash)#.to_s
    puts "\n"
    puts myString[0]
    testHash = myString[0]
    

    #puts newThing[:author] 
    #puts "\n"
    #parsedBibtex = JSON.parse(myString) 
    #puts parsedBibtex["author"] 
    
    newAuthor = testHash[:author]
    newSplitAuthor =  newAuthor.split(/,|&|and/)
    newSplitAuthor.each do |auth|
      puts auth
      puts "\n"
    end 
    newBookTitle =  testHash[:booktitle]
    newContainer = testHash[:container]
    newDate = testHash[:date]
    newDoi = testHash[:doi]
    newEdition = testHash[:edition]
    newEditor = testHash[:editor]
    newInstitution = testHash[:institution]
    newIsbn = testHash[:isbn]
    newJournal = testHash[:journal]
    newLocation = testHash[:location]
    newNote = testHash[:note]
    newPages = testHash[:pages]
    newPublisher = testHash[:publisher]
    newRetrieved = testHash[:retrieved]
    newTech = testHash[:tech]
    newTitle = testHash[:title]
    newTranslator = testHash[:translator]
    newUnknown = testHash[:unknown]
    newUrl = testHash[:url]
    newVolume = testHash[:volume]
    
    # need some counters here

  abort("mwhah")
  # looks for any key containing author or editor..
    keys.each do |key|
      puts key
      if key == "citation" 
        
      else 
        puts parsed[key]
      end
      
      if (key.include? "author")  || (key.include? "editor")  
        accuracy = false
        i= 0
        newSplitAuthor.each do |auth|
          fullAuthString = parsed[key]
          #puts fullAuthString[i]
          if auth.include? "#{fullAuthString[i][:family]} #{fullAuthString[i][:given]}"
            puts " OMG IT WAS INCLUDED... WHUUUUTTT"
          end
        end
        
        #puts "FOUND EM"
        #puts parsed[key]
      end 
    end
    #abort("HAH")
    #newSplitAuthor.each do |auth|
    #  if(){
      
     # }
    #end
    #if(){
    
    #}    
    
    break
    #open('textFile.txt', 'a'){ |f|
    #  f.puts citation["annotatedBib"] + "\n"
    #}
  end
  break 
}


#Anystyle.parse 


#client[:articles1].find.each {
#  |doc| puts doc
#  puts "There are #{docs.count} documents"
#  break
#}


client.close

