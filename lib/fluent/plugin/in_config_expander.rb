require_relative 'expander'

class Fluent::ConfigExpanderInput < Fluent::Input
  Fluent::Plugin.register_input('config_expander', self)

  # Define `log` method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method("log") { $log }
  end

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

  def configure(conf)
    super
    
    configs = conf.elements.select{|e| e.name == 'config'}
    if configs.size != 1
      raise Fluent::ConfigError, "config_expander needs just one <config> ... </config> section"
    end
    ex = expand_config(configs.first)
    @plugin = Fluent::Plugin.new_input(ex['type'])
    @plugin.configure(ex)

    mark_used(configs.first)
  end

  def start
    @plugin.start
  end

  def shutdown
    @plugin.shutdown
  end
end
