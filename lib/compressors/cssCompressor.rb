class CssCompressor < Compressor
  def initialize
    super('css')
    
    # TODO: handle non-concatenated input
    @concatenate_input=true
    
  end

  def process(input_str,cmd=nil)

    fout= (@concatenate_input)? "#{$cm.target_dir}/css/all.min.css" : $cm.get_target_path(inputpath)

    File.open(fout,'w') do |f|
      f.write(YUI::CssCompressor.new.compress(input_str))
    end
    
    fout
  end

end


