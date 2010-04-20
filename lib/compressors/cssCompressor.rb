class CssCompressor < Compressor
  def initialize
    super('css')
    @concatenate_input=true
  end

  def process(input_str,cmd=nil)
    puts YUI::CssCompressor.new.compress(input_str)
  end
 
end


