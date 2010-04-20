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

[ PngCompressor.new,
  GifCompressor.new,
  JsCompressor.new,
  CssCompressor.new
].each do |cmp| 
  
  cmp.compress


end
