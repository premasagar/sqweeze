class JsCompressor < Compressor
  

  def initialize
    super('js')
    @concatenate_input=true

  end

  def process(input,cmd=nil)

   unless @favourite_jscompressor == :closure
        compressor, method = YUI::JavaScriptCompressor.new( :munge => true), :compress
   else
        compressor, method = Closure::Compiler.new, :compiler
   end

    File.open(input,'r+') do |f|
        puts compressor.send(method, f.read)
        f.close
    end
  end
 
end


