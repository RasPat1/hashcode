require './PhotoIngester.rb'
require './ShowStarter.rb'

class App
  def initialize
    @output = nil
  end
  def call(file_names)
    File.open('./output.txt', 'w') do |output|
      @output = output
      overall_score = 0

      file_names.each do |file_name|
        photos = PhotoIngester.new.parse(file_name)

        # Let's run all of the known algs and take the best score and alg
        best_score = 0
        best_alg = ""

        print("Starting #{extract_name(file_name)}\n")

        ShowStarter::ALGS.each do |method|
          slideshow = ShowStarter.new(output).call(photos, method)

          score = slideshow.score
          print("#{method.to_s} -- #{score}")

          # print(slideshow.to_s)

          if score > best_score
            best_score = score
            best_alg = slideshow.name
          end
        end

        overall_score += best_score

        print("#{extract_name(file_name)} -- Score: #{best_score}")
        print("")
      end

      print("Overall Score: #{overall_score}")
    end
  end


  def multi_stage
  end

  def extract_name(file_name)
    file_name.split('.')[1][3..-1]
  end

  def print(msg)
    puts msg
    @output.write(msg + "\n")
  end
end

file_names = [
  "./a_example.txt",
  # "./b_lovely_landscapes.txt", # All Horizontal
  # "./c_memorable_moments.txt",
  # "./d_pet_pictures.txt",
  "./e_shiny_selfies.txt" # All Vertical
]

App.new.call(file_names)