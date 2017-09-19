require 'fluent/plugin/bare_output'

require_relative 'expander'
require 'forwardable'
require 'socket'

class Fluent::Plugin::ConfigExpanderOutput < Fluent::Plugin::BareOutput
  Fluent::Plugin.register_output('config_expander', self)

  helpers :event_emitter

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
    ex.name = 'match' # name/arg will be ignored by Plugin#configure, but anyway
    ex.arg = conf.arg
    ex
  end

  def configure(conf)
    super

    ex = expand_config(@config_config.corresponding_config_element)
    log.debug "[#{self.class.name}] expand config: \n" + ex.to_s

    type = ex['@type']
    @plugin = Fluent::Plugin.new_output(type)
    @plugin.context_router = self.event_emitter_router(conf['@label'])
    @plugin.configure(ex)
    mark_used(@config_config.corresponding_config_element)

    # hack for https://bugs.ruby-lang.org/issues/12478 in ruby 2.3 or earlier
    mojule = Module.new do
      def method_defined?(accessor)
        methods.include?(accessor.to_sym)
      end
      def private_method_defined?(accessor)
        private_methods.include?(accessor.to_sym)
      end
    end
    self.extend(mojule) unless self.class === Module

    self.extend SingleForwardable
    override_methods = @plugin.methods - SingleForwardable.instance_methods - Object.instance_methods
    def_delegators(:@plugin, *override_methods)
  end
end
