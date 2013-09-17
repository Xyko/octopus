# -*- encoding : utf-8 -*-
require 'rubygems'
require 'ruby-progressbar'
require 'slop'


opts = Slop.parse do
  on '-v', 'Print the version' do
    puts "Version 1.0"
  end

  command 'add' do
  	puts "add"
  end

  command 'spy' do
  	puts "spy"
  end

end


