require_relative 'expander'

class Fluent::ConfigExpanderOutput < Fluent::Output
  Fluent::Plugin.register_output('config_expander', self)

  attr_accessor :plugin

  def expand_config(conf)
    ex = Fluent::Config::Expander.expand(conf, {})
    ex.name = ''
    ex.arg = ''
    ex
  end

  def configure(conf)
    super

    configs = conf.elements.select{|e| e.name == 'config'}
    if configs.size != 1
      raise Fluent::ConfigError, "config_expander needs just one <config> ... </config> section"
    end
    ex = expand_config(configs.first)
    @plugin = Fluent::Plugin.new_output(ex['type'])
    @plugin.configure(ex)
  end

  def start
    @plugin.start
  end

  def shutdown
    @plugin.shutdown
  end

  def emit(tag, es, chain)
    @plugin.emit(tag, es, chain)
  end
end
