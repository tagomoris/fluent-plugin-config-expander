require 'helper'
require_relative '../plugins'

class ConfigExpanderOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
type config_expander
<config>
  type config_expander_test
  tag foobar
  <for x in 1 2 3>
    <node>
      attr1 __x__
    </node>
  </for>
</config>
]
  def create_driver(conf=CONFIG, tag='test.default')
    Fluent::Test::OutputTestDriver.new(Fluent::ConfigExpanderOutput, tag).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal 'foobar', d.instance.plugin.tag
    assert_equal 3, d.instance.plugin.nodes.size
    assert_equal ['1','2','3'], d.instance.plugin.nodes.map{|n| n['attr1']}.sort

    assert_equal false, d.instance.plugin.started
    assert_equal false, d.instance.plugin.stopped

    d.instance.start()
    assert_equal true, d.instance.plugin.started
    assert_equal false, d.instance.plugin.stopped
    
    d.instance.shutdown()
    assert_equal true, d.instance.plugin.stopped
  end

  def test_emit
    d = create_driver
    d.run do
      d.emit({'field' => 'value1'})
      d.emit({'field' => 'value2'})
      d.emit({'field' => 'value3'})
    end

    emits = d.emits
    assert_equal 3, emits.size

    assert_equal 'foobar', emits[0][0]
    assert_equal 'value1', emits[0][2]['field']
    assert_equal 'expander', emits[0][2]['over']

    assert_equal 'foobar', emits[1][0]
    assert_equal 'value2', emits[1][2]['field']
    assert_equal 'expander', emits[1][2]['over']

    assert_equal 'foobar', emits[2][0]
    assert_equal 'value3', emits[2][2]['field']
    assert_equal 'expander', emits[2][2]['over']
  end

end
