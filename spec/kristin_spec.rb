require 'spec_helper'
 
describe Kristin do 
  
  before(:all) do
    @one_page_pdf = file_path("one.pdf")
    @multi_page_pdf = file_path("multi.pdf")
    @no_pdf = file_path("image.png")
    @large_pdf = file_path("large.pdf")
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

    describe "options" do
      #TODO: Only convert file once for performance
      
      it "should process outline by default" do
        target = @target_path + "/large.html"
        Kristin::Converter.new(@large_pdf, target, { process_outline: false }).convert
        doc = Nokogiri::HTML(File.open(target))
        el = doc.css("#pdf-outline").first
        el.children.should_not be_empty
      end

      it "should be possible to disable outline" do
        target = @target_path + "/large.html"
        Kristin::Converter.new(@large_pdf, target, { process_outline: false }).convert
        doc = Nokogiri::HTML(File.open(target))
        el = doc.css("#pdf-outline").first
        el.children.first.text.strip.should be_empty
      end

      it "should be possible to specify first page" do
        target = @target_path + "/multi.html"
        Kristin::Converter.new(@multi_page_pdf, target, { first_page: 2 }).convert
        doc = Nokogiri::HTML(File.open(target))
        # Content only present on page 1
        content_from_page_1 = doc.search("//span").map(&:content).select {|c| c.include? "Geometric series"}
        # Content only present on page 2
        content_from_page_2 = doc.search("//span").map(&:content).select {|c| c.include? "Generating functions"}
        content_from_page_1.should be_empty
        content_from_page_2.should_not be_empty
      end

      it "should be possible to specify last page" do
        target = @target_path + "/multi.html"
        Kristin::Converter.new(@multi_page_pdf, target, { last_page: 9 }).convert
        doc = Nokogiri::HTML(File.open(target))
        # Content only present on page 1
        content_from_page_1 = doc.search("//span").map(&:content).select {|c| c.include? "Geometric series"}
        # Content only present on page 10
        content_from_page_10 = doc.search("//span").map(&:content).select {|c| c.include? "William Blake"}
        content_from_page_1.should_not be_empty
        content_from_page_10.should be_empty
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