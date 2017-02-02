require 'fluent/plugin/input'

class Fluent::Plugin::ConfigExpanderTestInput < Fluent::Plugin::Input
  Fluent::Plugin.register_input('config_expander_test', self)

  config_param :tag, :string
  config_section :node, param_name: :nodes, multi: true do
    config_param :attr1, :string, default: nil
    config_param :attr2, :string, default: nil
    config_param :attr3, :string, default: nil
    config_param :attr4, :string, default: nil
  end
  attr_accessor :started, :stopped

  def configure(conf)
    super
    @started = @stopped = false
  end
  def start
    super
    @started = true
  end
  def shutdown
    @stopped = true
    super
  end
end

require 'fluent/plugin/output'

class Fluent::Plugin::ConfigExpanderTestOutput < Fluent::Plugin::Output
  Fluent::Plugin.register_output('config_expander_test', self)

  helpers :event_emitter

  config_param :tag, :string
  config_section :node, param_name: :nodes, multi: true do
    config_param :attr1, :string, default: nil
    config_param :attr2, :string, default: nil
    config_param :attr3, :string, default: nil
    config_param :attr4, :string, default: nil
  end
  attr_accessor :started, :stopped

  def configure(conf)
    super
    @started = @stopped = false
  end
  def start
    super
    @started = true
  end
  def shutdown
    @stopped = true
    super
  end

  def process(tag, es)
    es.each do |time, record|
      router.emit(@tag, time, record.merge({'over' => 'expander'}))
    end
  end
end
