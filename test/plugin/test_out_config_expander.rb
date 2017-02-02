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

  def create_driver(conf=CONFIG)
    d = Fluent::Test::Driver::BaseOwner.new(Fluent::Plugin::ConfigExpanderOutput)
    d.extend Fluent::Test::Driver::EventFeeder
    d.configure(conf)
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

  def test_emit
    d = create_driver
    d.run(default_tag: 'test.default', expect_records: 3) do
      d.feed({'field' => 'value1'})
      d.feed({'field' => 'value2'})
      d.feed({'field' => 'value3'})
    end

    events = d.events
    assert_equal 3, events.size

    assert_equal 'foobar', events[0][0]
    assert_equal 'value1', events[0][2]['field']
    assert_equal 'expander', events[0][2]['over']

    assert_equal 'foobar', events[1][0]
    assert_equal 'value2', events[1][2]['field']
    assert_equal 'expander', events[1][2]['over']

    assert_equal 'foobar', events[2][0]
    assert_equal 'value3', events[2][2]['field']
    assert_equal 'expander', events[2][2]['over']
  end
end
