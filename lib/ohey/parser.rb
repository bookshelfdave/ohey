require 'json'
require 'citrus'



class OheyQuery
  attr_accessor :source_paths
  attr_accessor :field_paths
  attr_accessor :data

  def initialize(data)
    @source_paths = []
    @field_paths = []
    @data = data
  end

  def eval_query
    @field_paths.each do |f|
      f.search(@data)
    end
  end
end

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
    return node
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
    oq = OheyQuery.new(@@json)
    prefix = captures(:source)[0]
    puts ">>>#{capture(:fields).value}<<<"
    capture(:fields).value.each do |c|
      qp = QueryPath.new("#{prefix}.#{c}")
      if qp.search(@@json)
        oq.field_paths << qp
      else
        raise "#{qp} is an invalid path"
      end
    end
    return oq.eval_query
  end
end

Citrus.require('ohey')
#Citrus.cache[path]
#Citrus.load 'parser'


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

