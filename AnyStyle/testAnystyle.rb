#!/usr/bin/ruby
require 'mongo'
require 'rubygems'
require 'json'
require 'anystyle/parser'
Mongo::Logger.logger.level = ::Logger::FATAL


require 'levenshtein'
def distance_percent(first,second)
  max_distance = [first,second].max_by(&:length).length
  distance = Levenshtein.distance(first,second)
  (100.0 / max_distance * distance).round.to_s + "%"
end
print "Hello World!"

# connecting to the db
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'real')
client.collections.each { |coll| print coll.name}
# client.close
docs = client[:articles1].find
print "There are #{docs.count} documents"
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
headersStringCSV = "_id;style;bib;resBib;author;bookTitle;container;date;doi;edition;editor;journal;location;pages;publisher;translator;url;volume;total\n"

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
    #f.print object["$oid"] + ";"

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
      f.print object["$oid"] + ";" 
      f.print citation["style"] + ";"
      f.print citation["bib"]+ ";"
      myString = Anystyle.parse(citation["bib"], :hash)#.to_s
      print "\n"
      print myString[0]
      testHash = myString[0]
      f.print "#{testHash};" 

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
      #print "newEditor :: #{newEditor}"
      if !newEditor.nil?
        newSplitEditor = newEditor.split(/,|&/)
        newSplitEditor.each do |edit|
          # print edit + "\n"
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
          #print trans + "\n"
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
          puts "#{newAuthor} : new Author "
          #puts "#{newSplitAuthor} : newSplitAuthor"
          puts "#{parsed[key]}: parsed[key]"
          puts "#{newSplitAuthor.length} == #{parsed[key].length} "


          if (!newSplitAuthor.nil?) &&(newSplitAuthor.length == parsed[key].length)
            print "THEY WERE EQUALLL\n"
            finalPercentage = 0.000
            newSplitAuthor.each do |auth|
              fullAuthString = parsed[key]
              puts fullAuthString
              puts "#{fullAuthString[i]} + #{i}"
              print fullAuthString[i]
              puts "#{auth} + #{i}"
              puts "\n#{auth} == #{fullAuthString[i]["family"]} #{fullAuthString[i]["given"]}"
              fullAuthFinalString = "#{fullAuthString[i]["family"]} #{fullAuthString[i]["given"]}"
              puts "OMG" 
              puts distance_percent(fullAuthFinalString,auth)
              editDistance = levenshtein_distance(fullAuthFinalString,auth)
              puts "EDIT DISTANCE = #{editDistance}"
              percent1 = 0.000

              # use variables instead of calculating multiple times
              puts auth.length
              puts fullAuthFinalString.length
              if auth.length > fullAuthFinalString.length
                percent1 = (auth.length.to_f-editDistance.to_f) / auth.length.to_f
              else
                percent1 = (fullAuthFinalString.length.to_f - editDistance.to_f) / fullAuthFinalString.length.to_f
              end
              puts "PERCENT == %.4f" % [percent1] 
              finalPercentage = finalPercentage + percent1
              if (auth.include? "#{fullAuthString[i]["family"]} #{fullAuthString[i]["given"]}")
                print "Found correct Author"
              else
                accuracy = false
              end
              i = i+1
            end
            puts "final percentage %.4f " % [finalPercentage/newSplitAuthor.length]
            f.puts finalPercentage/newSplitAuthor.length.to_f
            #  Compare not equal lengths with family and given on different
            #  iterations
          else
            i =0
            j =0
            percent = 0.0000
            percent1 = 0.0000
            newSplitAuthor.each do |auth|
              fullAuthString = parsed[key]
              if j ==0
                finalAuthString = fullAuthString[i]["family"]
                j=1
              else
                finalAuthString = fullAuthString[i]["given"]
                j =0
                i = i+1
              end  
              puts distance_percent(finalAuthString,auth)
              editDistance = levenshtein_distance(finalAuthString, auth)
              puts "Edit distance = %.4f" % [editDistance]
              if editDistance == 0
                puts "iT WAS EXACT"
                percent1 = 1
              else
                puts " auth.length = %f" % [auth.length]
                puts "finalAuthString = %f" % [finalAuthString.length]
                puts "auth = %s" % [auth]
                puts "finalAuth = %s" % [finalAuthString]
                if auth.length > finalAuthString.length
                  percent1 = (auth.length.to_f-editDistance.to_f)/ auth.length.to_f
                else
                  percent1 = (finalAuthString.length.to_f - editDistance.to_f)/ finalAuthString.length.to_f
                end
              end
              percent = percent + percent1 
              puts "percent == %.4f" % [percent]
              #accuracy =false

            end
            finalpercent = percent/newSplitAuthor.length.to_f
            puts "finalPercent = %.4f" % [finalpercent]
            f.print "#{finalpercent};"
          end
          if accuracy == true
            print "all authors were correct\n"
            #f.print "1" + ";"
          else
            #f.print "0"+ ";"
          end
        else 
          #f.print "0;"
        end 

      end
      # check the rest of the field values
      if !newBookTitle.nil? 
        # check for it in the title
        print "newBookTitle == #{newBookTitle}"

        # newBookTitle can be array of string.. maybe kill it if its an
        # array>?
        if newBookTitle.kind_of?(Array)
          percentTitle = distance_percent(parsed["title"],newBookTitle[0])
          puts percentTitle
          percentCollTitle =  distance_percent(parsed["collectionTitle"],newBookTitle[1])
          puts percentCollTitle
          finalPercent = if percentTitle < percentCollTitle then percentTitle else percentCollTitle end
          f.print "#{finalPercent};"
        end 

        if newBookTitle.kind_of?(Array)
          f.print "0;"
          puts "\n#{parsed["title"]} == #{newBookTitle}\n"
          puts "#{parsed["collectionTitle"]}\n"
        elsif parsed["title"].include? newBookTitle
          print "booktitle was correct"
          #f.print "1" + ";"
        elsif (!parsed["collectionTitle"].nil?) && (parsed["collectionTitle"].include? newBookTitle)
          print "bookTitle was correct"
          #f.print "1" + ";"
        else
          #f.print "0" + ";"
        end
        print "bookTitle"
      end
      if !newContainer.nil?

        percentContainer =  distance_percent(parsed["containerTitle"],newContainter)  
        puts percentContainer
        f.print "#{percentContainer};"
        puts "#{parsed["containerTitle"]} == #{newContainer}\n"
        if parsed["containerTitle"].include? newContainer
          #f.print "1;"
        else
          #f.print "0;"
        end

        print "container"
      else
        f.print "-;"
        puts "no container - give it a dash"
      end

      if !newDate.nil?
        #check event-date and issued.. date-parts for both and its first in
        #the array of 2 array????
        outerPart = parsed["event-date"]
        datePartEvent = outerPart["date-parts"]
        #print datePartEvent
        outerPart = parsed["issued"]
        datePartIssued = outerPart["date-parts"]
        puts datePartEvent
        puts datePartIssued
        puts newDate
        if newDate.kind_of(Array)
          newDate = newDate[0].gsub(".", "")  
          
        else  
          newDate = newDate.gsub(".", "")
        end
        #puts "#{datePartEvent[0][0]} ----- " 
        #puts newDate 
        #percentDate = distance_percent(datePartEvent[0][0].to_s,newDate)
        #puts percentDate
        #percentDateIssued = distance_percent(datePartIssued[0][0].to_s,newDate)
        #puts percentDateIssued 
        puts "#{datePartEvent} == #{newDate}\n"
        if datePartEvent[0][0].to_s.include? newDate
          f.print "1.000;"
          puts "1.0000%"
        elsif datePartIssued[0][0].to_s.include? newDate
          f.print "1.000;"
          puts "1.0000%" 
        else
          puts "0.0000%"
          f.print "0.000;"
        end 
        #print datePart[0]
        #print "date" 
      end
      #abort("heh")
      if !newDoi.nil?
        print "doi"
        parsedDoi = parsed["DOI"]
        if !parsedDoi.nil?
          #f.print "2;"
          percentDOI = distance_percent(parsedDoi,newDoi)
          puts percentDOI
          f.print "#{percentDOI};"
          puts "#{parsedDoi} == #{newDoi}\n"  
          if parsedDoi.include? newDoi
            #f.print "1;"
          else 
            #f.print "0;"
          end
        else
          f.print "-;"
        end
      else
          f.print "-;"
      end

      if !newEdition.nil?
        print "edition"
        parsedEdition = parsed["edition"]
        puts "#{parsedEdition} == #{newEdition}\n"
        if !parsedEdition.nil?
          #f.print "2;"
          percentEdition = distance_percent(parsedEdition,newEdition)
          puts percentEdition
          f.print "#{percentEdition};"
          if (newEdition.kind_of?(String)) && (parsedEdition.include? newEdition)
           # f.print "1;"
          else
            #f.print "0;"
          end
        else
          f.print "-;"
        end
        else
          f.print "-;"
      end

      if !newEditor.nil?
        print "editor"
        if accuracyForEditor == "1"
          f.print "1.0000;"
          #f.print "1;"
        elsif
          f.print "0.0000;"
        end
      else
        f.print "-;"
      end

      if !newJournal.nil?

        ## MAY NEED TO NOT ALTER NAME THIS MUCH.. FOR TESTING PURPOSES..
        #BECAUSE THE TRAINING WILL ADD THE TAGS ITSELF TO TRY GET THEM
        #CORRECT
        # appears in container-title and collection-title
        print "journal"
        parsedContainerTitle = parsed["container-title"]
        parsedCollectionTitle = parsed["collection-title"]
        puts parsedContainerTitle
        puts parsedCollectionTitle 
        if (!parsedContainerTitle.nil?)# || (!parsedCollectionTitle.nil?)
          puts "#{parsedContainerTitle} == #{newJournal}\n"
          percentJournal = distance_percent(parsedContainerTitle,newJournal)
          
          if (parsedContainerTitle.include? newJournal)
            #f.print "1;"
          elsif (parsedCollectionTitle.include? newJournal)
            #f.print "1;"
          else
            #f.print "0;"
          end
        end
        if !parsedCollectionTitle.nil?
          percentJournal1 = distance_percent(parsedCollectionTitle, newJournal)
          puts percentJournal1 
          #f.print "2;"
        end
          if percentJournal < percentJournal1 
            f.print "#{percentJournal};"
          else
            f.print "#{percentJournal1};"
          end  
      end     

      if !newLocation.nil?
        # appears in publisher and title also try archiveLocation
        print "location"
        parsedTitle = parsed["title"]
        parsedPublisher = parsed["publisher"]
        parsedArchiveLocation = parsed["archiveLocation"]
        print "\nParsed Title :: #{parsedTitle} == \n"
        print "\nnewLocation :: #{newLocation} \n"
        # This is where the magic happens
        #parsedTitle.each do |title|
        #

        if (!parsedTitle.nil?) #&& newLocation.kind_of?(String) && (parsedTitle.include? newLocation)
          percentLocationTit = distance_percent(parsedTitle, newLocation) 
          puts percentLocationTit
          print "It was in the title"
          # may need to change this to a 1
          #f.print "2;"
          break
        end
        if (!parsedArchiveLocation.nil?)#&&(parsedArchiveLocation.include? newLocation)
          percentLocationLoc = distance_percent(parsedArchiveLocation, newLocation)
          puts percentLocationLoc
          print "It was in the archive"

          #f.print "1;"
          break
          #else parsedPublisher.include? newLocation
          #  print "It was in the publisher"
          #  f.print "1,"
        end
        finalPercent
        if percentLocationTit < percentLocationLoc 
            finalPercent = percentLocationTit
        else
            finalPercent = percentLocationLoc
        end
        ###
        # MAGIC
        #  Need to make sure.. everything passed to csv.. is a floating point..
        #  so its not just zero..
        #
        f.print "#{finalPercent};"
        #end  
      else
        f.print "-;"
      end

      if !newPages.nil?
        print "pages"
        if !parsed["page"].nil?

          percentPage = distance_percent(parsed["page"],newPages )
          puts percentPage
          f.print "#{percentPage};"
          pageTest =  parsed["page"].split(/-/)
          print newPages
          check = true

          pageTest.each do |page|
            puts "#{newPages} == #{page}\n"
            if(!newPages.include? page)
              check =false
            end
          end

          if(check ==true) 
            print "pages was correct"
            #f.print "1;"
          else
            #f.print "0;"
          end
        end
        f.print "-;"
      else
        f.print "-;"
      end

      if !newPublisher.nil?
        print "publisher"
        parsedPublisher = parsed["publisher"]

        if !parsedPublisher.nil?
          percentPub = distance_percent(parsedPublisher, newPublisher)
          puts percentPub
          f.print "#{percentPub};"
          puts "#{parsedPublisher} == #{newPublisher}"
          if (newPublisher.kind_of?(String)) && (parsedPublisher.include? newPublisher)
            #f.print "1.000;"
          else
            #f.print "0.000;"
          end
          f.print "-;" 
        end
      end
      if !newTranslator.nil?
        if accuracyForTrans == "1"
          f.print "1.000;" 
        elsif accuracyForTrans == "0"
          f.print "0.000;"
        end    
      end
      if !newUrl.nil?
        parsedUrl = parsed["Url"]
        if  !parsedUrl.nil?
          percentURL = distance_percent(parsedUrl, newUrl)
          puts percentURL
          f.print "#{percentURL};"
          if parsedUrl.include? newUrl
            #f.print "1;"
          else
            #f.print "0;"
          end 
        else
          f.print "-;"
        end
      else
        f.print "-;"
      end

      if !newVolume.nil?
        parsedVolume = parsed["volume"]
        if !parsedVolume.nil?
          percentVol = distance_percent(parsedVolume, newVolume)
          puts percentVol
          f.print "#{percentVol};"
          puts "#{parsedVolume} == #{newVolume}"
          if parsedVolume.include? newVolume
            #f.print "1;"
          else
            #f.print "0;"
          end
        else
          f.print "-;"
          puts "volume was empty for original"
        end
      else
        f.print "-;"
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


