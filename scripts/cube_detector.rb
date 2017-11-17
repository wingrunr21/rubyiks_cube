require 'rubygems'
require 'bundler'
Bundler.require
require 'opencv'
require 'listen'

class CubeDetector
  attr_reader :window

  def initialize
    # load detector_path
    @window = OpenCV::GUI::Window.new("Rubyik's Cube")
    @listener = Listen.to(File.dirname(detector_path)) do |modified, _added, _removed|
      modified.each {|f| load f }
      run_detection
    end
    load detector_path
    run_detection
  end

  def run_detection
    image = OpenCV::CvMat.load(cube_image(1))
    window.show Detector.detect(image)
    # capture = OpenCV::CvCapture.open
    # while image = capture.query
    #   window.show Detector.detect(image)
    # end
  rescue => e
    puts e
  end

  def start
    @listener.start
    loop do
      sleep(1)
      break if OpenCV::GUI::wait_key(100)
    end
  end

  private

  def basedir
    @basedir ||= File.expand_path(File.join(__FILE__, '..'))
  end

  def detector_path
    @detector_path ||= File.join(basedir, 'cube_detector', 'detector.rb')
  end

  def cube_image(cube_num = 1)
    File.join(basedir, "cube#{cube_num}.jpg")
  end
end

c = CubeDetector.new
c.start