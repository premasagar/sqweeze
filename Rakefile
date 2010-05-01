require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('sqweeze', '0.0.1') do |p|
  p.description    = "A command line web-asset optimisation tool"
  p.url            = "http://github.com/premasagar/sqwidget-builder"
  p.author         = "Andrea Fiore"
  p.email          = "and@inventati.org" 
  p.spec_pattern=['spec']
  p.ignore_pattern = ["doc/", 'spec/test_dir_sqweezed',"webapp"]
  p.runtime_dependencies = ['hpricot >= 0.8.2','closure-compiler >=0.2.2','yui-compressor = 0.9.1']

end

