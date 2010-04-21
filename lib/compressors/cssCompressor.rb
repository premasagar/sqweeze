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
    #EMBEDDABLE = /[\A\/]embed\//
    #EMBED_REPLACER = /url\(__EMBED__([^\s)]+)(\?\d+)?\)/  
  
  def initialize
    super('css')  

    # TODO: handle non-concatenated input
    @concatenate_input=true    
    @embed_imgs=true
    @concatenated_file=nil
    # TODO fonts..
  end


  def process(input_str,cmd=nil)
    fout= (@concatenate_input)? "#{$cm.target_dir}/css/all.min.css" : $cm.get_target_path(inputpath)
    compressed_output=YUI::CssCompressor.new.compress(input_str)
    
    if @embed_imgs
      puts "we should embed images here.."
      embed_datauris( compressed_output )   
      #embed_mhtml( compressed_output ) 
      # note: 
      # this is inconsistent with sending out of a single output filepath
      # as in this case we are producing two output files rather than only one.      
    else
      write_file(compressed_output,fout) 
    end
    fout
  end

  
  private 



  def embed_datauris(compressed_css)
    compressed_css.gsub!(EMBED_DETECTOR) do |url|
       "url(\"data:#{mime_type($1)};charset=utf-8;base64,#{encoded_contents($1)}\")"
    end  
    compressed_css
    write_file(compressed_css,"#{$cm.target_dir}/all.min-datauri.css")
  end

  def embed_into_mhtml  
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
      data = File.open(remap_filepath(asset_path), 'rb'){|f| f.read }
      Base64.encode64(data).gsub(/\n/, '')
  end


end


