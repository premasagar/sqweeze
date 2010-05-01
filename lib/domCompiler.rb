class DOMCompiler
  include SqweezeUtils
  
  attr_reader :dom_documents
  
 
  def initialize
     #   @dom_extnames=['.html','.svg']
     @cm=ConfManager.instance
     #if @cm.link_assets_to and not @cm.link_assets_to.empty? 
     @dom_documents=@cm.get_conf(:dom_documents).to_a
  end
  
  def get_resource(path_or_url)
    f=open(remap_filepath(path_or_url))
    (f.is_a? File)? f.read : f 
  end
  
  def iterate_over(selector)  
   @dom_documents.each do |path|
    doc=Hpricot(open(path))
    if doc
      doc.search(selector).each do |element|
        
      #$log.debug..
      yield(element, doc)
      # save document 
      #write_file(doc.innerHTML, [@cm.target_dir, File.basename(path) ].join('/') )
      write_file(doc.innerHTML, path )
    end
    
      else
      $log.error("DOMCompiler cannot parse #{path}")  
    end
   end
  end
 
  def js_cdata(text,callback)
     ["\n<!--//--><![CDATA[//><!--", self.send(callback,text), "//--><!]]>\n"].join("\n")
    end
  def css_cdata(text,callback)
     ["/* <![CDATA[ */", self.send(callback,text), "/* ]]> */\n"].join("\n")
  end
 
end
