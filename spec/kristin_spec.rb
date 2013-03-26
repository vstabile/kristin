require 'spec_helper'
 
describe Kristin do 
  
  before(:all) do
    @one_page_pdf = file_path("one.pdf")
    @multi_page_pdf = file_path("multi.pdf")
    @target_path = "/tmp/kristin"
  end

  after(:all) do
    FileUtils.rm_rf @target_path
  end

  describe ".convert" do
    it "should raise error if source file does not exists" do
      lambda { Kristin.convert("nonsense.pdf", "nonsense.html") }.should raise_error(IOError)
    end
  end
end