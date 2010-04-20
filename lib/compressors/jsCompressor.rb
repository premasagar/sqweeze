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


   fout= (@concatenate_input)? "#{$cm.target_dir}/js/all.min.js" : $cm.get_target_path(inputpath)

   File.open(fout,'w') do |f|
      f.write(compressor.send( method, input_str))
   end
    
   fout
  end
 
end


