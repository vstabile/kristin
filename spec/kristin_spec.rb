require 'spec_helper'
require 'webrick'
include WEBrick

describe Kristin do 
  
  before(:all) do
    @one_page_pdf = file_path("one.pdf")
    @multi_page_pdf = file_path("multi.pdf")
    @no_pdf = file_path("image.png")
    @large_pdf = file_path("large.pdf")
    @target_path = "tmp/kristin"
    @target_file = @target_path + "/output.html"
    @fast_opts = { process_outline: false, vdpi: 1, hdpi: 1, first_page: 1, last_page: 1 }
    dir = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))  
    port = 50510
    @url = "http://#{Socket.gethostname}:#{port}"
    @t1 = Thread.new do
      @server = HTTPServer.new(:Port => port, :DocumentRoot => dir, :AccessLog => [], :Logger => WEBrick::Log::new("/dev/null", 7))  
      @server.start
    end
  end

  before(:each) do
    FileUtils.mkdir_p @target_path
  end

  after(:each) do
    FileUtils.rm_rf @target_path
  end

  after(:all) do
    @t1.exit
  end

  describe "#convert" do
    describe "with no options" do
      it "should raise error if source file does not exists" do
        c = Kristin::Converter.new("nonsense.pdf", "nonsense.html")
        lambda { c.convert }.should raise_error(IOError)
      end

      it "should convert a one page pdf to one html file" do
        Kristin::Converter.new(@one_page_pdf, @target_file, @fast_opts).convert
        File.exists?(@target_file).should == true
      end

      it "should convert a multi page pdf to one html file" do
        Kristin::Converter.new(@multi_page_pdf, @target_file, @fast_opts).convert
        File.exists?(@target_file).should == true
      end

      it "should raise error if pdf is not a real pdf" do
        lambda { Kristin::Converter.new(@no_pdf, "nonsense.html").convert }.should raise_error(IOError)
      end

      it "should convert a pdf from an URL" do
        Kristin::Converter.new("#{@url}/one.pdf", @target_file, @fast_opts).convert
        File.exists?(@target_file).should == true
      end

      it "should raise an error if URL does not exist" do
        lambda { Kristin::Converter.new("#{@url}/donotexist.pdf", @target_file).convert }.should raise_error(IOError)
      end

      it "should raise an error if URL file is not a real pdf" do
        lambda { Kristin::Converter.new("#{@url}/image.png", @target_file).convert }.should raise_error(IOError)
      end
    end

    describe "options" do
      it "should be possible to disable outline" do
        Kristin::Converter.new(@large_pdf, @target_file, { process_outline: false }).convert
        doc = Nokogiri::HTML(File.open(@target_file))
        el = doc.css("#pdf-outline").first
        el.children.first.text.strip.should be_empty
      end

      it "should be possible to specify first page" do
        Kristin::Converter.new(@multi_page_pdf, @target_file, { first_page: 2 }).convert
        doc = Nokogiri::HTML(File.open(@target_file))
        # Content only present on page 1
        content_from_page_1 = doc.search("//span").map(&:content).select {|c| c.include? "Geometric series"}
        # Content only present on page 2
        content_from_page_2 = doc.search("//span").map(&:content).select {|c| c.include? "Generating functions"}
        content_from_page_1.should be_empty
        content_from_page_2.should_not be_empty
      end

      it "should be possible to specify last page" do
        Kristin::Converter.new(@multi_page_pdf, @target_file, { last_page: 9 }).convert
        doc = Nokogiri::HTML(File.open(@target_file))
        # Content only present on page 1
        content_from_page_1 = doc.search("//span").map(&:content).select {|c| c.include? "Geometric series"}
        # Content only present on page 10
        content_from_page_10 = doc.search("//span").map(&:content).select {|c| c.include? "William Blake"}
        content_from_page_1.should_not be_empty
        content_from_page_10.should be_empty
      end

      it "should be possible to specify hdpi and vdpi" do
        Kristin::Converter.new(@one_page_pdf, @target_file, { hdpi: 1, vdpi: 1 }).convert
        doc = Nokogiri::HTML(File.open(@target_file))
        doc.at_css("img").attributes["src"].value.size.should == 538 # The size you get when hdpi and vdpi is 1 on @one_page_pdf
      end

      it "should be possible to specify zoom ratio" do
        Kristin::Converter.new(@one_page_pdf, @target_file, { zoom: 2.0 }).convert
        doc = Nokogiri::HTML(File.open(@target_file))
        doc.at_css(".pi").attributes["data-data"].value.should include("2.0")
      end
    end
  end

  describe ".convert" do
    it "should convert without options" do
      Kristin.convert(@one_page_pdf, @target_file)
      File.exists?(@target_file).should == true
    end

    it "should convert with options" do
      Kristin.convert(@one_page_pdf, @target_file, { hdpi: 1, vdpi: 1 })
      File.exists?(@target_file).should == true
    end
  end
end