class Node
  attr_accessor :obj, :neighbors

  def initialize(obj)
    @obj = obj
    @neighbors = {}
  end

  def add_neighbor(node)
    # we could use a neighbor hash here?
    if !@neighbors.key?(node)
      @neighbors[node] = true
      node.neighbors[self] = true
    end
  end

  # Get a random value from the neighbor hash
  def random_neighbor
    # rand_num = (rand * neighbors.size).floor
    # rand_key = neighbors.keys[rand_num]
    # neighbors[rand_key]
    # rand_key
    @neighbors.first[0]
  end

end

class TagNode < Node
  ALL_NODES = {}
  attr_accessor :tag_name

  def initialize(tag_name)
    @tag_name = tag_name
    super
  end

  def self.find_or_create(tag_name)
    return ALL_NODES[tag_name] if ALL_NODES.key?(tag_name)
    node = TagNode.new(tag_name)
    ALL_NODES[tag_name] = node
  end

  def self.all
    ALL_NODES.values
  end

  def to_s
    "#{@tag_name}"
  end
end

class PhotoNode < Node
  def to_s
    debugger
    "Photo: #{@obj.orientation} -- Tags: #{@neighbors.keys.map(&:to_s).join(',')}"
  end
end

class Tag
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end