class ConfManager  

  def initialize(source_dir,target_dir='build')
    @include_files=[]
    @exclude_files=[]
    @files=[]
    @bin_paths={}
    @source_dir=source_dir
    @target_dir=target_dir

    @cm=nil

    parse_conf
    create_target_dirtree

    # globalize self..
    $cm=self
  
  end 
  attr_reader :bin_paths,:files,:include_files,:exclude_files,
              :target_dir,:source_dir,:favourite_js_compressor
  
 
  # recreate the directory structure of the source directory into the target directory

  def create_target_dirtree
    get_dirs.each  do |dir|
      FileUtils.mkdir_p( get_target_path(dir)) 
    end
  end

  # remap a filepath from source to target directory

  def get_target_path(infile_path)
   infile_path.gsub( Regexp.new("^#{@source_dir}"), @target_dir)
  end


  def mkpath(pattern,dir=@source_dir)
    dir.to_a.push(pattern).join('/')
  end
  
  
  # parse the hidden configuration file 
  # to be found in the project directory

  def parse_conf
    
    configfile=mkpath('.sqwidgetconfig.yml')
    conf=YAML::load_file( configfile ) 


    raise "You should specify your system's executable paths "+
          "in the bin_paths: sectin of the .sqwidgetconfig.yml file" unless conf and conf.is_a?(Hash) and conf.has_key?('bin_paths') and conf['bin_paths'].to_a.size > 0

    # do not select commands if their file cannot be found on disk

    conf['bin_paths'].each{|h| @bin_paths[h.keys.first.to_sym]=h.values.first if File.exists?(h.values.first)}

    # favourite js compressor ( can either be :yui or :closure)
   
    @favourite_js_compressor = ( conf['favourite_js_compressor'] == :closure) ?  :closure : :yui
  
    @include_files,@exclude_files = conf['include'].to_a, conf['exclude'].to_a

    # unless the user defined file inclusion list is empty, select only the files specified by the user.
    # Otherwise consider all the files in the project directory as potentially compressible.


    @files = unless @include_files.empty?
               get_files(@include_files)
             else 
               get_files
    end

    # always exclude files explicitly blacklisted by the user 

    @files -= get_files(@exclude_files)
  end


  # get all the files matching an array of expanding 
  # patterns ( Any expanding patterns accepted by the Dir[] method is considered to be valid).

  def get_files(pathlist=['**/*'])
    pathlist.collect{|pattern| 

      Dir[ mkpath(pattern)  ].
           reject{|f|File.directory?(f) or not File.exists?(f)}

    }.flatten
  end
  
  def get_dirs
    Dir[mkpath('**/*')].select{|f| File.directory?(f)}
  end

end
