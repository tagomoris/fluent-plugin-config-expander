class Fluent::ConfigExpanderTestInput < Fluent::Input
  Fluent::Plugin.register_input('config_expander_test', self)

  config_param :tag, :string
  attr_accessor :nodes
  attr_accessor :started, :stopped

  def configure(conf)
    super
    @nodes = []
    conf.elements.each do |e|
      next if e.name != 'node'
      @nodes << {}.merge(e)
    end
    @started = @stopped = false
  end
  def start
    super
    @started = true
  end
  def shutdown
    super
    @stopped = true
  end
end

class Fluent::ConfigExpanderTestOutput < Fluent::Output
  Fluent::Plugin.register_output('config_expander_test', self)

  config_param :tag, :string
  attr_accessor :nodes
  attr_accessor :started, :stopped

  def configure(conf)
    super
    @nodes = []
    conf.elements.each do |e|
      next if e.name != 'node'
      @nodes << {}.merge(e)
    end
    @started = @stopped = false
  end
  def start
    super
    @started = true
  end
  def shutdown
    super
    @stopped = true
  end

  # Define `router` method of v0.12 to support v0.10 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      router.emit(@tag, time, record.merge({'over' => 'expander'}))
    end
    chain.next
  end
end

require 'fluent/plugin/output'

class Fluent::ConfigExpanderV14TestOutput < Fluent::Output
  Fluent::Plugin.register_output('config_expander_test_v14', self)

  helpers :event_emitter

  config_param :tag, :string
  attr_accessor :nodes
  attr_accessor :started, :stopped

  def configure(conf)
    super
    @nodes = []
    conf.elements.each do |e|
      next if e.name != 'node'
      @nodes << {}.merge(e)
    end
    @started = @stopped = false
  end
  def start
    super
    @started = true
  end
  def shutdown
    super
    @stopped = true
  end

  def process(tag, es)
    es.each do |time, record|
      router.emit(@tag, time, record.merge({'over' => 'expander'}))
    end
  end
end
