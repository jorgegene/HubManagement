#!/usr/bin/ruby

=begin
  File: HubManagement.rb
  Authors: Jose Felix Longares
           Jorge Generelo Gimeno
  Libs installation:  This script needs to install "colorize"
      and "netsnmp" to work propertly.
      Use "sudo gem install colorize & sudo gem install netsnmp"
  Usage: Execute the script with ./HubScript <IP>
      where IP is the remote hub you want to manage.
      If you want to use a file to config the segments of the hub,
      you must use the following notation:
      <PortNumber1>:<SegmentNumber1>
                   .
                   .
                   .
      <PortNumberN>:<SegmentNumberN>     



 Change the $host variable with the ip of the device you're going to admin.
 Run the script like following: "./HubManagement.rd"

=end

require 'colorize'
require 'netsnmp'
include NETSNMP

#@host = "192.168.113.202"


=begin
  Return the number of digits of the given number
=end
def DigitsNumber(number)
  d = 1
  i = number
  while i > 10 do
    i /= 10
    d += 1
  end
  return d
end

=begin
  Returns true if the given port is a valid port for 3Com SSII PS40 Hub.
=end
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

=begin
  Returns true if the given segment is a valid port for 3Com SSII PS40 Hub.
=end
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

=begin
  Returns the interface value of the given port
=end
def GetPortInterface(port)
    manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
    oid = "1.3.6.1.4.1.43.10.26.1.1.1.5.1."+port
    value = manager.get(oid: oid)
    return value
end

=begin
  Given a list of segment's IDs, prints the segment of each port.
=end
def ListAllPorts(segmentIds)
  i = 1
  s1 = Array.new
  s2 = Array.new
  s3 = Array.new
  s4 = Array.new

  manager = Client.new(:host => @host,:community => 'security',:version => :SNMPv1)
  manager.walk(oid: "1.3.6.1.4.1.43.10.26.1.1.1.5").each do |oid_code, value|
    if(i < 15)
      if value == segmentIds.at(0)
        s1.push(i.to_s)
      elsif value == segmentIds.at(1)
        s2.push(i.to_s)
      elsif value == segmentIds.at(2)
        s3.push(i.to_s)
      else
        s4.push(i.to_s)
      end
      i = i + 1
    end
  end
  puts "* Segment 1:".light_green.bold
  if !s1.empty?
    s1.each do |p|
      puts ("\t- Port " + p).green
    end
  else
    puts "\n"
  end
  puts "\n* Segment 2:".light_green.bold
  if !s2.empty?
    s2.each do |p|
      puts ("\t- Port " + p).green
    end
  else
    puts "\n"
  end
  puts "\n* Segment 3:".light_green.bold
  if !s3.empty?
    s3.each do |p|
      puts ("\t- Port " + p).green
    end
  else
    puts "\n"
  end
  puts "\n* Segment 4:".light_green.bold
  if !s4.empty?
    s4.each do |p|
      puts ("\t- Port " + p).green
    end
  else
    puts "\n"
  end
  manager.close
end

=begin
  Given a list of segment's IDs, prints the type of each port.
=end
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
end

=begin
  Given a list of segment's IDs, a port number and a segment number,
  changes the selected port to the selected segment.
=end
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

=begin
  Returns a list of segmentIds
=end
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

=begin
  Given a list of segment's IDs and the name of an existing file,
  changes the segment related to each port in order to the file info.
=end
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
  if (ARGV.length != 1)
    puts "Incorrect number of params. ./HubScript.rb <IP>.".light_red
    fin = true
  else
    @host = ARGV[0]
    puts "Welcome you will be working on ".light_magenta + ((ARGV[0].to_s).light_magenta).underline
    segmentIds = GetSegmentIds()
    fin = false
    option1 = "1)".bold + " List all ports.\n"
    option2 = "2)".bold + " List port types.\n"
    option3 = "3)".bold + " Change port to a different segment.\n"
    option4 = "4)".bold + " Change ports from a "+"file.\n".bold
    option5 = "5)".bold + " Exit."
  
    menu ="Select operation number:\n".bold+option1+option2+option3+option4+option5
  end

  while fin == false do
      puts menu.light_yellow
      option = STDIN.gets.chomp
      if option == "1" then # List all the ports
          ListAllPorts(segmentIds)

      elsif option == "2" then
        ListPortTypes(segmentIds)

      elsif option == "3" then  # Change port to different segment
        dentro = false
        while dentro == false do
            puts "Select port to move to a different segment [1-14]. 0 to go back to the Menu".light_cyan
            port = STDIN.gets.chomp
            if port == "0" then
              dentro = true
            elsif CheckValidPort(port) then
              dentro2 = false
              while dentro2 == false do
                puts "Select new segment [1-4] for port ".light_cyan + (port.light_cyan).underline + ". 0 to go back to the port select".light_cyan
                segment = STDIN.gets.chomp
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

      elsif option == "4" then
        print "Introduce filepath: ".light_cyan
        $stdout.flush
        filename = STDIN.gets.chomp
        if (File.exist?(filename)) then
          PortsFromFile(filename,segmentIds)
          puts
          puts ("FINAL CONFIGURATION".light_green).bold
          ListAllPorts(segmentIds)
        else
          puts "The given filepath doesn't exist.".light_red
        end
      elsif option == "5" then
          puts ("Closing program".light_yellow).italic
          fin = true
      else
          puts "Incorrect option, use a valid number".light_red
      end

  end
end
