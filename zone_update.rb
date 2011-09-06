#!/usr/bin/env ruby

require 'zonefile'
require 'fileutils'

def master_zone_config(dn)
out =<<-ENDH
zone "#{dn}" {
       type master;
       file "/etc/bind/master/pri.#{dn}";
       };
      
      ENDH
end

def slave_zone_config (dn)
  out =<<-ENDH
zone "#{dn}" {    
      type slave;
      file "/var/cache/bind/sec.#{dn}";
      masters {
              207.7.100.99;
              };
      };
      
      ENDH
  #puts out
end

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
      zf.soa[:primary] = "auth1.nextlevelinternet.com."
      zf.origin = zf.origin.sub!("pri.","") + "."
      zf.new_serial
      File.open("./updated-zones/zones.master.config-delta", 'a') {|f| f.write(master_zone_config(z)) ; f.close}
      File.open("./updated-zones/zones.slaves.config-delta", 'a') {|f| f.write(slave_zone_config(z)) ; f.close}
      File.open("./updated-zones/pri.#{z}", 'w') {|f| f.write(zf.output) ; f.close}
    else 
      puts z
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
