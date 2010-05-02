# Main component for handling Sqweeze's file and command-line configuration parameters


class ConfManager 
  include SqweezeUtils
  include Singleton
  # Class constructor.  
  # 
  # As ConfManager implements the singleton pattern, it is actually instanciated only once. 
  # The same instance might be retrieved from different places by calling the method: 
  #
  # <code>ConfManager.instance()</code>
 
  def initialize  
    @conf_filename='.sqweeze.yml'
    @source_dir=nil
    @target_dir=nil
    @files=[]
    
    @conf={
      :suppress_info => false,
      :suppress_debug => true,
      :suppress_warn => false,
      :suppress_error => false,
      :bin_paths => {},
      :dom_documents => [],
      :include_files => [],
      :exclude_files => [],
      :compress_png  => true,
      :compress_jpeg => true,
      :compress_gif  => true,
      :compress_js  => true,
      :compress_css  => true,
      :append_scripts_to => :head,
      :default_js_compressor => :yui,
      :optimisation_strategy => :all_in_one
    }
  end   
  attr_reader :target_dir,:source_dir,
                :files,:conf_filename,:conf              
  
  
  # Setter method used to populate the <code>@conf</code> attribute with key value pairs.
  # 
  # *Note*: string keys are automatically converted to symbols.
  
  
  def set_conf(key,value);@conf[key.to_sym]=value;end
  
  # Getter method for retrieving configuration values. 
  
  def get_conf(key);@conf[key.to_sym];end

  # Sets the source directory, the target directory, and parse configuration files.
  #
  # [source]  the source directory
  #
  # [target] the target directory
  #
  # [override_conf] a Hash which may be used to override file-based configuration.

  def prepare(source,target=nil,override_conf={})
    
    @source_dir=source
    @target_dir=unless target
      "#{File.basename(source)}_sqweezed"            
    else 
      target 
    end
    copy_source

    write_globalconf
    # Parses the global configuration file in $HOME.
    parse_conf
    # Parses the local configuration file in source directory.
    local_conf=mkpath(@conf_filename)
    parse_conf(local_conf) if File.exists?(local_conf)
   
    # CLI/Overrides of the values already set in config files. 
    override_conf.each{|k,v| set_conf(k, v)} unless override_conf.empty?

    # Creates the list of the files in the project directory.
    
    list_files

  end
 
  # Copies the source into the target directory.
  def copy_source
    FileUtils.cp_r(@source_dir,@target_dir)
    # avoid nesting into each other multiple copies of the same directory
    nested_dir=[@target_dir,File.basename(@source_dir)].join('/')
    FileUtils.rm_r(nested_dir) if File.directory?(nested_dir)
  end

  # Remaps a filepath from the source to the target directory.
  #
  #  TODO:check if this works with relative paths (i.e. <code>../imgs/bar.png</code>)
  
  def get_target_path(infile_path)
   infile_path.gsub( Regexp.new("^#{@source_dir}"), @target_dir)
  end

 
  # Generates a file pattern suitable to be expanded by ruby's {Dir[]}[http://ruby-doc.org/core/classes/Dir.html] method.

  def mkpath(pattern,dir=@source_dir) 
    dir.to_a.push(pattern).join('/')
  end
  
  # Defines a global <code>.sqweeze.yml</code> file  and places it in the user's home directory.
  #
  # The golobal config files sets the default path of the image compression binaries 
  # (see @conf[:bin_paths]).

  def write_globalconf
    unless File.exists?("#{ENV['HOME']}/#{@conf_filename}") 
         File.open("#{ENV['HOME']}/#{@conf_filename}",'w') do |f|
           f.write("bin_paths:
   - pngcrush: /usr/bin/pngcrush
   - jpegtran: /usr/bin/jpegtran
   - gifsicle: /usr/bin/gifsicle
           ")
           f.close
         end
    end
  end
    
  # Parses configuration files and sets user-defined file inclusion/exlusion patterns.
  
  def parse_conf(configfile="#{ENV['HOME']}/#{@conf_filename}")
    notify("Parsing configuration file: #{configfile}",:debug) 
    conf=YAML::load_file( configfile ) 
     
    bin_paths={}
    # do not select commands if their path cannot be found on disk      
    conf['bin_paths'].each do |h| 
        if File.exists?(h.values.first)
          bin_paths[h.keys.first.to_sym] = h.values.first 
        else
          $log.warn("Command #{h.keys.first} not found in #{h.values.first}")
        end
    end
    set_conf(:bin_paths,bin_paths) unless bin_paths.empty?
    
    # Expand the dom document pattern excluding the files located in the source directory.     
    if conf['dom_documents']
      
      domdoc_file_patterns = Dir[conf['dom_documents']].collect{|f| f.gsub(Regexp.new("^#{@source_dir}"),@target_dir)}
      set_conf(:dom_documents, domdoc_file_patterns)
    end
    
    # Sets the favourite js compressor ( can either be :yui or :closure, defaults on YUI)
    compressor = ( conf['default_js_compressor'] == :closure) ?  :closure : :yui
    set_conf(:default_js_compressor, compressor)
    
    # others..
    %w(include exclude).each {|k| set_conf(k, conf[k].to_a)}
    %w(optimisation_strategy append_scripts_to 
      suppress_messagess suppress_debug suppress_warnings).each{|k| set_conf(k,conf[k]) if conf[k]}
  end
 
  # Explodes the inclusion/exclusion patterns provided by the user into a list, and populates the @files attribute.   
 
  def list_files
    # unless the user defined file inclusion list is empty, select only the files specified by the user.
    # Otherwise consider all the files in the project directory as potentially compressible.

    @files = unless get_conf(:include).empty?
               files=get_files( get_conf(:include));$log.debug("Including #{files.size} file/s from user list")
               files
             else 
               get_files
    end
 
    # always exclude files explicitly blacklisted by the use 
    exclude_files=get_files(get_conf(:exclude))
    
    
    notify("Excluding #{exclude_files.size} file/s from user list", :debug)
    @files -= exclude_files
    notify("#{@files.size} file/s found", :info)
  end

  # Get all the files matching an array of patterns 
  #
  # (Any file expansion patterns accepted ruby's Dir[] method can be used).

  def get_files(pathlist=['**/*'])
    pathlist.collect{|pattern|
 
      Dir[ mkpath(pattern)  ].
           reject{|f|File.directory?(f) or not File.exists?(f)}
    }.flatten
  end

 end
