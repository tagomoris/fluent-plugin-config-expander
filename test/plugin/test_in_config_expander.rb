require 'helper'
require_relative '../plugins'

class ConfigExpanderInputTest < Test::Unit::TestCase
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

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::ConfigExpanderInput).configure(conf)
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

  CONFIG2 = %[
type config_expander
hostname testing.node.local
<config>
  type config_expander_test
  tag baz
  <node>
    attr1 ${hostname}
    attr2 ${HOSTNAME}
    attr3 __hostname__
    attr4 __HOSTNAME__
  </node>
]
  def test_configure_hostname
    d = create_driver CONFIG2
    assert_equal 1, d.instance.plugin.nodes.size
    assert_equal 'testing.node.local', d.instance.plugin.nodes.first['attr1']
    assert_equal 'testing.node.local', d.instance.plugin.nodes.first['attr2']
    assert_equal 'testing.node.local', d.instance.plugin.nodes.first['attr3']
    assert_equal 'testing.node.local', d.instance.plugin.nodes.first['attr4']
  end

end
