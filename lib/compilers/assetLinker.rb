class AssetLinker < DOMCompiler
  
  def compile
    iterate_over("link[@rel='stylesheet'], script[@src]") do |elm,doc|
      # Skip if the script has an absolute link
      next if elm.get_attribute('src') =~ /^http:\/\// 
      # Otherwise delete. 
      elm.parent.children.delete(elm)
    end    
         
    dom_documents.each do |path|
      target_path=remap_filepath(path) 

      # Append concatenated JavaScript file.

      doc = Hpricot(open(path))
      doc.search(@cm.get_conf(:append_scripts_to).to_s.downcase).append( "<script type='text/javascript' src='javascripts.min.js'></script>") 

      notify("#{ansi_bold(target_path)}:".ljust(60) + ansi_green("Appending Sylesheets"),:info)

stylesheets_html=<<EOF     

        <!--[if (!IE)|(gte IE 8)]><!-->
              <link href="stylesheets.min.datauri.css" media="screen" rel="stylesheet" type="text/css" />
         <!--<![endif]-->
         <!--[if lte IE 7]>
              <link href="stylesheets.min.mhtml.css" media="screen" rel="stylesheet" type="text/css" />
        <![endif]-->
EOF
     
      # Append concatenated CSS files, wrapping them within IE conditional tags
      doc.search('head').append(stylesheets_html)       
      notify("#{ansi_bold(target_path)}:".ljust(60)+ansi_green("Appending Sylesheets"),:info)
      write_file(doc.innerHTML, target_path)
    end 
  end
  
end
