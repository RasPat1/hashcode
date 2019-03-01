require './SlideShow.rb'

class Transition
  attr_accessor :slide1, :slide2

  def initialize(slide1, slide2)
    @score = nil
    @slide1 = slide1
    @slide2 = slide2
  end

  def score
    if @score == nil
      @score = SlideShow.transition_score(@slide1, @slide2)
    end

    @score
  end

  def to_s
    "#{@slide1} => #{@slide2}"
  end
end