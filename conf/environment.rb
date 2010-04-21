$squidget_dir=File.dirname(File.expand_path(__FILE__+'/..'))
['lib','lib/compressors','conf'].each{|dir| $LOAD_PATH << $squidget_dir+"/#{dir}"  }


require 'confManager'
require 'rubygems'
require 'yui/compressor'
require 'closure-compiler'
require 'compressor'
require 'yaml'
require 'base64'
require 'uri'
require 'pathname'
require 'pp'

Dir[$squidget_dir+'/lib/compressors/*'].entries.each do |fname|
  require File.basename(fname,'.rb') if fname =~ /Compressor\.rb$/  
end
