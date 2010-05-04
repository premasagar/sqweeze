require 'sqw_spec_helper'

describe ConfManager do 
  context "Starting up" do
  
  before(:each) do
    @cm = ConfManager.instance
  end

  after(:each) do
    @cm=nil
    # clean up local configuration file
    %w( ENV['home'] test_dir ).each do |f|  
        f << "/.sqweeze.yml"
        FileUtils.rm(f) if File.exists?(f) 
    end
  end
  
  it "Should create a .sqweeze.yml file in the home directory" do  
      @cm.prepare('test_dir', 'test_dir_sqweeze', {:suppress_info => true} )
      File.exists?("#{ENV['HOME']}/.sqweeze.yml").should be_true
  end
 
  it "Should select the list of files provided by the user if the *include:* section of the .sqweeze.yml is not empty" do
   extra_lines= ["include:","- js/**/*.js",'- color/**/*.png']
   write_configfile(extra_lines[0..1].join("\n"))
   @cm.prepare('test_dir', 'test_dir_sqweeze', {:suppress_info => true} )
   @cm.should have(3).files
  
   write_configfile(extra_lines.join("\n"))

   @cm.prepare('test_dir', 'test_dir_sqweeze', {:suppress_info => true} )
   @cm.should have(5).files
  end
  it "Should select all files in the project if the include: section of .sqweeze.yml is left empty" do 
    project_file_count= Dir['test_dir/**/*'].reject{|f| File.directory?(f)}.size
    @cm.prepare('test_dir', 'test_dir_sqweeze',:suppress_info => true)
    @cm.should have(project_file_count).files 
  end
  it "Should always exclude the files specified by the user in the .sqweeze.yml exclude section " do
    write_configfile(["exclude:","- js/**/*.js"].join("\n"))
    project_file_count= Dir['test_dir/**/*'].reject{|f| File.directory?(f)}.size
    @cm.prepare('test_dir', 'test_dir_sqweeze',:suppress_info => true)
    @cm.should have(46).files
  end
 
  it "Should search *dom_documents* in the the target directory " do
    write_configfile("dom_documents: test_dir/**/*.php")
    @cm.prepare('test_dir', 'test_dir_sqweeze',:suppress_info => true)
    @cm.get_conf(:dom_documents).should include('test_dir_sqweeze/tpl/page.tpl.php')
  end 
 end 
end
