class JsCompressor < Compressor
  

  def initialize
    super('js')
    @concatenate_input=true

  end

  def process(input_str,cmd=nil)
   unless @favourite_jscompressor == :closure
        compressor, method = YUI::JavaScriptCompressor.new( :munge => true), :compress
   else
        compressor, method = Closure::Compiler.new, :compiler
   end

   puts compressor.send(method, input_str)
  end
 
end


