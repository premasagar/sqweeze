# Pseudo-abstract class inherited by all the other classes performing asset-compression operations

class Compressor
  include SqweezeUtils  

  #  Sets the file extensions that a compressor accepts 
  # 
  #  *Note*: As this class cannot be instanciated directly, this method is only used by subclasses. 
  def initialize(input_file_extensions)

     # Behave as a pseudo abstract class
     raise "Cannot instantiate #{self.class} directly" if self.class == Compressor
     
     @cm=ConfManager.instance
     @input_file_extensions=input_file_extensions
    

     # Get the project file list from the configuration manager
     @input_files=@cm.files

     # The commands used by this compressor,
     # listed in order of priority  
     
     @commands={}

     # Set the default shell command to use for this compressor.
     # issue: what's the point of calling this default command and not just default..
     @default_command=nil
     
     # whether or not concatenating the input files (it is the case of css and javascripts)      
     @concatenate_input=false
     
     # Store the overall byte weight of the assets, before compressions
     @byteweight_before = collect_filepaths.inject(0){|sum,f| sum+File.size(f)}
     
     #set later, after compression
     @byteweight_after = 0
  end


  attr_reader :input_file_extensions, #something here 
              :byteweight_before, 
              :byteweight_after
              
  
  # Sets the system command to be invoked by the compressor.
  # 
  # This raises a runtime error if the third party command cannot be found in the file system.  
  def set_command(libname,command)
    
    raise "missing library #{libname}" unless  @cm.get_conf(:bin_paths).keys.include?(libname)
    @default_command=libname if @commands.empty?
    @commands[libname]=command
  end

  # Turns a string or an array of strings containing several file extension names into regular expressions.

  def filextension2regexpstr(ext=@input_file_extensions)
     if @input_file_extensions.is_a?(Array) and @input_file_extensions.size > 1
        "(#{@input_file_extensions.collect{|ext|"\.#{ext}"}.join('|')})$"
       else
        "\.#{@input_file_extensions}$"      
    end
  end


  #  Collects the paths of files having the compressor extension name.
  def collect_filepaths
    exp_str = filextension2regexpstr  
    @cm.files.select{|path| path =~ Regexp.new(exp_str,true)  }
  end

  # Applies a system command to a list of file paths.
  #
  # This method is overridden by both CssCompressor and JsCompressor, as these two classes do not rely on 
  # command line executable but use ruby bindings to YUI and Google Closure.  

  def process(inputpath,cmd=nil)      
     output_path =@cm.get_target_path(inputpath)    
     
     cl= cmd.gsub('%executable%', @cm.get_conf(:bin_paths)[@default_command]).
                 gsub('%input%',inputpath).
                 gsub('%output%', output_path)
     system(cl)
     notify("run command #{cl}, pid=#{$?.pid} exitstatus=#{$?.exitstatus}", :debug)  
     output_path
  end


  # Iterates over the list of file paths matching the compressor extension/s and applies the process method to each of them. 
 
  def compress
    files=@input_files=collect_filepaths
    
    # This will consist of only an entry (the concatenated file body)
    # when compressing javascript or css files 

    files=[concatenate_files] if @concatenate_input
    cmd= (@commands.empty?)? nil : @commands[ @default_command ]

    files.each do |path|
      output_path=process(path,cmd)
      size_check(path,output_path) unless %w(.css .js).include?( File.extname(output_path))   
    end
    
    # summarise compression stats
    print_summary  unless ['.css','.js' ].include?(@input_file_extensions)
  end
  
  # Makes sure that the byteweight of a compressed file is not larger that the original one.  

  def size_check(input_path,output_path)
    before_size, after_size = byteweight(input_path), byteweight(output_path)
      # if the compressed file is bigger than the original one, copy the original in the target dir
    if after_size < before_size 
          notify("compressed #{input_path} to the #{ compression_percentage(before_size,after_size)}% of its original size  (from: #{before_size} to #{after_size} bytes ) ", :debug)
          @byteweight_after+=after_size
      else
          notify("output(#{after_size}) >= input(#{before_size}), keeping the original file #{input_path}",:debug)  
          FileUtils.cp(input_path,output_path)
          @byteweight_after+=before_size
      end
  end

  # Concatenates several files into a single string (used in both CSS and JS compression).
  
  def concatenate_files
    @input_files.collect{|f|File.open(f,'r').read}.join("\n")
  end
  
  def print_summary    
       notify("Compressed #{ansi_bold(@input_files.size)} #{@input_file_extensions.first.upcase} files".ljust(60) +
             "#{ansi_green(compression_percentage(@byteweight_before,@byteweight_after)+'%')} (was #{ansi_bold(@byteweight_before)}, is #{ansi_bold(@byteweight_after)} bytes now) \n", 
             :info) unless @byteweight_before == 0
  end

end
