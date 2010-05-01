class AssetLinker < DOMCompiler
  
  def compile
    iterate_over("link[@rel='stylesheet'], script[@src]") do |elm,doc|
      # Skip if the script has an absolute link
      next if elm.get_attribute('src') =~ /^http:\/\// 
      # Otherwise delete. 
      elm.parent.children.delete(elm)
    end    
    dom_documents.each do |path|
      # Append concatenated JavaScript file.
      doc = Hpricot(open(path))
      doc.search(@cm.get_conf(:append_scripts_to).to_s.downcase).append( "<script type='text/javascript' src='javascripts.min.js'></script>") 
      
stylesheets_html=<<EOF     
      <!--[if lte IE 8]>
          <link href="stylesheets.min.mhtml.css" rel="stylesheet" />
      <![endif]-->
      <!--[if IE 8]>
          <link href="stylesheets.min.datauri.css" rel="stylesheet" />
      <![endif]-->
      <!--[if !IE]>
         <link href="stylesheets.min.datauri.css" rel="stylesheet" />
      <![endif]-->
EOF
  
      # Append ie conditional tags
      doc.search('head').append(stylesheets_html)      
      write_file(doc.innerHTML,path)
    end
  end
  
end
