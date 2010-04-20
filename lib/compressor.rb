class Compressor
 
  def initialize(input_file_extensions, compression_identifier='sqw.min')

     #behave as a pseudo abstract class
     raise "Cannot instantiate #{self.class} directly" if self.class == Compressor
     
     @input_file_extensions=input_file_extensions
     @compression_identifier=compression_identifier


     # get the project file lists from the configuration manager
     @input_files=$cm.files


     # the commands used by this compressor,
     # listed in order of priority  

     @commands={}

     # set the default library/command to use for this compressor.
    

     @default_command=nil

     @concatenate_input=false
     
#     @bkupdir_path=$cm.mkpath("../#{File.basename($cm.source_dir)}.backup")
#     backup_dir if not File.exists?(@bkupdir_path) 

     # store the overall byte weight of the assets, before compressions
     
     @byteweight_before = collect_filepaths.inject(0){|sum,f| sum+File.size(f)}
     @byteweight_after = 0
  end


  attr_reader :bkupdir_path, 
              :input_files, 
              :input_file_extensions,
              :byteweight_before, 
              :byteweight_after


  def backup_dir
     FileUtils.cp_r($cm.source_dir, @bkupdir_path)
  end

  attr_accessor :default_bin
  
  # Set a candidate command to be invoked by the compressor
  def set_command(libname,command)

    raise "missing library #{libname}" unless  $cm.bin_paths.keys.include?(libname)
    @default_command=libname if @commands.empty?
    @commands[libname]=command
  end


  def filextension2regexpstr(ext=@input_file_extensions)
     if @input_file_extensions.is_a?(Array) and @input_file_extensions.size > 1
        "(#{@input_file_extensions.collect{|ext|"\.#{ext}"}.join('|')})$"
       else
         "\.#{@input_file_extensions}$"      
    end
  end


  def collect_filepaths
    exp_str = filextension2regexpstr  
    $cm.files.select{|path| path =~ Regexp.new(exp_str,true)  }
  end

  
#  def get_output_filepath(inputpath)
#     raise 'Warning.. file #{inputpath} does not exist' unless File.exists?(inputpath)
#     "#{File.dirname(inputpath)}/#{@output_filename }.#{@output_extension}"
#  end
  


  # Override this method to change the default compression behaviour


  def process(inputpath,cmd=nil)      
     output_path =$cm.get_target_path(inputpath)

     cl= cmd.gsub('%executable%', $cm.bin_paths[ @default_command ]).
                 gsub('%input%',inputpath).
                 gsub('%output%', output_path)
     system(cl)

     output_path
  end

  def compress
    files=@input_files=collect_filepaths
    files=[concatenate_files] if @concatenate_input

    cmd= (@commands.empty?)? nil : @commands[ @default_command ]

    files.each do |path|
      output_path=process(path,cmd)

      #  The default setting is that files are simply overwritten. However, when using string concatenation,
      #  the output file will be different the input ones..
      
      if File.exists?(path) 
        before_size=File.size(path)
        else
        # this is not a path, but a string 
        # concatenated from a list of files..

        before_size=0
        path.each_byte{|b| before_size+=1}
      end
      after_size=File.size(output_path)


      # if the compressed file is bigger than the original one, copy the original in the target dir
      if after_size < before_size 
          puts "byteweight before #{before_size} after: #{after_size}"
          @byteweight_after+=after_size
      else
          puts "AAARG!!! output(#{after_size}) > input(#{before_size}), rolling back to #{path} "  
          FileUtils.cp(path,output_path)
          @byteweight_after+=before_size
      end
      
      
    end  
  end

  def concatenate_files
    @input_files.collect{|f|File.open(f,'r').read}.join("\n")
  end

end
