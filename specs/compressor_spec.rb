
require '../conf/environment'
require 'sqw_spec_helper'


describe PngCompressor do 

  before(:each) do
      write_configfile
      ConfManager.new('test_dir')
  end

  after(:each) do
      #TODO: Rubify this
      system('rm -rf test_dir.backup')
  end

  context "On startup" do 
    it "Should behave as an abstract class and raise an error if directly instanciated" do
       lambda {Compressor.new('whatever')}.should raise_error(RuntimeError) 
     end

     it "Should backup the project directory" do
        File.exists?(@c.bkupdir_path).should be_true
     end 
  end
end
