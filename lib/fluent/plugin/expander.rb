require 'fluent/config'

module Fluent::Config::Expander
  def self.replace(str, mapping)
    mapping.reduce(str){|r, pair| r.gsub(pair[0], pair[1])}
  end

  def self.expand(element, mapping)
    name = replace(element.name, mapping)
    arg = replace(element.arg, mapping)
    attrs = element.reduce({}){|r, pair| r[replace(pair[0], mapping)] = replace(pair[1], mapping); r}
    elements = []
    element.elements.each do |e|
      if e.name == 'for'
        unless e.arg =~ /^([a-zA-Z0-9]+) in (.+)$/
          raise Fluent::ConfigError, "invalid for tag syntax: <for NAME in ARG1 ARG2 ...>"
        end
        vkey = $1.dup
        vargs = $2.split(/ +/).select{|v| v.size > 0}

        vname = '__' + vkey + '__'
        vname2 = '${' + vkey + '}'
        vargs.each do |vary|
          # no indexed vname implicitly indicate a first element
          vfirst = vary.split(',').first
          vmaps = {vname => vfirst, vname2 => vfirst}

          indexed_vmaps = vary.split(',').map.with_index {|v, i|
            {"__#{vkey}[#{i}]__" => v, "${#{vkey}[#{i}]}" => v}
          }.reduce({}){|memo, item| memo.merge(item) }

          expanded = expand(e, mapping.merge(vmaps).merge(indexed_vmaps))
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
