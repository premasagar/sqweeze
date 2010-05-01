class JsDomCompiler < DOMCompiler
  
  def compile
    puts "compiling js"

    iterate_over('script[@src]') do |element, doc | 
      res_body=get_resource(element.get_attribute('src'))
  
      puts element.get_attribute('src')
      element.remove_attribute('src')

      # do the YUI/CLOSURE thing here
      element.innerHTML=js_cdata(res_body,:compress)
    end
  end
  
  
  def compress(fbody)
   unless @cm.default_js_compressor == :closure
       compressor, method = YUI::JavaScriptCompressor.new( :munge => true), :compress
     else
       compressor, method = Closure::Compiler.new, :compiler
   end
     compressor.send(method,fbody)
  end
  
 
end
