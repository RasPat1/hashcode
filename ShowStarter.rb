require './SlideShow.rb'
require './Transition.rb'
require 'byebug'

class ShowStarter

  ALGS = [
    BASIC = :basic,
    REVERSE = :reverse,
    RANDOM = :random,
    BRUTE = :brute,
    GREEDY = :greedy,
    GREEDY_CYCLE = :greedy_cycle,
    GREEDY_CYCLE_GLUE = :greedy_cycle_glue,
    TAG_BUCKET = :tag_bucket
  ]

  def initialize(output_file)
    @output_file = output_file
  end

  # First alg puts each photo on a slide
  def call(photos, method)
    start = Time.now
    return nil unless ALGS.include?(method)
    slideshow = self.send(method.to_s, photos)
    stop = Time.now

    msg = "#{slideshow.name}: #{stop - start}s"
    @output_file.write(msg + "\n")
    puts msg

    slideshow
  end

  def basic(photos, name: "Basic")
    slideshow = SlideShow.new(name: name)

    photos.each do |photo|
      slide = Slide.new([photo])
      slideshow.add_slide(slide)
    end

    slideshow
  end

  def reverse(photos, name: "Reverse Basic")
    slideshow = SlideShow.new(name: name)

    photos.reverse.each do |photo|
      slide = Slide.new([photo])
      slideshow.add_slide(slide)
    end

    slideshow
  end

  # A brute force. approach where we try every ordering
  # This is an n! # of orderings
  # Um this is optimal lol, always, if it completes
  # this excludes the idea of vertical pairs
  def brute(photos, name: "Brute Force")
    all_permutations = all_perms(photos, [], [])
    max_score = -1
    best_show = nil

    all_permutations.each do |perm|
      slideshow = SlideShow.new(name: name)

      perm.each do |photo|
        slide = Slide.new([photo])
        slideshow.add_slide(slide)
      end

      score = slideshow.score

      if score > max_score
        max_score = score
        best_show = slideshow
      end
    end

    best_show
  end

  # Randomized alg that does n trials
  def random(photos, name: "Random")
    max_score = -1
    best_show = nil

    trials = 10
    trials.times do |trial|
      slideshow = SlideShow.new(name: name)
      photos = photos.shuffle
      photos.each do |photo|
        slide = Slide.new([photo])
        slideshow.add_slide(slide)
      end

      score = slideshow.score

      if score > max_score
        max_score = score
        best_show = slideshow
      end
    end

    best_show
  end


## Real Version
## What are some heuristics that make sense
# Tsin we are looking for the min of these three values we can optimize when we ckeep them in balance
# If a photo has 100 tags and another photo has 1 tag the min by definition is 1 tag...
# So as a rule we want to put slides with similar tag counts near each otehr
# So simplest heiuristis is let's sort by tag count
# and see how we do

  def sort_by_tag_count
  end

  # this is also a bad heuristic
  def sort_by_tag_count_with_random_buckets
  end

# The max score is half the number of tags
# This means half of tags of a are its own
# half of them are shared with b
# and half of b's tags are its own
# and we want a and b to have the same tag count

# For each tag in teh set
# LEt's find all photos with that tag
# Now at a minimum only groups that have tags in common shoudl be next to each other
# Even though we may want to give a vertain transition a 0 score so that we can buff a score elsewhere
# HmMMMMMHMHMHMMHMH

# we can be greedy as well. Let's get all n^s transition scores and select the highest value transition available
# then continue
  # I mean it performs way better than the randoms but it's not performant
  # Ends up being like n^2logn^2 or liek worse
  # This is 5x better than random
  # But doesn't finish on the larger files
  def greedy(photos, name: "Greedy")
    return SlideShow.new(name: name) if photos.size > 10
    slides = []
    photos.each do |photo|
      slides << Slide.new([photo])
    end
    # prob best to use a max heap here
    pairs = []

    slides.each do |slide1|
      slides.each do |slide2|
        next if slide1 == slide2
        pairs << Transition.new(slide1, slide2)
      end
    end

    # pairs = sort(pairs)
    pairs = pairs.sort { |pair| -1 * pair.score }
    slides_included = {}
    # The funny thing here is that we select a set of pairs and we ignore half
    # the transitions in between the selected pairs
    slideshow = SlideShow.new(name: name)
    slide_included = {}

    pairs.each do |pair|
      # skip if we already included the slide
      next if slide_included[pair.slide1]
      next if slide_included[pair.slide2]
      slideshow.add_slide(pair.slide1)
      slideshow.add_slide(pair.slide2)
      slide_included[pair.slide1] = true
      slide_included[pair.slide2] = true
    end

    slides.each do |slide|
      slideshow.add_slide(slide) unless slide_included[slide]
    end

    slideshow
  end

  # It seems the expensive way of the greedy version is to make all pairs
  # and score those. That's pretty tricky.  But let's think. of it a different way
  # Let's start by selecting a single slide. Then find the photo with the highest transitino value to come ofter that. Since every photo. must be followed by a photo
  # Let's pick a photo. Find its greedy successor, and then continue this way until we've chosen a transition between each set of photos
  # THen we can cut the min trnsition and say that is the start/end
  # This is still nsa right since each photo looks at all remaining photos
  # but it is practically much better since we aren't sorting
  # and the number of pairs calculated is half the size of the previous greedy
  # also it considers more edges so that's good
  # This is 3x better than greedy
  def greedy_cycle(photos, name: "Greedy Cycle")
    return SlideShow.new(name: name) if photos.size > 10000
    slides = []

    photos.each do |photo|
      slides << Slide.new([photo])
    end

    curr_slide = slides.shift
    cycle = [curr_slide]

    # Then we don't search the full region for the really juicy values
    # how abotu we put in a shortcut heurisitc that syas hey if we've foudn apretty godo bmatch already so let's stop searching
    # And wehn teh list is long we can short cut relatively low
    # and when teh list is longer we can short cut later

    threshold = 4 # idk made this starting param up

    while slides.size > 0
      best_score = -1
      best_slide = nil
      best_slide_index = -1

      slides.each_with_index do |next_slide, index|
        score = SlideShow.transition_score(curr_slide, next_slide)
        if score > best_score
          best_score = score
          best_slide = next_slide
          best_slide_index = index
        end
        # if best_score >= threshold
        #   break
        # end
      end

      # we know the best next slide now!
      cycle << best_slide
      curr_slide = best_slide
      slides.delete_at(best_slide_index)
      # update threshold
      # lol on unweighted average
      # threshold = (threshold + best_score) / 2
    end

    SlideShow.new(slides: cycle, name: name)
  end

  # OPtimize run time of greedy cycle
  # def greedy_cycle(photos, name: "Greedy Cycle Time Optimized")
  #   # WE can trade off runtime for complexity maybe?
  # end


  # We can break this into a series of chunks
  # maybe a list of 80k hsodul be 80 lists of 1k each that we put together
  # this can help us since we do linear chunking aka 80 * 1k^2 is way better than 80^2
  # The downside there is we have 80 pieces taht we want to glue back together which is fine

  def greedy_cycle_glue(photos, name: "Greedy Glue")
    slides = []

    chunk_size = 50
    chunk_count = (photos.size / chunk_size).ceil
    chunk_count.times do |chunk_num|
      low = chunk_num * chunk_size
      high = low + chunk_size
      chunk = photos[low..high]
      slideshow = greedy_cycle(chunk)
      slides += slideshow.slides
    end

    SlideShow.new(slides: slides, name: name)
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

  # Okay making the glue idea was fun
  # But time to go to the real crux of this problem
  # Let's bucket tags
  # Since we're comign out with scores of

  # 1.1M was max score we saw on scoreboard
  # for a-e which has a count of 80K + 1K + 90k + 80k = 251k images
  # so looks like there is an transition score of 4.
  # We're currently hitting an avg transtion score of like 0.1 on b and 1.6 on c


  def tag_bucket(photos, name: "Tag Bucket")
    # We're not sure how many unique tags there are in each sectionm
    # but we can find out in O(t) time
    # we could also specialize approaches for each type of input

    # do we try to compose ideal slides based on tags?
    all_tags = {}
    slides = []

    # O(n)
    photos.each do |photo|
      slides << Slide.new([photo])
    end

    # O(t), where t is number of tags
    # O(n*t) space?
    slides.each do |slide|
      slide.tags.each do |tag_name, present|
        all_tags[tag_name] = [] unless all_tags.key?(tag_name)
        all_tags[tag_name] << slide
      end
    end

    slideshow = SlideShow.new(name: name)
    added_slides = {}

    all_tags.each do |tag_name, tag_bucket|
      available_slides = []
      tag_bucket.each do |tagged_slide|
        available_slides << tagged_slide unless added_slides.key?(tagged_slide)
        # slideshow.add_slide(tagged_slide)
        added_slides[tagged_slide] = true
      end
      next if available_slides.size == 0

      tmp_photos = []
      available_slides.each do |slide|
        tmp_photos += slide.photos
      end


      # Use an alternate strategy inside the bucket
      if available_slides.size < 10000
        greedy_slideshow = greedy_cycle(tmp_photos)
        greedy_slideshow.slides.each do |slide|
          slideshow.add_slide(slide)
        end
      else
        greedy_cycle_glue = greedy_cycle_glue(tmp_photos)
        greedy_cycle_glue.slides.each do |slide|
          slideshow.add_slide(slide)
        end
        puts "TRIGGERED THE GLUE"
      end

    end


    slideshow
  end


  # We could try a gradient ascent version of the random?
  # Where we keep some high scoring part and shuffle the rest right
  # that actually feels pretty cool

  # We could possibly just use machine learning here and say okay here's your feedback function. Just solve the problem

  # WE coudl try doing it piecemeal. find the highest value transition and than the second highest transition and stitch tose together

  # We could try each slide with each other slide and find all the pairs of transitions. Then we need to select a set of transitions that can cover our entire set

  # The only additional complexity is taht photos can be in vertical and have 2 photos per slide. This is an interesting problem


  def all_perms(photos, prefix, all_perms)
    # if photos.size == prefix.size
    #   all_perms << prefix.clone
    # end
    photos.each do |photo|
      next if prefix.include?(photo)
      p_clone = prefix.clone
      p_clone << photo

      all_perms(photos, p_clone, all_perms)
    end

    all_perms << prefix.clone if prefix.size == photos.size

    all_perms
  end
end