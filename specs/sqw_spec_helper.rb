     SQW_CONF_FILE='test_dir/.sqwidgetconfig.yml'
     SQW_FBODY=<<EOF
bin_paths:
   - pngcrush: /usr/bin/pngcrush
   - jpegtran: /usr/bin/jpegtran
   - gifsicle: /usr/bin/gifsicle
  #- cssembed: /home/and/installed/cssembed.jar
EOF

  def write_configfile(extra_lines='')
      fbody = SQW_FBODY + extra_lines
      f=File.open(SQW_CONF_FILE,'w')
      f.write( fbody)
      f.close
  end
  def delete_configfile
    File.delete(SQW_CONF_FILE) if File.exists?(SQW_CONF_FILE)
  end

