class Compressor
 
  def initialize(input_file_extensions, compression_identifier='sqw.min')

     # Behave as a pseudo abstract class
     raise "Cannot instantiate #{self.class} directly" if self.class == Compressor
     
     @cm=ConfManager.instance
     @input_file_extensions=input_file_extensions
     @compression_identifier=compression_identifier


     # Get the project file list from the configuration manager
     @input_files=@cm.files

     # The commands used by this compressor,
     # listed in order of priority  
     
     @commands={}

     # Set the default shell command to use for this compressor.
    
     @default_command=nil
     
     # whether or not concatenating the input files (it is the case of css and javascripts)      
     @concatenate_input=false
     
     # Store the overall byte weight of the assets, before compressions
     @byteweight_before = collect_filepaths.inject(0){|sum,f| sum+File.size(f)}
     
     #set later, after compression
     @byteweight_after = 0
  end


  attr_reader :input_files, 
              :input_file_extensions,
              :byteweight_before, 
              :byteweight_after
              
  
  # Set a candidate command to be invoked by the compressor
  def set_command(libname,command)

    raise "missing library #{libname}" unless  @cm.bin_paths.keys.include?(libname)
    @default_command=libname if @commands.empty?
    @commands[libname]=command
  end

  # turns the file extensions supplied by controller inherting classes into 
  # regular expressions

  def filextension2regexpstr(ext=@input_file_extensions)
     if @input_file_extensions.is_a?(Array) and @input_file_extensions.size > 1
        "(#{@input_file_extensions.collect{|ext|"\.#{ext}"}.join('|')})$"
       else
        "\.#{@input_file_extensions}$"      
    end
  end


  #  Get all the paths of the files in the source directory 
  # (filtered by the compressor file extension)
  
  def collect_filepaths
    exp_str = filextension2regexpstr  
    @cm.files.select{|path| path =~ Regexp.new(exp_str,true)  }
  end

  # Find a file into the target directory
  # endpath is a string containing parent directory and file name 
  # (e.g imgs/separator.png)

  def find_file_in_targetdir(endpath)
    pattern=  [@cm.target_dir,"**/*#{File.extname(endpath)}"].join('/')
    #puts "searcing for files in #{pattern} ending with #{endpath}"
    Dir[pattern].find{|path| path =~ Regexp.new("#{endpath}$")}
    
  end

  
  # Default compression method for media assets compressed through 
  # command line tools (that is GIF,PNG,JPG..). This is overridden 
  # by both the Javascript and CSS compressor subclasses 

  def process(inputpath,cmd=nil)      
     output_path =@cm.get_target_path(inputpath)
     
     cl= cmd.gsub('%executable%', @cm.bin_paths[ @default_command ]).
                 gsub('%input%',inputpath).
                 gsub('%output%', output_path)
     puts cl
     system(cl)

     output_path
  end

  def compress

    files=@input_files=collect_filepaths
    
    # This will consist of only an entry (the concatenated file body)
    # when compressing javascript or css files 

    files=[concatenate_files] if @concatenate_input

    cmd= (@commands.empty?)? nil : @commands[ @default_command ]

    files.each do |path|
      output_path=process(path,cmd)
      size_check(path,output_path) unless File.extname(output_path) == '.css' 
    end  
  end

  def size_check(input_path,output_path)
    before_size, after_size = byteweight(input_path), byteweight(output_path)
      # if the compressed file is bigger than the original one, copy the original in the target dir


    # TODO: implement a logger, so that one can log on stdoutput as well as on file

    if after_size < before_size 
          puts "byteweight before #{before_size} after: #{after_size}"
          @byteweight_after+=after_size
      else
          puts "AAARG!!! output(#{after_size}) >= input(#{before_size}), using the original file #{input_path} "  
          FileUtils.cp(input_path,output_path)
          @byteweight_after+=before_size
      end
  end



  def concatenate_files
    @input_files.collect{|f|File.open(f,'r').read}.join("\n")
  end

  # get the byte weight of input strames, wether these are file paths or just strings

  def byteweight(path_or_string)
      path_or_string="" if path_or_string.nil?
  
      if File.exists?(path_or_string)
         File.size(path_or_string)
       else
         bweight=0
         path_or_string.each_byte{|b|bweight+=1}
         bweight
      end
  end

end