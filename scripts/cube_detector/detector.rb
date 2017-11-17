require 'matrix'

OpenCV::CvColor::Orange = OpenCV::CvColor.new(0, 128, 255) # BGR

class ComparativeContour
  attr_reader :contour, :bounding_rect

  def initialize(contour)
    @contour = contour
    @moment = OpenCV::CvMoments.new(contour)
    @bounding_rect = contour.bounding_rect
  end

  def center
    @center ||= moment.gravity_center
  end

  def height
    bounding_rect.height
  end

  def width
    bounding_rect.width
  end

  # compare our center with other's
  # we are comparing if our center lies within
  # other's height/width
  def <=>(other)
    cmp = compare_with_height(other) 
    cmp.zero? ? compare_with_width(other) : cmp
  end

  private

  attr_reader :moment

  def compare_with_height(other)
    range = other.bounding_rect.y..(other.bounding_rect.y+other.bounding_rect.height)
    compare_in_range(center.y, range)
  end

  def compare_with_width(other)
    range = other.bounding_rect.x..(other.bounding_rect.x+other.bounding_rect.width)
    compare_in_range(center.x, range)
  end

  def compare_in_range(target, range)
    case
    when range.include?(target) 
      0
    when target < range.begin
      -1
    when target > range.end
      1
    end
  end
end

class Detector
  CUBIE_AREA = (5000.0..400000.0).freeze
  COLOR_NAMES = [
    :White,
    :Red,
    :Green,
    :Blue,
    :Yellow,
    :Orange
  ]

  def self.colors
    @color_mat ||= begin
      mat = OpenCV::CvMat.new(1, 6) # 1 row of 6 colors
      mat[0] = OpenCV::CvColor.new 255, 255, 255 # white
      mat[1] = OpenCV::CvColor.new 126, 15, 24 # red
      mat[2] = OpenCV::CvColor.new 30, 175, 80 # green
      mat[3] = OpenCV::CvColor.new 2, 78, 125 # blue
      mat[4] = OpenCV::CvColor.new 198, 238, 80 # yellow
      mat[5] = OpenCV::CvColor.new 250, 95, 65 # orange

      mat.RGB2Lab
    end
  end

  def self.determine_color(img, contour)
    mask = img.clone.create_mask
    # Draw the contour interior filled in with white
    mask = mask.draw_contours(contour, OpenCV::CvColor::White, OpenCV::CvColor::White, 0, thickness: -1)

    # Get rid of non-white pixels
    mask = mask.erode(nil, 2)

    # Compute the average in the lab colorspace
    mean = img.avg(mask).to_ary

    distances = []
    6.times do |i|
      distances.push [euclidean_distance(colors[i], mean), i]
    end
    COLOR_NAMES[distances.min.last]
  end

  # based on http://www.pyimagesearch.com/2015/10/05/opencv-gamma-correction/
  def self.adjust_gamma(image, gamma = 1.0)
    inverse_gamma = 1.0 / gamma

    table = OpenCV::CvMat.new(1, 256, :cv8u, 1)
    (0..255).each do |i|
      table[0, i] = OpenCV::CvScalar.new(((i / 255.0)**inverse_gamma) * 255)
    end

    # apply gamma correction using the lookup table
    image.lut(table)
  end

  def self.approx_is_square(approx, side_vs_side_threshold = 0.6, angle_threshold = 20, rotate_threshold = 30)
    area = approx.contour_area.abs
    return false unless approx.size == 4 && approx.convexity? && CUBIE_AREA.include?(area) # TODO: make the area range dynamic on image size
    # return false unless approx.convexity? && (5000.0..400000.0).include?(area)
    # return false unless (50.0..400000.0).include?(area)
    # return true

    # corner order starts at lower left and goes clockwise
    vectors = approx.map.with_index do |point, i|
      next_point = approx[i - approx.size + 1]
      Vector[next_point.x - point.x, next_point.y - point.y]
    end
    cosins = vectors.map.with_index do |v, i|
      Math.cos(v.angle_with(vectors[i - 1])).abs
    end.sort

    return cosins.max < 0.3 # approx 90 degrees
  end

  def self.euclidean_distance(v1, v2)
    sum = 0
    v1.to_ary.zip(v2.to_ary).each do |a, b|
      component = (a - b)**2
      sum += component
    end
    Math.sqrt(sum)
  end

  # sort criteria:
  # each contour is made up of 4 points
  # the points go from upper left and ends on the lower left
  # each point has an x and y
  def self.sort_contours(contours)
    contours.sort_by(&:approx)
  end

  def self.detect(image)
    gamma_corrected = adjust_gamma(image, 1.5)
    # gamma_corrected = image
    # return gamma_corrected

    # convert to grayscale
    gray = gamma_corrected.BGR2GRAY
    lab = gamma_corrected.BGR2Lab
    # return lab

    # apply a small blur
    smooth = gray.smooth(OpenCV::CV_GAUSSIAN, 3, 3)
    # return smooth

    # Convert to outlines with canny algorithm
    canny = smooth.canny(30, 40)
    # return canny

    # Thicken lines
    # kernel = OpenCV::IplConvKernel.new(3, 3, 0, 0, :rect)
    kernel = OpenCV::IplConvKernel.new(3, 3, 0, 0, :rect, Array.new(3 * 3, 1))
    dilate = canny.dilate(kernel, 2)
    # return dilate

    # Find contours
    contour_options = {
      mode: OpenCV::CV_RETR_TREE,
      method: OpenCV::CV_CHAIN_APPROX_SIMPLE
    }
    contour = dilate.find_contours(contour_options)
    contoured_image = image
    cubies = []

    # breadth first interation of the tree
    while contour
      contour2 = contour

      while contour2
        perimeter = contour2.arc_length
        approx = contour2.approx_poly(method: :dp, accuracy: perimeter * 0.03, recursive: true)

        if approx_is_square(approx)
          color = determine_color(lab, approx)
          # draw_color = color == :Orange ? OpenCV::CvColor::Fuchsia : OpenCV::CvColor.const_get(color)
          draw_color = OpenCV::CvColor.const_get(color)
          contoured_image = contoured_image.draw_contours(contour2, draw_color, draw_color, 0, thickness: 3) 
          cubies << OpenStruct.new(
            approx: ComparativeContour.new(approx),
            contour: contour2,
            color: color
          )
        end

        contour2 = contour2.h_next
      end

      contour = contour.v_next
    end
    cubies = sort_contours(cubies)
    contoured_image
  end
end
