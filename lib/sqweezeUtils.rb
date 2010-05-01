module SqweezeUtils
  
  # Mapping from extension to mime-type of all embeddable assets.
  EMBED_MIME_TYPES = {
      '.png' => 'image/png',
      '.jpg' => 'image/jpeg',
      '.jpeg' => 'image/jpeg',
      '.gif' => 'image/gif',
      '.tif' => 'image/tiff',
      '.tiff' => 'image/tiff',
      '.ttf' => 'font/truetype',
      '.otf' => 'font/opentype'
  } 

  
  
  def write_file(fbody,fpath)
    File.open(fpath,'w') do |f|
      f.write(fbody)
      f.close
    end
  end
  
  # Grab the mime-type of an asset, by filename.
  def mime_type(asset_path)
      EMBED_MIME_TYPES[File.extname(asset_path)]
  end
  

  # Remaps a file in the source directory to its compressed 
  # version in the target directory
  #
  # if the resource is an absolute URL fine, 
  # Otherwise, if the resource is a relative url in the source dir, try 
  # to map it to its compressed version in the target directory
  
  def remap_filepath(path)
    path=Pathname.new(path)
    parent_dir, path_basename = path.parent, path.basename
    is_absolute = URI.parse(path).absolute? 
    unless is_absolute
       find_file_in_targetdir( [parent_dir, path_basename].join('/'))
      else 
       path.to_s
    end
  end
  
  # Return the Base64-encoded contents of an asset on a single line.
  def encoded_contents(asset_path)
      data = open(asset_path, 'rb'){|f| f.read }
      Base64.encode64(data).gsub(/\n/, '')
  end  
  
  
   # Gets the byte weight of input strames, wether these are file paths or just strings

  def byteweight(path_or_string)
      path_or_string="" if path_or_string.nil?
  
      if File.exists?(path_or_string)
         File.size(path_or_string)
       else
         bweight=0
         path_or_string.each_byte{|b|bweight+=1}
         bweight
      end
  end
  
  def compression_percentage(before_bweight,after_bweight)
    sprintf('%.2f',after_bweight/before_bweight.to_f * 100)
  end
  

  # Find a file in the target directory
  # endpath is a string containing parent directory and file name 
  # (e.g imgs/separator.png)
  
  # TODO: rewrite this! (it sucks..)

  def find_file_in_targetdir(endpath)
    pattern=  [@cm.target_dir,"**/*#{File.extname(endpath)}"].join('/')
    #puts "searcing for files in #{pattern} ending with #{endpath}"
    Dir[pattern].find{|path| path =~ Regexp.new("#{endpath}$")}
  end
  
  
  
  
end