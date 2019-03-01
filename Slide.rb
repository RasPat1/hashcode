class Slide
  attr_accessor :tags, :photos

  def initialize(photos)
    @photos = photos
    @tags = {}
    @tags = photos[0].tags

    if photos.size > 1
      photos.each_with_index do |photo, index|
        next if index == 0
        @tags = @tags.merge(photos[1].tags)
      end
    end
  end

  def to_s
    "#{@photos.join(',')}"
  end
end