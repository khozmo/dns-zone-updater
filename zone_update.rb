#!/usr/bin/env ruby

require 'zonefile'
require 'fileutils'

def load_zones(glob)
  dn = []
  File.open(glob).each_line {|line| dn << line.chomp}
  dn
end

def migrate (zones)
  zones.each do |z|
    file_name = "zonefiles/pri.#{z}"
    if File.exist?(file_name) then
      zf = Zonefile.from_file(file_name)
      zf.ns[0..2] = [ {:name=>nil, :ttl=>nil, :class=>"in", :host=>"auth1.nextlevelinternet.com."},
                      {:name=>nil, :ttl=>nil, :class=>"in", :host=>"auth2.nextlevelinternet.com."},
                      {:name=>nil, :ttl=>nil, :class=>"in", :host=>"auth3.nextlevelinternet.com."} ]
      zf.soa[:primary] = "auth1.nextlevelinternet.com"
      zf.new_serial
      File.open("./updated-zones/pri.#{z}", 'w') {|f| f.write(zf.output) }
    end
  end
end

if ARGV.empty? then
  puts("usage: please supply a text file containing domains you wish to update") 
  exit
end

FileUtils.rm_rf('updated-zones') if Dir.exist?('updated-zones')
Dir.mkdir('updated-zones')
migrate (load_zones(ARGV[0]))


