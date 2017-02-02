require 'fluent/plugin/filter'

require_relative 'expander'
require 'forwardable'
require 'socket'

class Fluent::Plugin::ConfigExpanderFilter < Fluent::Plugin::Filter
  Fluent::Plugin.register_input('config_expander', self)

  config_param :hostname, :string, default: Socket.gethostname
  config_section :config, multi: false, required: true, param_name: :config_config do
    # to raise configuration error for missing section
  end

  def mark_used(conf)
    conf.keys.each {|key| conf[key] } # to suppress unread configuration warning
    conf.elements.each{|e| mark_used(e)}
  end

  def builtin_mapping
    {'__hostname__' => @hostname, '__HOSTNAME__' => @hostname, '${hostname}' => @hostname, '${HOSTNAME}' => @hostname}
  end

  def expand_config(conf)
    ex = Fluent::Config::Expander.expand(conf, builtin_mapping())
    ex.name = 'filter' # name/arg will be ignored by Plugin#configure, but anyway
    ex.arg = conf.arg
    ex
  end

  def configure(conf)
    super

    ex = expand_config(@config_config.corresponding_config_element)
    type = ex['@type']
    @plugin = Fluent::Plugin.new_input(type)
    @plugin.context_router = self.event_emitter_router(conf['@label'])
    @plugin.configure(ex)
    mark_used(@config_config.corresponding_config_element)

    self.extend SingleForwardable
    override_methods = self.methods + @plugin.methods - SingleForwardable.instance_methods - Object.instance_methods
    override_methods.uniq!
    def_delegators(:@plugin, *override_methods)
  end

  def method_missing(name, *args, &block)
    @plugin.__send__(name, *args, &block)
  end
end
