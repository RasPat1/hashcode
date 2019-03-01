require './PhotoIngester.rb'
require './ShowStarter.rb'

class App
  def call(file_names)
    File.open('./output.txt', 'w') do |output|
      overall_score = 0
      file_names.each do |file_name|
        photos = PhotoIngester.new.parse(file_name)

        # Let's run all of the known algs and take the best score and alg
        best_score = 0
        best_alg = ""

        msg = "Starting #{extract_name(file_name)}\n"
        output.write(msg)
        puts msg

        ShowStarter::ALGS.each do |method|
          slideshow = ShowStarter.new(output).call(photos, method)

          score = slideshow.score
          puts "#{method.to_s} -- #{score}"
          if score > best_score
            best_score = score
            best_alg = slideshow.name
          end
        end

        overall_score += best_score

        print(output, "#{extract_name(file_name)} -- Score: #{best_score}")
        print(output, "")
      end

      msg = "Overall Score: #{overall_score}"
      output.write(msg + "\n")
    end
  end

  def extract_name(file_name)
    file_name.split('.')[1][3..-1]
  end

  def print(output, msg)
    puts msg
    output.write(msg + "\n")
  end
end

file_names = [
  "./a_example.txt",
  "./b_lovely_landscapes.txt", # 7356 from glue @ 80s, #36930 @ 1.7s from tag bucket
  "./c_memorable_moments.txt", # 563 from greedy, 1691 from greedy cycle, 841 from tag_bucket
  "./d_pet_pictures.txt", # 203436 from tag bucket @ 0.75s
  "./e_shiny_selfies.txt" # 135248 from tag bucket @ 1.2s
]


App.new.call(file_names)