# Compresses stylesheets using the YUI compressor, creating three new files in the target directory:
# [<code>stylesheets.min.css</code>]
#                  compressed and concatenated stylesheets without embedded assets (suitable for all browsers).
#
# [<code>stylesheets.datauir.css</code>]
#                  compressed and concatenated stylesheets with assets embedded as data-uris (suitable for both Webkit and Geko based browser, and ie8). 
#
# [<code>stylesheets.mhtml.css</code>]
#                  compressed and concatenated stylesheets with assets embedded as data-uris (suitable for IE6 and IE7).
#
# *Note*: some of the methods used by this class are copied from Jash kenas's excellent {Jammit}[http://github.com/documentcloud/jammit/], an asset optimisation tool for Rails. 

class CssCompressor < Compressor
  
    # 32k maximum size for embeddable images (an IE8 limitation).
    MAX_IMAGE_SIZE = 32768

    # CSS asset-embedding regexes for URL rewriting.    
    EMBED_DETECTOR = /url\(['"]?([^\s)]+\.[a-z]+)(\?\d+)?['"]?\)/

    # MHTML file constants.
    MHTML_START = "/*\r\nContent-Type: multipart/related; boundary=\"SQWEEZED_ASSET\"\r\n\r\n"
    MHTML_SEPARATOR= "--SQWEEZED_ASSET\r\n"

  def initialize
    super('css')  
    
    @concatenate_input=true    
    @concatenated_file=nil   
    # This hash is populated while generating the data uris
    # in order to be reused later in the MHTML file 
    @assets={}
    # TODO fonts..
  end

  def process(input_str,cmd=nil)
    fout= (@concatenate_input)? "#{@cm.target_dir}/all.min.css" : @cm.get_target_path(inputpath)
    compressed_output=YUI::CssCompressor.new.compress(input_str)
    
    unless compressed_output.chomp.empty?
     write_file(compressed_output,"#{@cm.target_dir}/stylesheets.min.css") 
     
     # set the total byte-weight 
     @byteweight_after=byteweight(compressed_output) 
     embed_datauris( compressed_output )     
     embed_mhtml( compressed_output ) if @cm.get_conf(:mhtml_root) 
    end
    # this return is pointless
    fout
  end

  
  
  private 
  def mhtml_location(path)
    p=Pathname.new(path) 
    p.relative_path_from( Pathname.new(@cm.target_dir)) 
  end

  def embed_datauris(compressed_css)

    out=compressed_css.gsub(EMBED_DETECTOR) do |url|
      
      compressed_asset_path=remap_filepath($1)
      mime_t=mime_type(compressed_asset_path)
      if compressed_asset_path and File.exists?(compressed_asset_path) and File.size(compressed_asset_path) < MAX_IMAGE_SIZE and mime_t
         
         base64_asset=encoded_contents( compressed_asset_path ) 

         notify("file:#{compressed_asset_path}; mime-type: #{mime_type($1)}#",:debug)
         # label the image
         @assets[ compressed_asset_path ] = base64_asset 
         "url(\"data:#{mime_t};charset=utf-8;base64,#{base64_asset}\")"
       else
         "url(#{$1})"
      end
    end

    total_file_weight=@assets.keys.inject(0){|sum,path| sum+File.size(path)}

   notify("Converting #{ansi_bold(@assets.size)} images (#{ansi_bold(total_file_weight)} bytes) into base64".ljust(60),:info)
    write_file(out,"#{@cm.target_dir}/stylesheets.min.datauri.css")
  end


  def embed_mhtml(compressed_css)
    mhtml= MHTML_START
   
    @assets.each do |mhtml_loc,base64|
      mhtml << [MHTML_SEPARATOR, 
               "Content-location: #{mhtml_loc}\r\n", 
               "Content-Transfer-Encoding: base64\r\n",
               "Content-type: #{mime_type(mhtml_loc)} \r\n\r\n",
               "#{base64}\r\n"
      ].join('')
    end
    mhtml << "*/\r\n"
    mhtml << compressed_css.gsub(EMBED_DETECTOR) do |css|
      compressed_asset_path=remap_filepath($1)
      if compressed_asset_path
       "url(mhtml:#{@cm.get_conf(:mhtml_root).gsub(/\/$/,'')}/stylesheets.min.mhtml.css!#{compressed_asset_path})"
        else
        "url(#{$1})"
      end
    end
    
    write_file(mhtml,"#{@cm.target_dir}/stylesheets.min.mhtml.css")
  end

end

