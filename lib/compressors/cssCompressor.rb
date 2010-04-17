class CssCompressor < Compressor
  def initialize
    super('css')
    @concatenate_input=true
  end

  def process(input,cmd=nil)

    File.open(input,'r+') do |f|
        yui=YUI::CssCompressor.new 
        puts yui.compress(f.read)
        f.close
    end
  end
 
end


