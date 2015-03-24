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




class QuerySource
  attr_accessor :qpath
  attr_accessor :segments
  attr_accessor :results

  def initialize(p)
    @qpath = p.strip
    @segments = @qpath.split(".")
    @results = []
  end

  def resolve_path(json)
    resolve(json, @segments)
  end



#1) Iterate over the source, which must be an array or a hash
#2) Apply where clauses
#3) Extract fields


# $key is in kernel.modules
# select $key, $object.size from kernel.modules

  # returns a flattened list of all paths reachable by this
  # query
  def resolve(json, segments)
    node = json
    segments.each_with_index do |segment, index|
      #puts "Segment #{segment}, #{index}, #{segments.length - 1}"

      if node.is_a? Hash
        if node.has_key?(segment)
          node = node[segment]
        else
          case segment
            when '$key'
              node.each do |child|
                node = child[0]
                resolve(node, segments.drop(index))
              end
              return
            when '$object'
              node.each do |child|
                #puts "Resolve #{child[1]} #{segments.drop(index + 1)}"
                resolve(child[1], segments.drop(index + 1))
              end
              return
          end
        end

        if index == (segments.length - 1)
          @results << node
          return
        end

      elsif node.is_a? Array
        puts " - Array"
        puts node
        #puts "Array segments = #{segments}"
        #puts "X: Array"
        #if node.has_key?(segment)
        #  node = node[segment]
        #end

        #case segment
        #when '$key'
        #  node.each do |child|
        #    node = child[0]
        #    resolve(node, segments.drop(index))
        #  end
        #when '$object'
        #  node.each do |child|
        #    node = child[1]
        #    resolve(node, segments.drop(index))
        #  end
        #end
        raise "Array unimpl"
      else
        #puts "x"
        @results << node
      end
    end
  end

  def to_s
    @qpath
  end
end

module FieldListWithStar
  def value
    captures(:sf).map do |c|
      c.value
    end
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
    source_path = source.value
    #puts "SOURCE = #{source_path}"
    qs = QuerySource.new(source_path)
    qs.resolve_path(@@json)
    data_to_filter = qs.results

    # apply where clauses
    filtered_data = data_to_filter

    results = []
    filtered_data.each do |r|
      # return results
      fields.each do |f|
        #puts "Query #{f}"
        field_source = QuerySource.new(f)
        field_source.resolve_path(r)
        results << field_source.results
      end
    end
    return results.transpose
  end
end


Citrus.require('ohey')


