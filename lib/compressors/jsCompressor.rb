class JsCompressor < Compressor  

  def initialize
    super('js')
    @concatenate_input=true
  end


  def process(input_str,cmd=nil)
   if @cm.get_conf(:default_js_compressor) == :closure
        compressor, method = Closure::Compiler.new, :compiler
   else
        compressor, method = YUI::JavaScriptCompressor.new( :munge => true), :compress
   end
   fout= (@concatenate_input)? "#{@cm.target_dir}/javascripts.min.js" : @cm.get_target_path(inputpath)
   

   File.open(fout,'w') do |f|
      f.write(compressor.send( method, input_str))
   end

   # set the total byte-weight 
   @byteweight_after=byteweight(fout) 
   fout
  end
 
end


