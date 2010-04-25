require 'conf/environment.rb'

config=<<EOF
bin_paths:
   - pngcrush: /usr/bin/pngcrush
   - jpegtran: /usr/bin/jpegtran
   - gifsicle: /usr/bin/gifsicle
EOF

File.open('agregado/.sqwidgetconfig.yml','w') do |f|
  f.write(config)
  f.close
end

cm=ConfManager.instance
cm.set_directories('agregado','agregado_build')

[ PngCompressor.new,
  GifCompressor.new,
  JpegCompressor.new,
  JsCompressor.new,
  CssCompressor.new
].each do |cmp| 

  puts "initialising.."
  cmp.compress



end
