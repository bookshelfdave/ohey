require 'json'
require 'citrus'
require 'jsonpath'

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

  def search_from_root(json)
    search(json, @segments)
  end



#1) Iterate over the source, which must be an array or a hash
#2) Apply where clauses
#3) Extract fields


# general algorithm
# 1) iterate over each segment
# 2) if the segment exists and is scalar, continue
# 3) if the segment exists and is an object, iterate
#    over each value in the current object
#    recurse
# 4) if the segment exists and is an array, iterate
#    over each value in the array
#    recurse

# $key is in kernel.modules
# select $key, $object.size from kernel.modules


  def search(json, segments)
    results = []
    node = json
    segments.each_with_index do |segment, index|
      puts "Segment #{index}:#{segment}"
      if node.has_key?(segment)
        node = node[segment]
      end
      if index = (segments.length - 1)
        results << node
      end
    end
    results
  end
#  def search(json, segments)
#    results = []
#    node = json
#    segments.each_with_index do |segment, index|
#      puts "Segment #{index}:#{segment}"
#      if node.has_key?(segment)
#        node = node[segment]
#      else
#        if segment[0] == '$'
#          case segment
#          when "$key"
#            return node.keys
#          when "$object"
#            if node is_a? Hash
#              node.each do |v|
#                search(node, segments.drop(index))
#              end
#            elsif node is_a? Array
#              raise "Unimplemented!"
#            else
#              # keep iterating
#              node
#            end
#          else
#            raise "Unknown reserved word #{segment}"
#          end
#        else
#          # don't return false, that might be a valid answer
#          return nil
#        end
#      end
#    end
#    return node
#  end

  def to_s
    @qpath
  end
end

#module StarField
#  def value
#    puts "STARFIELD"
#    "SOMESTARFIELD"
#  end
#end

module FieldListWithStar
  def value
    captures(:sf).map do |c|
      c.value
    end
  end
end

#module Field
#  def value
#    puts "FIELD"
#    "FIELD"
#  end
#end

#module Id
#  def value
#    puts "ID"
#    capture(:id).value.to_str.strip
#  end
#end


module Ref
  def value
    puts "REF"
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
    #oq = OheyQuery.new(@@json)
    results = []
    source = capture(:source)[0]
    fields = capture(:fields).value
    puts "SOURCE = #{source}"
    sourcePath = JsonPath.new("$.#{source}")
    dataToFilter = sourcePath.on(@@json)
    #puts dataToFilter
    # apply where clauses
    filteredData = dataToFilter
    # return results
    results = []
    fields.each do |f|
      relativeField = "$.[*].#{f}"
      rp = JsonPath.new(relativeField)
      results << rp.on(filteredData)
    end
    return results.flatten
  end
end


Citrus.require('ohey')


