#!/usr/bin/ruby

require 'colorize'
require 'netsnmp'
include NETSNMP

@host = "192.168.113.202"

def GetPortInterface(port)
    manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
    oid = "1.3.6.1.4.1.43.10.26.1.1.1.5.1."+port
    value = manager.get(oid: oid)
    return value
end

def ListAllPorts(segmentIds)
  i = 1
  manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
  manager.walk(oid: "1.3.6.1.4.1.43.10.26.1.1.1.5").each do |oid_code, value|
    if(i < 15)
      if value == segmentIds.at(0)
        puts "Port #{i}\t  Segment #{1}".green
      elsif value == segmentIds.at(1)
        puts "Port #{i}\t  Segment #{2}".green
      elsif value == segmentIds.at(2)
        puts "Port #{i}\t  Segment #{3}".green
      else
        puts "Port #{i}\t  Segment #{4}".green
      end
      i = i + 1
    end
  end
  manager.close
  puts "\n"
end

def ValidPort?(port)
  portI = port.to_i
  if portI >= 1 && portI <= 14 then
      if port == 12
          puts "Port 12 not allowed"
          return false
      else
          return true
      end
  end
  return false
end

def BandwithOnPort(port)
    value = GetPortInterface(port)
    manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
    oid = "1.3.6.1.4.1.43.10.26.1.1.1.5.1."+port
    value = manager.get(oid: oid)
end

def ChangePort2NewSegment(port, segmentIds)
  dentro = false
  while dentro == false do
      puts "Select new segment [1-4] for port" + port + "or 0 to go back to the port select"
      segment = gets.chomp
      segment = segment.to_i
      if segment == 0 then
        dentro = true
      elsif segment > 0 && segment < 4 then
        query = "1.3.6.1.4.1.43.10.26.1.1.1.5.1." + port
        valor = segmentIds.at(segment-1).to_i
        puts query
        puts valor
        manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
        manager.set(oid: query, value: valor)
        manager.close
        dentro = true
      else
          puts "Incorrect segment\n".red
      end
  end
end

def GetSegmentIds()
  i = 1
  segmentIds = Array.new
  manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
  manager.walk(oid: "1.3.6.1.4.1.43.10.26.1.1.1.5").each do |oid_code, value|
    if(i > 14 && i < 19)
      segmentIds.push(value)
    end
    i = i + 1
  end
  manager.close
  return segmentIds
end

begin
    fin = false

    option1 = "1) List all ports.\n"
    option2 = "2) Change port to a different segment.\n"
    option3 = "3) Bandwith on a port\n"
    option4 = "4) Exit"

    menu ="Select operation number:\n"+option1+option2+option3+option4
    segmentIds = GetSegmentIds()

    while fin == false do
        puts menu.yellow
        option = gets.chomp
        if option == "1" then # List all the ports
            ListAllPorts(segmentIds)

        elsif option == "2" then  # Change port to different segment
          dentro = false
          while dentro == false do
              puts "Select port to move to a different segment [1-14] or 0 to go back to the Menu"
              port = gets.chomp
              if port == "0" then
                  dentro = true
              elsif ValidPort?(port) then
                 ChangePort2NewSegment(port, segmentIds)
              else
                  puts "Incorrect port\n".red
              end
          end

        elsif option == "3" then
            dentro = false
            while dentro == false do
                puts "Select port to see Bandwith [1-14]. 0 to go back to the Menu".green
                port = gets.chomp
                if port == "0" then
                    dentro = true
                elsif ValidPort?(port.to_i) then
                   BandwithOnPort(port)
                else
                    puts "Incorrect port".red
                end
            end

        elsif option == "4" then
            puts "Closing program".yellow
            fin = true
        else
            puts "Incorrect option, use a valid number".red
        end

    end
end
