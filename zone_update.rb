#!/usr/bin/env ruby

require 'zonefile'
require 'pp'
require 'ap'

def load_zones(glob)
  dn = []
  File.open(glob).each_line {|line| dn << line.chomp}
  puts dn.class
  dn
end

def migrate (zones)
  puts zones.class
  ap zones
  zones.each do |z|
    file_name = "zonefiles/pri.#{z}"
    if File.exist?(file_name) then
      puts Zonefile.from_file(file_name).output
    end
  end
end


if ARGV.empty? then
  puts("usage: please supply a text file containing domains you wish to update") 
  exit
end

migrate (load_zones(ARGV[0]))


