#!/usr/bin/ruby

require 'colorize'
require 'netsnmp'
include NETSNMP

@host = "192.168.113.202"

def DigitsNumber(number)
  d = 1
  i = number
  while i > 10 do
    i /= 10
    d += 1
  end
  return d
end


def CheckValidPort(port)
  length = port.length
  port = port.to_i
  digits = DigitsNumber(port)
  if length == digits
    if (port > 0 && port < 15) then
      return true
    else
      return false
    end
  else
    return false
  end
end

def CheckValidSegment(segment)
  length = segment.length
  segment = segment.to_i
  digits = DigitsNumber(segment)
  if length == digits
    if (segment > 0 && segment < 5) then
      return true
    else
      return false
    end
  else
    return false
  end
end

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
        puts "Port #{i}\t  Segment #{1}".light_green
      elsif value == segmentIds.at(1)
        puts "Port #{i}\t  Segment #{2}".light_green
      elsif value == segmentIds.at(2)
        puts "Port #{i}\t  Segment #{3}".light_green
      else
        puts "Port #{i}\t  Segment #{4}".light_green
      end
      i = i + 1
    end
  end
  manager.close
end

def BandwithOnPort(port)
    value = GetPortInterface(port)
    manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
    oid = "1.3.6.1.4.1.43.10.26.1.1.1.5.1."+port
    value = manager.get(oid: oid)
end

def ListPortTypes(segmentIds)
  i = 1
  manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
  manager.walk(oid: "1.3.6.1.4.1.43.10.26.1.1.1.7").each do |oid_code, value|
    if(i < 15)
      if value == 2
        puts "Port #{i}\t  RJ45".light_green
      elsif value == 255
        puts "Port #{i}\t  Cascade".light_green
      else
        puts "Port #{i}\t  Unknown".light_green
      end
      i = i + 1
    end
  end
  manager.close
  puts "\n"
end

def ChangePort2NewSegment(port, segmentIds, segment)
  segment = segment.to_i
  query = "1.3.6.1.4.1.43.10.26.1.1.1.5.1." + port
  valor = segmentIds.at(segment-1).to_i
  manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
  manager.set(oid: query, value: valor)
  manager.close
  segment = segment.to_s
  puts "Port ".light_green + (port.light_green).underline + " changed to segment ".light_green + (segment.light_green).underline
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

def PortsFromFile(filename,segmentIds)
  file_data = File.read(filename).split
  nline = 0
  file_data.each do |line|
    nline = nline + 1
    port,segment = line.split(':')
    if (CheckValidPort(port) && CheckValidSegment(segment)) then
      ChangePort2NewSegment(port,segmentIds,segment)
    else
      nlineS = nline.to_s
      puts "Error in line ".light_red + nlineS.light_red
    end
  end
end

begin
  fin = false

  option1 = "1)".bold + " List all ports.\n"
  option2 = "2)".bold + " Change port to a different segment.\n"
  option3 = "3)".bold + " Bandwith on a port\n"
  option4 = "4)".bold + " List port types\n"
  option5 = "5)".bold + " Change ports from a "+"file\n".bold
  option6 = "6)".bold + " Exit"

  menu ="Select operation number:\n".bold+option1+option2+option3+option4+option5+option6
  segmentIds = GetSegmentIds()

  while fin == false do
      puts menu.light_yellow
      option = gets.chomp
      if option == "1" then # List all the ports
          ListAllPorts(segmentIds)

      elsif option == "2" then  # Change port to different segment
        dentro = false
        while dentro == false do
            puts "Select port to move to a different segment [1-14]. 0 to go back to the Menu".light_cyan
            port = gets.chomp
            if port == "0" then
              dentro = true
            elsif CheckValidPort(port) then
              dentro2 = false
              while dentro2 == false do
                puts "Select new segment [1-4] for port ".light_cyan + (port.light_cyan).underline + ". 0 to go back to the port select".light_cyan
                segment = gets.chomp
                if segment == "0" then
                  dentro2 = true
                elsif CheckValidSegment(segment) then
                  ChangePort2NewSegment(port, segmentIds, segment)
                  dentro2 = true
                  dentro = true
                else
                  puts "Incorrect segment".light_red
                end
              end
            else
                puts "Incorrect port".light_red
            end
        end

      elsif option == "3" then
          dentro = false
          while dentro == false do
              puts "Select port to see Bandwith [1-14]. 0 to go back to the Menu".light_cyan
              port = gets.chomp
              if port == "0" then
                  dentro = true
              elsif ValidPort?(port.to_i) then
                  BandwithOnPort(port)
              else
                  puts "Incorrect port".light_red
              end
          end

      elsif option == "4" then
        ListPortTypes(segmentIds)

      elsif option == "5" then
        print "Introduce filepath: ".light_cyan
        $stdout.flush
        filename = gets.chomp
        if (File.exist?(filename)) then
          PortsFromFile(filename,segmentIds)
          puts
          puts "RESULTADO DE LA CONFIGURACION".light_green
          ListAllPorts(segmentIds)
        else
          puts "The given filepath doesn't exist.".light_red
        end
      elsif option == "6" then
          puts ("Closing program".light_yellow).italic
          fin = true
      else
          puts "Incorrect option, use a valid number".light_red
      end

  end
end
