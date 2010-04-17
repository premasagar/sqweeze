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
     
     @bkupdir_path=$cm.mkpath("../#{File.basename($cm.source_dir)}.backup")
       make_backup_dir if not File.exists?(@bkupdir_path) 
  end
  attr_reader :bkupdir_path


  def make_backup_dir
     #TODO: Rubyfy this
     system("cp -r #{$cm.source_dir} #{@bkupdir_path}")
  end

  attr_accessor :default_bin
  
  # Set a candidate command to be invoked by the compressor
  def set_command(libname,command)


    raise "missing library #{libname}" unless  $cm.bin_paths.keys.include?(libname)
    @default_command=libname if @commands.empty?
    @commands[libname]=command
  end


  def filextension2regexpstr(ext=@input_file_extension)
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
  
  def process(inputpath,cmd=nil)      
    
     # execute pre-compression hook
     preprocess(inputpath) if self.methods.include?('before_compress') 
     
     puts cmd.gsub('%executable%', $cm.bin_paths[ @default_command ]).
         gsub('%input%',inputpath).
         gsub('%output%',inputpath)

  
     # execute pre-compression hook
     postprocess(inputpath) if self.methods.include?('after_compress')
  end


  def compress()

    @input_files=collect_filepaths
    @input_files=concatenate_files.to_a if @concatenate_input

    cmd= (@commands.empty?)? nil : @commands[ @default_command ]

    @input_files.each do |path|
      process(path,cmd)
    end  
  end



  def concatenate_files(output='/tmp/sqwidget_'+Time.now.to_i.to_s)
    newfile = ""

    @input_files.each do |fname|

        next if File.directory?(fname)

        f=File.open(fname,'r')
        newfile << f.read
        f.close

    end  

    newf=File.open(output,'w')
    newf.write(newfile)
    newf.close

    output
  end
end
