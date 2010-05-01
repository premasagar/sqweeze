class CssDomCompiler < DOMCompiler
  
  def compile
    iterate_over('link[@rel="stylesheet"]') do |elm, doc|
      next unless elm.has_attribute?('href') and not elm.get_attribute('href').nil?
      
      fbody=get_resource(elm.get_attribute('href'))
      
      # this is a bit convoluted, but it seems to be the right way of doing it
      elm.parent.children.delete(elm)
      
      style_html = "<style type=\"text/css\">\n" + css_cdata(fbody,:compress) + '</style>'
      doc.search('head').append(style_html)
 
    end
  end

  
  def compress(fbody)
    YUI::CssCompressor.new.compress(fbody)
  end
  
end
