require 'conf/environment.rb'

config=<<EOF
bin_paths:
   - pngcrush: /usr/bin/pngcrush
   - jpegtran: /usr/bin/jpegtran
   - gifsicle: /usr/bin/gifsicle
EOF

File.open('specs/test_dir/.sqwidgetconfig.yml','w') do |f|
  f.write(config)
  f.close
end

ConfManager.new('specs/test_dir')

[ 
  PngCompressor.new,
  GifCompressor.new,
  JsCompressor.new,
  CssCompressor.new
].each do |cmp| 


  puts "initialising.."
  cmp.compress
 # puts "compressing #{cmp.collect_filepaths.size } #{cmp.input_file_extensions.to_s.upcase} files from #{ cmp.byteweight_before} to #{cmp.byteweight_after} bytes"



end
