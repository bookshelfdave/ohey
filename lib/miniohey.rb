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

  rule(:ref) { ( bool | string | id | number ).as(:ref) >> space? }

  rule(:bool) { (str("true") | str("false")).as(:bool) >> space? }

  rule(:op) { (str("=") | str("!=")).as(:op) >> space? }

  rule(:fields) { (id >> (comma >> id).repeat(0)).as(:f) }

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

  rule(:id) { (match['a-z\.A-Z'].repeat(1)).as(:id) >> space? }

  rule(:comma)      { match(',') >> space? }
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  root :query
end

class OHeyTrans < Parslet::Transform
    rule(:ref => simple(:v)) { v.to_str }
    rule(:string => simple(:v)) { v.to_str }
    rule(:number => simple(:v)) { v }
    rule(:id => simple(:v)) { v.to_str }
  end

parser = OHeyParser.new
result =  parser.parse("select foo, bar,baz from xyz where foo=\"bar\" and foo=1 or x = 2")
pp result
puts "----"
trans = OHeyTrans.new
pp trans.apply(result)
