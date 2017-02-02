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
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ConfigExpanderInput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal 'foobar', d.instance.tag
    assert_equal 3, d.instance.nodes.size
    assert_equal ['1','2','3'], d.instance.nodes.map{|n| n.attr1 }.sort

    assert_equal false, d.instance.started
    assert_equal false, d.instance.stopped

    d.instance.start()
    assert_equal true, d.instance.started
    assert_equal false, d.instance.stopped

    d.instance.shutdown()
    assert_equal true, d.instance.stopped
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
</config>
]
  def test_configure_hostname
    d = create_driver CONFIG2
    assert_equal 1, d.instance.nodes.size
    assert_equal 'testing.node.local', d.instance.nodes.first.attr1
    assert_equal 'testing.node.local', d.instance.nodes.first.attr2
    assert_equal 'testing.node.local', d.instance.nodes.first.attr3
    assert_equal 'testing.node.local', d.instance.nodes.first.attr4
  end
end
