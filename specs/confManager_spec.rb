require '../conf/environment.rb'
require 'sqw_spec_helper'

describe ConfManager do 
  context "Starting up" do
 

  after(:each) do
    delete_configfile
  end
  
  it "Should rise a missing file error if no .sqwidgetconfig is found in the project directory" do  
      lambda {ConfManager.new('test_dir')}.should raise_error(Errno::ENOENT)
  end
 
  it "Should rise an error if .sqwidgetconfig exists, but no bin_path is therein provided " do  
    File.open(SQW_CONF_FILE,'w') {|f| f.write("bin_paths:\n") }
    lambda {ConfManager.new('test_dir')}.should raise_error(RuntimeError)
  end
  
  it "Should expose itself as a global variable" do
    write_configfile
    ConfManager.new('test_dir')
    $cm.should be_a(ConfManager)
  end

  it "Should select the list of files provided by the user if the include: section of the .sqwidgetconfig is not empty" do
   extra_lines= ["include:","- js/**/*.js",'- color/**/*.png']
   write_configfile(extra_lines[0..1].join("\n"))
   ConfManager.new('test_dir').should have(8).files

   write_configfile(extra_lines.join("\n"))
   ConfManager.new('test_dir').should have(10).files

  end


  it "Should select all files in the project if the include: section of .sqwidgetconfig is left empty" do 
    write_configfile
    project_file_count= Dir['test_dir/**/*'].reject{|f| File.directory?(f)}.size
    ConfManager.new('test_dir').should have(project_file_count).files 

  end



  it "Should always exclude the files specified by the user in the .sqwidgetconfig exclude section " do
    write_configfile(["exclude:","- js/**/*.js"].join("\n"))
    project_file_count= Dir['test_dir/**/*'].reject{|f| File.directory?(f)}.size
    ConfManager.new('test_dir').should have(project_file_count - 8).files
  end

 end
end

