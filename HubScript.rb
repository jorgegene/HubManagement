#!/usr/bin/ruby

require 'colorize'

fin = false



option1 = "1) List all ports.\n"
option2 = "2) Change port to a segment.\n"
option3 = "3) Exit"

menu ="Select operation number:\n"+option1+option2+option3

while fin == false do
    puts menu.yellow
    option = gets.chomp
    if option == "1" then

    elsif option == "2" then
        
    elsif option == "3" then
        puts "Cerrando programa"
        exit(0)
    else
        puts "Incorrect option, use a valid number".red
    end

end