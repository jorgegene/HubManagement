#!/usr/bin/ruby

require 'colorize'
require 'snmp'
include SNMP
@host = "192.168.113.202"



def ListAllPorts()
    ifTable = ObjectId.new("1.3.6.1.4.1.43.10.26.1.1.1.5")
    SNMP::Manager.open(:host => @host,:community => 'security',:version => :SNMPv1) do |manager|
        manager.walk("ifTable") { |vb| puts vb }
    end
end
def ValidPort?(port)
    if port.is_a? Integer then
        if port >= 1 && port <= 14 then
            if port == 12
                puts "Port 12 not allowed"
                return false
            else
                return true
            end
        end
    end
    return false
end

def BandwithOnPort(port)
end
begin
    fin = false

    option1 = "1) List all ports.\n"
    option2 = "2) Change port to a segment.\n"
    option3 = "3) Bandwith on a port\n"
    option4 = "4) Exit"

    menu ="Select operation number:\n"+option1+option2+option3+option4

    while fin == false do
        puts menu.yellow
        option = gets.chomp
        if option == "1" then
            ListAllPorts()
        elsif option == "2" then
            
        elsif option == "3" then
            dentro = false
            while dentro == false do
                puts "Select port to see Bandwith [1-14]. 0 to go back to the Menu"
                port = gets.chomp
                if port == "0" then
                    dentro = true
                elsif ValidPort?(port) then
                   BandwithOnPort(port) 
                else
                    puts "Incorrect port"
                end
            end

        elsif option == "4" then
            puts "Closing program"
            fin = true
        else
            puts "Incorrect option, use a valid number".red
        end

    end
end