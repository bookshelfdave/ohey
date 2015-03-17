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
    prefix = capture(:sources).value[0]
    capture(:fields).value.each do |c|
      qp = QueryPath.new("#{prefix}.#{c}")
      if qp.search(@@json)
        puts "#{qp} is a valid path"
      else
        puts "#{qp} is an invalid path"
      end
    end
    return "result"
  end
end


Citrus.load 'ohey'

Query::json = parsed
m = OHEY.parse 'select real, foo from cpu where'
puts m.value



# rule query
# (select fields:idlist from sources:idlist where) {
#
# puts "Selecting from "
# capture(:fields).value.each do |c|
# puts ">>> #{c}"
# end
#
# puts "Sources:"
# capture(:sources).value.each do |s|
# puts "Source: #{s}"
# end
# }
# end

