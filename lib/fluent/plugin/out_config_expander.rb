require_relative 'expander'

class Fluent::ConfigExpanderOutput < Fluent::MultiOutput
  Fluent::Plugin.register_output('config_expander', self)

  config_param :hostname, :string, :default => `hostname`.chomp
  attr_accessor :plugin

  def mark_used(conf)
    conf.keys.each {|key| conf[key] } # to suppress unread configuration warning
    conf.elements.each{|e| mark_used(e)}
  end

  def builtin_mapping
    {'__hostname__' => @hostname, '__HOSTNAME__' => @hostname, '${hostname}' => @hostname, '${HOSTNAME}' => @hostname}
  end

  def expand_config(conf)
    ex = Fluent::Config::Expander.expand(conf, builtin_mapping())
    ex.name = ''
    ex.arg = ''
    ex
  end

  attr_reader :outputs

  def configure(conf)
    super

    configs = conf.elements.select{|e| e.name == 'config'}
    if configs.size != 1
      raise Fluent::ConfigError, "config_expander needs just one <config> ... </config> section"
    end
    ex = expand_config(configs.first)
    @plugin = Fluent::Plugin.new_output(ex['type'])
    @plugin.configure(ex)

    @outputs = [@plugin]

    mark_used(configs.first)
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
