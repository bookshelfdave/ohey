class QuerySource
  attr_accessor :qpath
  attr_accessor :segments
  attr_accessor :results
  attr_accessor :debug

  @@keyword= %w($key $object $size)

  def initialize(p)
    @qpath = p.strip
    @segments = @qpath.split(".")
    @results = []
    @debug = false
  end

  def resolve_path(json)
    resolve(json, @segments)
  end

  def resolve_pred_path(json, pred)
    resolve(json, @segments, pred)
  end

  def is_keyword?(segment)
    @@keyword.include?(segment)
  end

  def is_container?(node)
    node.is_a? Hash or node.is_a? Array
  end

  def eval_if_pred(value, pred)
    if pred.nil?
      @results << value
    else
      puts "EVAL #{pred}"
      @results << value
    end
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
            #@results << node
            eval_if_pred(node, pred)
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
                  eval_if_pred(node, pred)
                  #@results << node
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
                  #@results << node
                  eval_if_pred(node, pred)
                end
              end
              return
            when '$size'
              @results << node.size
              # TODO
              #eval_if_pred(node, pred)
          end
          return
        else
          # segment not found
          puts "Segment(s) not found: #{@segments}"
          eval_if_pred(nil, pred)
        end


      elsif node.is_a? Array
        puts node
        raise "Array unimpl"
      else
        puts "NOT AN ARRAY OR HASH"
      end
    end
  end


  def to_s
    @qpath
  end
end

