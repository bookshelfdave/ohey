require 'json'
require 'citrus'

#file = open("data.json")
#json = file.read
#parsed = JSON.parse(json)


class QueryPath
  attr_accessor :qpath
  attr_accessor :segments

  def initialize(p)
    @qpath = p.strip
    @segments = @qpath.split(".")
  end


  def search(json)
    node = json
    @segments.each do |segment|
      if node.has_key?(segment)
        node = node[segment]
      else
        return false
      end
    end
    return true
  end

  def to_s
    @qpath
  end
end

module Query
  @@json = nil
  def self.json
    @@json
  end

  def self.json=(x)
    @@json = x
  end

  def value
    prefix = capture(:source).value
    puts ">>>#{prefix}<<<"
#    capture(:fields).value.each do |c|
#      qp = QueryPath.new("#{prefix}.#{c}")
#      if qp.search(@@json)
#        puts "#{qp} is a valid path"
#      else
#        puts "#{qp} is an invalid path"
#      end
#    end
    return "result"
  end
end


Citrus.load 'ohey'

