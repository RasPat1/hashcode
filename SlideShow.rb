require './Slide.rb'
require 'byebug'

class SlideShow
  attr_accessor :slides, :name

  def initialize(slides: [], name: "")
    @slides = slides
    @name = name
  end

  def add_slide(slide)
    @slides << slide
  end

  def score
    score = 0

    @slides.each_with_index do |slide, index|
      next if @slides[index + 1] == nil
      next_slide = @slides[index + 1]

      score += SlideShow.transition_score(slide, next_slide)
    end

    score
  end

  def self.transition_score(slide1, slide2)
    return 0 if slide1 == nil || slide2 == nil

    shared = 0
    only_in_one = 0
    only_in_two = 0

    # bad in practice
    # if slide1.tags.size < slide2.tags.size
    #   tmp = slide1
    #   slide1 = slide2
    #   slide2 = tmp
    # end

    slide1.tags.each do |tag_name, present|
      if slide2.tags.key?(tag_name)
        shared += 1
      else
        only_in_one += 1
      end
    end

    only_in_two = slide2.tags.size - shared
    [shared, only_in_one, only_in_two].min
  end

  def to_s
    result = []

    result << "Name: #{@name}" if @name.size > 0
    result << "Score: #{score}"

    @slides.each do |slide|
      result << slide.to_s
    end

    result.join("\n")
  end

end