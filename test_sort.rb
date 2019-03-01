class FakeScore
  attr_accessor :score
  def initialize(score)
    @score = score
  end

  def to_s
    @score
  end
end

def sort(arr)
  arr.each_with_index do |el1, i|
    arr.each_with_index do |el2, j|
      next if j < i
      if arr[j].score < arr[i].score
        tmp = arr[i]
        arr[i] = arr[j]
        arr[j] = tmp
      end
    end
  end

  arr
end

arr = []
10.times do |index|
  arr << FakeScore.new((rand * 100).floor)
end
puts arr.map{|el| el.to_s}.join(',')
sort(arr)
puts arr.map{|el| el.to_s}.join(',')