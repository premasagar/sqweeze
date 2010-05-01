     SQW_CONF_FILE='test_dir/.sqweeze.yml'
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
    FileUtils.rm_r(SQW_CONF_FILE) if File.exists?(SQW_CONF_FILE)
  end

  def wget_webpage(url,dir_prefix)
    domain=URI.parse(url).host
    system("wget --no-parent --timestamping --convert-links --page-requisites --no-directories --no-host-directories -erobots=off --quiet --directory-prefix=#{dir_prefix} #{url}")           
  end
