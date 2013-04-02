require 'spec_helper'
 
describe Kristin do 
  
  before(:all) do
    @one_page_pdf = file_path("one.pdf")
    @multi_page_pdf = file_path("multi.pdf")
    @no_pdf = file_path("image.png")
    @target_path = "tmp/kristin"
  end

  before(:each) do
    FileUtils.mkdir_p @target_path
  end

  after(:each) do
    FileUtils.rm_rf @target_path
  end

  describe "#convert" do
    describe "with no options" do
      it "should raise error if source file does not exists" do
        c = Kristin::Converter.new("nonsense.pdf", "nonsense.html")
        lambda { c.convert }.should raise_error(IOError)
      end

      it "should convert a one page pdf to one html file" do
        target = @target_path + "/one.html"
        Kristin::Converter.new(@one_page_pdf, target).convert
        File.exists?(target).should == true
      end

      it "should convert a multi page pdf to one html file" do
        target = @target_path + "/multi.html"
        Kristin::Converter.new(@multi_page_pdf, target).convert
        File.exists?(target).should == true
      end

      it "should raise error if pdf is not a real pdf" do
        lambda { Kristin::Converter.new(@no_pdf, "nonsense.html").convert }.should raise_error(IOError)
      end

      it "should convert a pdf from an URL" do
        target = @target_path + "/from_url.html"
        Kristin::Converter.new("https://www.filepicker.io/api/file/vR0btUfRQiCF9ntRkW6Q", target).convert
        File.exists?(target).should == true
      end

      it "should raise an error if URL does not exist" do
        target = @target_path + "/from_url.html"
        lambda { Kristin::Converter.new("https://www.filepicker.io/api/file/donotexist.pdf", target).convert }.should raise_error(IOError)
      end

      it "should raise an error if URL file is not a real pdf" do
        target = @target_path + "/from_url.html"
        lambda { Kristin::Converter.new("https://www.filepicker.io/api/file/agxKeTfQSWKvMR4CDXMq", target).convert }.should raise_error(IOError)
      end
    end

    describe "with options" do
      it "should allow specifying first page" do
        target = @target_path + "/multi.html"
        Kristin::Converter.new(@one_page_pdf, target).convert
        File.exists?(target).should == true
      end
    end
  end

  describe ".convert" do
    it "should convert without options" do
      target = @target_path + "/one.html"
      Kristin.convert(@one_page_pdf, target)
      File.exists?(target).should == true
    end

    it "should convert with options" do
      pending
    end
  end
end