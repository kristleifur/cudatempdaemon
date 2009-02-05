#!/usr/bin/env ruby

#require 'yaml'

class GpuTempSetter
  def self.countCards()
    puts "Counting cards ..."
    sInfo = `nvclock -s`.split("\n")
    cards = {}
    sInfo.each_with_index do | sInfoLine, i |
      if (sInfoLine =~ /Card number/)
        cardNumber = sInfoLine.split(" ")[-1]
        cardName = sInfo[i - 1].split(":")[-1].strip()
        puts "\tCard #{cardNumber}: #{cardName}"
        cards[cardNumber] = cardName
      end
    end
    puts "... done."
    puts "---"
    return cards
  end
  
  def initialize()
    @wantedTabs = 3
    
    @grepStrings = {}
    @grepStrings["Core temperature"] = "GPU temperature:"
    @grepStrings["Board temperature"] = "Board temperature:"
    @grepStrings["Fan speed, RPM"] = "Fanspeed:"
    @grepStrings["Fan speed, percent"] = "PWM duty cycle:"
    
    @cards = GpuTempSetter::countCards()
  end
  
  def autoTemp
    @cards.keys.each do | cardID |
      `nvclock -c#{cardID} -f -F auto`  
    end
  end
  
  def getInfo
#    initialize()
    allCardsInfo = {}
    @cards.keys.each do | cardID |
      rawInfo = `nvclock -i`.split("\n")
      cardInfo = {}
      @grepStrings.each do | infoKey, infoGrepString |
        infoStr = "#{(rawInfo.grep(/#{infoGrepString}/))}".split(" ")
  #      puts "infoStr: #{infoStr.inspect()}"
  #      print "grep:\n"
        numGrep = "#{infoStr.grep(/[0-9]+/)}" # (/[0-9]*\.?[0.9]/)}"
  #      puts numGrep
  #      puts numGrep.to_f();
  #      puts "---"
        cardInfo[infoKey] = numGrep.to_f() # "#{rawInfo.grep(/#{infoGrepString}/)}".to_f()
      end
      allCardsInfo[cardID] = cardInfo
    end
    return allCardsInfo
  end
  
  def printInfo
    allCardsInfo = self.getInfo()
    allCardsInfo.each do | cardID, info |
      puts "Card #{cardID} (#{@cards[cardID]}) info: "
      info.keys.sort.each do | infoKey |
        tabStops = infoKey.length / 8
        puts "#{infoKey}:#{"\t" * [0, (@wantedTabs - tabStops)].max()}#{info[infoKey]}" 
      end
      puts "---"
    end
  end
  
end
