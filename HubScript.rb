#!/usr/bin/ruby

require 'colorize'
require 'snmp'

@host =  192.168.113.203


def ListAllPorts()


begin
    fin = false

    option1 = "1) List all ports.\n"
    option2 = "2) Change port to a new segment.\n"
    option3 = "3) Exit"

    menu ="Select operation number:\n"+option1+option2+option3

    while fin == false do
        puts menu.yellow
        option = gets.chomp
        if option == "1" then

        elsif option == "2" then

        elsif option == "3" then
            puts "Bye"
            fin = true
        else
            puts "Incorrect option, use a valid number".red
        end

    end
end
