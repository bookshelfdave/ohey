require 'parslet'
require 'pp'


class OHeyParser < Parslet::Parser
  rule(:query) {
    str("select") >> space >>
      fields.as(:fields) >>
      str("from") >> space >>
      id.as(:source) >>
      where_clause.maybe
  }

  rule(:where_clause) { str("where") >> space >> predicates.as(:preds) }

  rule(:predicates) { predicate >> (andor >> predicate).repeat(0)  }

  rule(:andor) { (str("and") | str("or")) >> space }

  rule(:predicate)  { (ref.as(:a) >> op >> ref.as(:b)).as(:pred) }

  rule(:ref) { ( reserved | bool | string | id | number ).as(:ref) >> space? }

  rule(:bool) { (str("true") | str("false")).as(:bool) >> space? }

  rule(:op) { (str("=") | str("!=")).as(:op) >> space? }

  rule(:fields) { (field >> (comma >> field).repeat(0)).as(:f) }

  rule(:field) { id | reserved }


  rule(:digit) { match('[0-9]') }

  rule(:number) {
      (
        str('-').maybe >> (
          str('0') | (match('[1-9]') >> digit.repeat)
        ) >> (
          str('.') >> digit.repeat(1)
        ).maybe >> (
          match('[eE]') >> (str('+') | str('-')).maybe >> digit.repeat(1)
        ).maybe
      ).as(:number)
    }

  rule(:string) {
      str('"') >> (
        str('\\') >> any | str('"').absent? >> any
      ).repeat.as(:string) >> str('"')
    }

  rule(:reserved) { (str("$") >> id).as(:reserved) }

  rule(:id) { (match['a-z\._A-Z0-9'].repeat(1)).as(:id) >> space? }
  rule(:comma)      { match(',') >> space? }
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  root :query
end

class Pred
  attr_accessor :a
  attr_accessor :b
  attr_accessor :op
  def initialize(a, b, op)
    @a = a
    @b = b
    @op = op
  end

  def to_s
      "#{@a} #{@op} #{@b}"
  end
end

class OHeyTrans < Parslet::Transform
    rule(:reserved=> simple(:v)) { "$#{v}" }
    rule(:f => simple(:v)) { [v] }
    rule(:f => sequence(:v)) { v }
    #rule(:f => {:reserved => simple(:v)}) { ["$#{v}"] }
    rule(:ref => simple(:v)) { v.to_str }
    rule(:string => simple(:v)) { v.to_str }
    rule(:number => simple(:v)) { v }
    rule(:id => simple(:v)) { v.to_str }
    rule(:pred=>{:a=>simple(:va), :op=>simple(:vop), :b=>simple(:vb)}) { Pred.new(va, vb, vop) }
    # I can't get :preds to match single items!
end

class OHey
  attr_accessor :parser
  def initialize
    @parser = OHeyParser.new
  end

  def apply_preds(data, preds)
    if preds == [nil]
      # TODO: parser bug
      return data
    end
    filtered_results = []
    data.each do |d|
      d.each do |x|
        ## TODO: and/or/group predicates
        preds.map do |p|
          #puts "Predicate: #{p}"
          qs = QuerySource.new(p.a)
          qs.resolve_pred_path(x, p)
          if qs.results.flatten == [true]
            filtered_results << x
          end
        end
      end
    end
    filtered_results
  end

  def run(q, json)
    #puts "Raw:"
    result =  parser.parse(q)
    #pp result
    #puts "---- transformed"
    trans = OHeyTrans.new
    result = trans.apply(result)
    #pp result

    fields = result[:fields]
    source = result[:source]
    preds = result[:preds]

    #puts "Fields #{fields}"
    #puts "Source #{source}"
    #puts "Preds #{preds}"

    results = []
    qs = QuerySource.new(source)
    qs.resolve_path(json)
    data_to_filter = qs.results

    # apply where clauses
    if preds.is_a? Array
      filtered_data = data_to_filter
      raise "Multiple preds not implemented"
    else
      filtered_data = apply_preds(data_to_filter, [preds])
    end

    results = []
    filtered_data.each do |r|
      # return results
      row = []
      fields.each do |f|
        #puts "Query #{f}"
        field_source = QuerySource.new(f)
        field_source.resolve_path(r)
        row << field_source.results
      end
      results << row
    end

    if results.length > 1
      return results.transpose
    else
      return results
    end

  end
end



