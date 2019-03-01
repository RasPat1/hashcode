class Photo
  attr_accessor :orientation, :tags

  H_CHAR = 'H'
  V_CHAR = 'V'

  ORIENTATIONS = [
    HORIZONTAL = :horizontal,
    VERTICAL = :vertical
  ]

  def initialize(orientation, tags = [])
    # @orientation = orientation
    @orientation = (orientation == H_CHAR) ? HORIZONTAL : VERTICAL
    @tags = {}
    tags.each do |tag_name|
      @tags[tag_name] = true
    end
  end

  def orientation_char
    case @orientation
    when HORIZONTAL
      H_CHAR
    when VERTICAL
      V_CHAR
    end
  end

  def to_s
    "#{orientation_char} => #{@tags.join(',')}"
  end
end