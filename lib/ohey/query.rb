class QuerySource
  attr_accessor :qpath
  attr_accessor :segments
  attr_accessor :results

  @@keyword= %w($key $object)

  def initialize(p)
    @qpath = p.strip
    @segments = @qpath.split(".")
    @results = []
  end

  def resolve_path(json)
    resolve(json, @segments)
  end

  def is_keyword?(segment)
    @@keyword.include?(segment)
  end

  def is_container?(node)
    node.is_a? Hash or node.is_a? Array
  end

  # When does it finish?
  #   a) when all segments have been exhausted
  #   b) when the next segment can't be found
  def resolve(json, segments, pred=nil)

    if segments == []
      return
    end

    node = json
    last_segment = segments.length - 1
    segments.each_with_index do |segment, index|
      #puts "Segment #{segment}, #{index}, #{segments.length - 1}"

      if node.is_a? Hash
        if node.has_key?(segment)
          # segment found, push
          node = node[segment]
          if index == last_segment
            @results << node
            return
          end
        elsif is_keyword?(segment)
          # keyword
          case segment
            when '$key'
              node.each do |child|
                node = child[0]
                if is_container?(node)
                  resolve(node, segments.drop(index))
                else
                  @results << node
                end
              end
              return
            when '$object'
              node.each do |child|
                if is_container?(node)
                  #puts "Resolve #{child[1]} #{segments.drop(index + 1)}"
                  #puts ">>> #{segments.drop(index+1)}"
                  resolve(child[1], segments.drop(index + 1))
                else
                  @results << node
                end
              end
              return
          end
          return
        else
          # segment not found
          puts "Segment(s) not found: #{@segments}"
          @results << nil
        end


      elsif node.is_a? Array
        puts node
        raise "Array unimpl"
      else
        puts "NOT AN ARRAY OR HASH"
      end
    end
  end



#  def search(json)
#      search_segments(json, @segments)
#  end
#
#  def search_segments(json, segments)
#    index = 0
#    searching = true
#    node = json
#    while searching
#      segment = segments[index]
#      if index == segments.length
#        # exit the search loop
#        searching = false
#        next
#      end
#
#      if node.is_a? Hash
#        if node.has_key?(segment)
#          node = node[segment]
#          index += 1
#          next
#        elsif is_reserved(segment)
#
#           #when '$key'
#           #   node.each do |child|
#           #     node = child[0]
#           #     resolve(node, segments.drop(index))
#        else
#          # not found
#          searching = false
#          node = nil
#          next
#        end
#      elsif node.is_a? Array
#        puts "Array unimplemented"
#      else
#        puts "Some other type!"
#      end
#    end # while searching
#    node
#  end

  def to_s
    @qpath
  end
end

