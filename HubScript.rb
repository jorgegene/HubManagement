#!/usr/bin/ruby

=begin

 This script needs to install "colorize" and "netsnmp" to work propertly.
 Use "sudo gem install colorize & sudo gem install netsnmp"

 Change the $host variable with the ip of the device you're going to admin.
 Run the script like following: "./HubManagement.rd"

=end

require 'colorize'
require 'netsnmp'
include NETSNMP

$host = "192.168.113.202"

def GetPortInterface(port)
    manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
    oid = "1.3.6.1.4.1.43.10.26.1.1.1.5.1."+port
    value = manager.get(oid: oid)
    return value
end

# List all ports of the device followed by the segment they belong to.
def ListAllPorts(segmentIds)
  i = 1
  s1 = Array.new
  s2 = Array.new
  s3 = Array.new
  s4 = Array.new

  manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
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
  puts "\n"
end


# Test if the port given by the user is correct
def ValidPort?(port)
  portI = port.to_i
  if portI >= 1 && portI <= 14 then
      if port == 12
          puts "Port 12 not allowed".red
          return false
      else
          return true
      end
  end
  return false
end

# List all ports of the device followed by its type
def ListPortTypes(segmentIds)
  i = 1
  manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
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

# Change the given port to the new segment
def ChangePort2NewSegment(port, segmentIds)
  dentro = false
  while dentro == false do
      puts "Select new segment [1-4] for port ".light_cyan + (port.light_cyan).underline + ". 0 to go back to the port select".light_cyan
      segment = gets.chomp
      segment = segment.to_i
      if segment == 0 then
        dentro = true
      elsif segment > 0 && segment < 5 then
        query = "1.3.6.1.4.1.43.10.26.1.1.1.5.1." + port
        valor = segmentIds.at(segment-1).to_i
        puts query
        puts valor
        manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
        manager.set(oid: query, value: valor)
        manager.close
        dentro = true
      else
          puts "Incorrect segment\n".red
      end
  end
end

# Collect all the segments ids (used to format the info showed by the script)
def GetSegmentIds()
  i = 1
  segmentIds = Array.new
  manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
  manager.walk(oid: "1.3.6.1.4.1.43.10.26.1.1.1.5").each do |oid_code, value|
    if(i > 14 && i < 19)
      segmentIds.push(value)
    end
    i = i + 1
  end
  manager.close
  return segmentIds
end

def changeDeviceIp()
  manager = Client.new(:host => $host,:community => 'security',:version => :SNMPv1)
  oid = "1.3.6.1.4.1.43.10.27.1.1.1.15.1"
  value = manager.get(oid: oid)

  return value
end

# Main body of the script
begin
  if(ARGV.size > 0)
    $host = ARGV[0].to_s
  end

  fin = false

    option1 = "1)".bold + " List all ports.\n"
    option2 = "2)".bold + " Change port to a different segment.\n"
    option3 = "3)".bold + " Bandwith on a port\n"
    option4 = "4)".bold + " List port types\n"
    option5 = "5)".bold + " Exit"

    menu ="Select operation number:\n".bold+option1+option2+option3+option4+option5
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
              elsif ValidPort?(port) then
                 ChangePort2NewSegment(port, segmentIds)
              else
                  puts "Incorrect port\n".red
              end
          end

        elsif option == "3" then
            changeDeviceIp()
        elsif option == "4" then
          ListPortTypes(segmentIds)

        elsif option == "5" then
            puts ("Closing program".light_yellow).italic
            fin = true
        else
            puts "Incorrect option, use a valid number".light_red
        end

    end
end
