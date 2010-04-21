class CssCompressor < Compressor

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

 
    # 32k maximum size for embeddable images (an IE8 limitation).
    MAX_IMAGE_SIZE = 32768

    # CSS asset-embedding regexes for URL rewriting.
    
    EMBED_DETECTOR = /url\(['"]?([^\s)]+\.[a-z]+)(\?\d+)?['"]?\)/
    EMBED_REPLACER = /url\(__EMBED__([^\s)]+)(\?\d+)?\)/  

    # MHTML file constants.
    MHTML_START = "/*\r\nContent-Type: multipart/related; boundary=\"SQWIDGET_MHTML_SEPARATOR\"\r\n\r\n"
    MHTML_SEPARATOR = "--SQWIDGET_MHTML_SEPARATOR\r\n"
    MHTML_END = "*/\r\n"



  def initialize
    super('css')  

    # TODO: handle non-concatenated input
    @concatenate_input=true    
    @embed_imgs=true
    @concatenated_file=nil
    
    # This is filled after the uridata are computer
    @assets={}

    # TODO fonts..
  end


  def process(input_str,cmd=nil)
    fout= (@concatenate_input)? "#{$cm.target_dir}/css/all.min.css" : $cm.get_target_path(inputpath)
    compressed_output=YUI::CssCompressor.new.compress(input_str)
    
    if @embed_imgs
      embed_datauris( compressed_output )   
      embed_mhtml( compressed_output ) 
      # note: 
      # this is inconsistent with sending out of a single output filepath
      # as in this case we are producing two output files rather than only one.      
    else
      write_file(compressed_output,fout) 
    end
    fout
  end

  
  private 
  
  def mhtml_location(path)
    p=Pathname.new(path)
    
    p.relative_path_from( Pathname.new($cm.target_dir)) 
  end


  def embed_datauris(compressed_css)
    out=compressed_css.gsub(EMBED_DETECTOR) do |url|
       compressed_asset_path=remap_filepath($1)

       base64_asset=encoded_contents( compressed_asset_path ) #unless File.size(compressed_asset_path > MAX_IMAGE_SIZE)

       # label the image using its parent-directory and its basename..
       
       @assets[ mhtml_location(compressed_asset_path)] = base64_asset 

       "url(\"data:#{mime_type($1)};charset=utf-8;base64,#{base64_asset}\")"
    end

    
    write_file(out,"#{$cm.target_dir}/all.min.datauri.css")
  end

  def embed_mhtml(compressed_css)
    mhtml="/*\nContent-Type: multipart/related; boundary=\"#{MHTML_SEPARATOR}\""
    @assets.each do |mhtml_loc,base64|

    mhtml <<"
#{MHTML_SEPARATOR}  
Content-location: #{ mhtml_loc  }
Content-Type: #{mime_type(mhtml_loc)}
Content-Transfer-Encoding:base64

#{base64}\n"
     
    end

    mhtml << "/*\n\n"
    mhtml << compressed_css.gsub(EMBED_DETECTOR) do |css|
       "url( mhtml:!#{ mhtml_location( remap_filepath( $1 ))} )"
    end
    
    write_file(mhtml,"#{$cm.target_dir}/all.min.mhtml.css")
  end

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
  

  # if the resource is an absulte URI or local filepath, fine..
  # Otherwise, if the resource is a relative url in the source dir, try 
  # to map it to its compressed version in the target directory

  def remap_filepath(path)
    
    path=Pathname.new(path)
    is_absolute = URI.parse(path).absolute? or path.absolute?
    unless is_absolute
       find_file_in_targetdir( [path.parent, path.basename].join('/'))
      else 
       path.to_s
    end
  end
  
  # Return the Base64-encoded contents of an asset on a single line.
  
  def encoded_contents(asset_path)
      data = File.open(asset_path, 'rb'){|f| f.read }
      Base64.encode64(data).gsub(/\n/, '')
  end

end

