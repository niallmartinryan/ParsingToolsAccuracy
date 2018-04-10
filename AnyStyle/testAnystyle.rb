#!/usr/bin/ruby
require 'mongo'
require 'rubygems'
require 'json'
require 'anystyle/parser'
Mongo::Logger.logger.level = ::Logger::FATAL

print "Hello World!"

# connecting to the db
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'real')
client.collections.each { |coll| print coll.name}
# client.close
docs = client[:articles1].find
print "There are #{docs.count} documents"

#docs.each{
#  |doc| print doc
#  break
#}

#client[:articles1].find(:skip => 1).each do |doc|
#  print doc
#end

#cursor = client[:articles1].find({}, { :projection => {:_id => 0, :citation => 1} })
cursor = client[:articles1].find({}, {})

# Should probably create a csv with the accuracy values so they are easy to
# evaluate
# and possibly just keep track of the evaluation on the fly
# in order to make comparisons and double checks
#
# NEED TO CREATE SOME GLOBAL COUNTERS!!



# Need to add the headers to the .csv file
# creating the string first
headersStringCSV = "_id,style,bib,resBib,author,bookTitle,container,date,doi,edition,editor,journal,location,pages,publisher,translator,url,volume,total\n"

open('results.csv','a'){ |f|
  f.print headersStringCSV
}



j =0
cursor.each {|doc|  
  if j < 0 
    j = j+1
    next
  end
  open('results.csv', 'a'){ |f|



    parsed = JSON.parse(doc.to_json())
    # this may print out a LOT OF KEYS

    object = parsed["_id"]
    f.print object["$oid"] + ","

    #abort("omg")
    keys =  parsed.keys
    # search through the keys for words that match..e.g. author.. editor..
    #
    # getting the fields that anystyle generates
    anyStyleFields = Anystyle.parser.model.labels

    #print parsed
    parseTitle = parsed["title"]
    parseAuthors = parsed["author"]
    #print parseTitle
    #print parseAuthors
    #break
    parsed["citation"].each do |citation|
      #f.print object["$oid"] + "," 
      f.print citation["style"] + ","
      f.print citation["bib"]+ ","
      myString = Anystyle.parse(citation["bib"], :hash)#.to_s
      print "\n"
      print myString[0]
      testHash = myString[0]
      f.print "#{testHash}," 

      #print newThing[:author] 
      #print "\n"
      #parsedBibtex = JSON.parse(myString) 
      #print parsedBibtex["author"] 

      newAuthor = testHash[:author]
      puts "\n New AUTHOR??? : #{newAuthor}"
      notSame = false
      if !newAuthor.nil?
        if !newAuthor.kind_of?(Array)
          newSplitAuthor =  newAuthor.split(/,|&/)
          #newSplitAuthor.each do |auth|
          # print auth
          # print "\n"
          #end
          #puts "Size of newSPlitAuthor : #{newSplitAuthor.length}"
          #puts "parsed[author] : #{parsed["author"]}" 
          #puts "Size of parsed[author] : #{parsed["author"].length}"
        else

          newSplitAuthor =  newAuthor[1].split(/,|&/)
          notSame = true
          # Might need this later if results are scewed
          #if( newSplitAuthor.size != parsed["author"].size )
          #  print "They were not the same size" 
          #  notSame = true
          #end
        end
      end 
      newBookTitle =  testHash[:booktitle]
      newContainer = testHash[:container]
      newDate = testHash[:date]
      newDoi = testHash[:doi]
      newEdition = testHash[:edition]
      newEditor = testHash[:editor]
      print "newEditor :: #{newEditor}"
      if !newEditor.nil?
        newSplitEditor = newEditor.split(/,|&/)
        newSplitEditor.each do |edit|
          print edit + "\n"
        end
      end
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
      if !newTranslator.nil?
        newSplitTranslator = newTranslator.split(/,|&/)
        newSplitTranslator.each do |trans|
          print trans + "\n"
        end
      end

      newUnknown = testHash[:unknown]
      newUrl = testHash[:url]
      newVolume = testHash[:volume]
      #if newTech == null
      # print "it was null"
      if newTech.nil?
        print "it was nil"
      end 
      #abort("heh")
      accuracyForEditor = "0" 
      accuracyForTrans = "0" 
      # need some counters here

      #abort("mwhah")
      # looks for any key containing author or editor..
      keys.each do |key|
        #print key
        if key == "citation" 

        else 
          #print parsed[key]
        end
        if (key == "translator")
          accuracy = true
          i=0
          newSplitTranslator.each do |trans|
            fullTransString = parsed[key]
            if trans.include? "#{fullTransString[i][:family]} #{fullTransString[i][:given]}"

            else
              accuracy = false
            end
            i = i+1
          end
          if accuracy == true
            accuracyForTrans = "1"
          else 
            accuracyForTrans = "0"
          end
        end
        if (key == "editor") && (!parsed[key].nil?) && (!newEditor.nil?)
          accuracy = true
          i=0
          print newSplitEditor
          newSplitEditor.each do |auth|
            fullAuthString = parsed[key]
            if auth.include? "#{fullAuthString[i][:family]} #{fullAuthString[i][:given]}"

            else
              accuracy = false
            end
            i = i+1
          end
          if accuracy == true
            accuracyForEditor = "1"
          else
            accuracyForEditor = "0"
          end 
        end
        if (key.include? "author") && (!parsed[key].nil?) && (notSame == false)    
          accuracy = true
          i= 0
          #puts "#{newAuthor} : new Author "
          #puts "#{newSplitAuthor} : newSplitAuthor"
          #puts "#{parsed[key]}: parsed[key]"
          # parsed[key][0].length
          if (!newSplitAuthor.nil?) &&(newSplitAuthor.length == parsed[key].length)
            print "THEY WERE EQUALLL"

            newSplitAuthor.each do |auth|
              fullAuthString = parsed[key]
              #puts fullAuthString
              puts "#{fullAuthString[i]} + #{i}"
              #print fullAuthString[i]
              puts "#{auth} + #{i}"
              if (auth.include? "#{fullAuthString[i][:family]} #{fullAuthString[i][:given]}")
                #  print "Found correct Author"
              else
                accuracy = false
              end
              i = i+1
            end
          else
            accuracy =false
          end
          if accuracy == true
            print "all authors were correct"
            f.print "1" + ","
          else
            f.print "0"+ ","
          end
        else 
          f.print "0,"
        end 

      end
      # check the rest of the field values
      if !newBookTitle.nil? 
        # check for it in the title
        print "newBookTitle == #{newBookTitle}"

        # newBookTitle can be array of string.. maybe kill it if its an
        # array>?

        if newBookTitle.kind_of?(Array)
          f.print "0,"
        elsif parsed["title"].include? newBookTitle
          print "booktitle was correct"
          f.print "1" + ","
        elsif (!parsed["collectionTitle"].nil?) && (parsed["collectionTitle"].include? newBookTitle)
          print "bookTitle was correct"
          f.print "1" + ","
        else
          f.print "0" + ","
        end
        print "bookTitle"
      end
      if !newContainer.nil?
        if parsed["containerTitle"].include? newContainer
          f.print "1,"
        else
          f.print "0,"
        end

        print "container"
      end

      if !newDate.nil?
        #check event-date and issued.. date-parts for both and its first in
        #the array of 2 array????
        outerPart = parsed["event-date"]
        datePartEvent = outerPart["date-parts"]
        #print datePartEvent
        outerPart = parsed["issued"]
        datePartIssued = outerPart["date-parts"]
        if datePartEvent.include? newDate
          f.print "1,"
        elsif datePartIssued.include? newDate
          f.print "1," 
        else
          f.print "0,"
        end 
        #print datePart[0]
        #print "date" 
      end
      #abort("heh")
      if !newDoi.nil?
        print "doi"
        parsedDoi = parsed["DOI"]
        if !parsedDoi.nil?
          f.print "2,"  
        elsif parsedDoi.include? newDoi
          f.print "1,"
        else 
          f.print "0,"
        end 
      end

      if !newEdition.nil?
        print "edition"
        parsedEdition = parsed["edition"]
        if !parsedEdition.nil?
          f.print "2,"
        elsif (newEdition.kind_of?(String)) && (parsedEdition.include? newEdition)
          f.print "1,"
        else
          f.print "0,"
        end
      end

      if !newEditor.nil?
        print "editor"
        if accuracyForEditor == "1"
          f.print "1,"
        elsif
          f.print "0,"
        end
      else
        f.print "2,"
      end

      if !newJournal.nil?

        ## MAY NEED TO NOT ALTER NAME THIS MUCH.. FOR TESTING PURPOSES..
        #BECAUSE THE TRAINING WILL ADD THE TAGS ITSELF TO TRY GET THEM
        #CORRECT
        # appears in container-title and collection-title
        print "journal"
        parsedContainerTitle = parsed["container-title"]
        parsedCollectionTitle = parsed["collection-title"]

        if (!parsedContainerTitle.nil?) || (!parsedCollectionTitle.nil?)

          if (parsedContainerTitle.include? newJournal)
            f.print "1,"
          elsif (parsedCollectionTitle.include? newJournal)
            f.print "1,"
          else
            f.print "0,"
          end
        else
          f.print "2,"
        end  
      end     

      if !newLocation.nil?
        # appears in publisher and title also try archiveLocation
        print "location"
        parsedTitle = parsed["title"]
        parsedPublisher = parsed["publisher"]
        parsedArchiveLocation = parsed["archiveLocation"]
        print "\nParsed Title :: #{parsedTitle} \n"
        print "\nnewLocation :: #{newLocation} \n"
        # This is where the magic happens
        #parsedTitle.each do |title|
        if (!parsedTitle.nil?) && newLocation.kind_of?(String) && (parsedTitle.include? newLocation)
          print "It was in the title"
          # may need to change this to a 1
          f.print "2,"
          break
        elsif (!parsedArchiveLocation.nil?)&&(parsedArchiveLocation.include? newLocation)
          print "It was in the archive"
          f.print "1,"
          break
          #else parsedPublisher.include? newLocation
          #  print "It was in the publisher"
          #  f.print "1,"
        end
        #end  
      else
        f.print "2,"
      end

      if !newPages.nil?
        print "pages"
        if !parsed["page"].nil?

          pageTest =  parsed["page"].split(/-/)
          print newPages
          check = true

          pageTest.each do |page|

            if(!newPages.include? page)
              check =false
            end
          end

          if(check ==true) 
            print "pages was correct"
            f.print "1,"
          else
            f.print "0,"
          end
        end
        f.print "2,"
      else
        f.print "2,"
      end

      if !newPublisher.nil?
        print "publisher"
        parsedPublisher = parsed["publisher"]

        if !parsedPublisher.nil?

          if (newPublisher.kind_of?(String)) && (parsedPublisher.include? newPublisher)
            f.print "1,"
          else
            f.print "0,"
          end
          f.print "2," 
        end
      end
      if !newTranslator.nil?
        if accuracyForTrans == "1"
          f.print "1," 
        elsif accuracyForTrans == "0"
          f.print "0,"
        end    
      end
      if !newUrl.nil?
        parsedUrl = parsed["Url"]
        if  !parsedUrl.nil?
          if parsedUrl.include? newUrl
            f.print "1,"
          else
            f.print "0,"
          end 
        else
          f.print "2,"
        end
      else
        f.print "3,"
      end

      if !newVolume.nil?
        parsedVolume = parsed["volume"]
        if !parsedVolume.nil?
          if parsedVolume.include? newVolume
            f.print "1,"
          else
            f.print "0,"
          end
        else
          f.print "2,"
        end
      else
        f.print "3,"
      end


      f.print "\n"
      #print "FOUND EM"
      #print parsed[key]
      #abort("HAH")
      #newSplitAuthor.each do |auth|
      #  if(){

      # }
      #end
      #if(){

      #}    


      #open('textFile.txt', 'a'){ |f|
      #  f.print citation["annotatedBib"] + "\n"
      #}
  
    gets
    end

  }
}


#Anystyle.parse 


#client[:articles1].find.each {
#  |doc| print doc
#  print "There are #{docs.count} documents"
#  break
#}


client.close


def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  return m if n == 0
  return n if m == 0
  d = Array.new(m+1) {Array.new(n+1)}

  (0..m).each {|i| d[i][0] = i}
  (0..n).each {|j| d[0][j] = j}
  (1..n).each do |j|
    (1..m).each do |i|
      d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                  d[i-1][j-1]       # no operation required
                else
                  [ d[i-1][j]+1,    # deletion
                    d[i][j-1]+1,    # insertion
                    d[i-1][j-1]+1,  # substitution
                  ].min
                end
    end
  end
  d[m][n]
end

