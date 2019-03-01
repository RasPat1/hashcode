require './Photo.rb'

# Takes in a input file and returns
# a photo object for each photo

class PhotoIngester
  def parse(file_name)
    photos = []

    File.open(file_name, "r") do |f|
      photo_count = f.gets.to_i
      f.each_line do |line|

        line = line.split(' ')

        orientation = line[0]
        tag_count = line[1]
        tags = line[2..-1]
        photo = Photo.new(orientation, tags)
        photos << photo
      end
    end

    photos
  end
end