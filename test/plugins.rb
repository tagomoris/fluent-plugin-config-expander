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

  def emit(tag, es, chain)
    es.each do |time, record|
      router.emit(@tag, time, record.merge({'over' => 'expander'}))
    end
    chain.next
  end
end
