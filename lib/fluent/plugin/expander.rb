require 'fluent/config'

module Fluent::Config::Expander
  def self.replace(str, mapping)
    mapping.reduce(str){|r,p| str.gsub(p[0], p[1])}
  end

  def self.expand(element, mapping)
    name = replace(element.name, mapping)
    arg = replace(element.arg, mapping)
    attrs = element.reduce({}){|r,p| r[replace(p.first, mapping)] = replace(p.last, mapping); r}
    elements = []
    element.elements.each do |e|
      if e.name == 'for'
        unless e.arg =~ /^([a-zA-Z0-9]+) in (.+)$/
          raise Fluent::ConfigError, "invalid for tag syntax: <for NAME in ARG1 ARG2 ...>"
        end
        vname = '__' + $1 + '__'
        vargs = $2.split(/ +/).select{|v| v.size > 0}
        vargs.each do |v|
          expanded = expand(e, mapping.merge({vname => v}))
          attrs.update(expanded)
          elements += expanded.elements.map{|xe| expand(xe, mapping)}
        end
      else
        elements.push(expand(e, mapping))
      end
    end
    Fluent::Config::Element.new(name, arg, attrs, elements, [])
  end
end
