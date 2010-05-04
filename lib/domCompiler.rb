# Pseudo-abstract inherited by all classes doing  dom manipulations
class DOMCompiler
  include SqweezeUtils
  attr_reader :dom_documents
  
  def initialize
     #   @dom_extnames=['.html','.svg']
     @cm=ConfManager.instance
     #if @cm.link_assets_to and not @cm.link_assets_to.empty? 
     @dom_documents=@cm.get_conf(:dom_documents).collect{|path| remap_filepath(path) }
  end
  # Retrieves a resource, being this either a URL or a file.
  def get_resource(path_or_url)
    target_path=remap_filepath(path_or_url)
    f=open(target_path)
    (f.is_a? File)? f.read : f 
  end

  # Iterates over a DOM element and allows to apply a custom block over it.
  def iterate_over(selector)  
   @dom_documents.each do |path|
   raise "File #{path} does not seem to exist" unless File.exists?(path)
   doc=Hpricot(open(path))

   if doc
      doc.search(selector).each do |element|
      yield(element, doc) 
      write_file(doc.innerHTML, path )
    end
      else
      notify("DOMCompiler cannot parse #{path}",
             :error
      )
    end
   end
  end
 
  # Wraps a string into CDATA escaped in order to be embedded into a <code><script></code> element.
  # [text] a text string
  # [callback] an instance method used to process the string (normally compile).
  def js_cdata(text,callback)
     ["\n<!--//--><![CDATA[//><!--", self.send(callback,text), "//--><!]]>\n"].join("\n")
  end
   
  # Wraps a string into CDATA escaped in order to be embedded into a <code><style></code> element.
  # [text] a text string
  # [callback] an instance method used to process the string (normally compile).  
  def css_cdata(text,callback)
     ["/* <![CDATA[ */", self.send(callback,text), "/* ]]> */\n"].join("\n")
  end
 
end
