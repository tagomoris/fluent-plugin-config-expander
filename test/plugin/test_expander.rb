require 'helper'

class ConfigExpanderTest < Test::Unit::TestCase
  def setup
    @m = Fluent::Config::Expander
  end

  def test_replace
    assert_equal nil, @m.replace(nil, {})
    assert_equal "", @m.replace("", {})
    assert_equal "", @m.replace("", {'foo' => 'bar'})
    assert_equal "barbar", @m.replace("foobar", {'foo' => 'bar'})
    assert_equal "foofoo", @m.replace("foobar", {'bar' => 'foo'})
    assert_equal "foobar", @m.replace("foobar", {'hoge' => 'moge'})
    assert_equal "xxbar", @m.replace("foofoobar", {'foo' => 'x'})
    assert_equal "xxy", @m.replace("foofoobar", {'foo' => 'x', 'bar' => 'y'})
  end

  def test_expand
    e1 = Fluent::Config::Element.new('config', '', {'attr_first'=>'value_first', 'attr_second'=>'__NUM__'}, [], [])
    assert_equal "<config>\n  attr_first value_first\n  attr_second __NUM__\n</config>\n", e1.to_s
    assert_equal "<config>\n  attr_first value_first\n  attr_second 24224\n</config>\n", @m.expand(e1, {'__NUM__' => '24224'}).to_s

    e2 = Fluent::Config::Element.new('server', '', {'host'=> 'test', 'port'=>'__PORT__', 'ext'=>'__PORT__', 'num__PORT__'=>'1'}, [], [])
    assert_equal "<server>\n  host test\n  port __PORT__\n  ext __PORT__\n  num__PORT__ 1\n</server>\n", e2.to_s
    assert_equal "<server>\n  host test\n  port 24224\n  ext 24224\n  num24224 1\n</server>\n", @m.expand(e2, {'__PORT__' => '24224'}).to_s

    e3 = Fluent::Config::Element.new('config', 'for __PORT__', {'attr_first'=>'value_first', 'attr_second'=>'__PORT__'}, [e2], [])
    exconf1 = <<EOL
<config for 24224>
  attr_first value_first
  attr_second 24224
  <server>
    host test
    port 24224
    ext 24224
    num24224 1
  </server>
</config>
EOL
    assert_equal exconf1, @m.expand(e3, {'__PORT__' => '24224'}).to_s

    nonexconf2 = <<EOL
<config>
  <for portnum in 24221 24222 24223 24224>
    <server>
      host node__nodenum__.local
      port __portnum__
    </server>
  </for>
</config>
EOL
    conf2 = Fluent::Config.parse(nonexconf2, 'hoge').elements.first
    assert_equal nonexconf2, conf2.to_s
    exconf2 = <<EOL
<config>
  <server>
    host node__nodenum__.local
    port 24221
  </server>
  <server>
    host node__nodenum__.local
    port 24222
  </server>
  <server>
    host node__nodenum__.local
    port 24223
  </server>
  <server>
    host node__nodenum__.local
    port 24224
  </server>
</config>
EOL
    assert_equal exconf2, @m.expand(conf2, {}).to_s

    nonexconf3 = <<EOL
<config>
  type forward
  flush_interval 1s
  <for nodenum in 01 02>
    <for portnum in 24221 24222 24223 24224>
      <server>
        host node__nodenum__.local
        port __portnum__
      </server>
    </for>
  </for>
</config>
EOL
    conf3 = Fluent::Config.parse(nonexconf3, 'hoge').elements.first
    assert_equal nonexconf3, conf3.to_s
    exconf3 = <<EOL
<config>
  type forward
  flush_interval 1s
  <server>
    host node01.local
    port 24221
  </server>
  <server>
    host node01.local
    port 24222
  </server>
  <server>
    host node01.local
    port 24223
  </server>
  <server>
    host node01.local
    port 24224
  </server>
  <server>
    host node02.local
    port 24221
  </server>
  <server>
    host node02.local
    port 24222
  </server>
  <server>
    host node02.local
    port 24223
  </server>
  <server>
    host node02.local
    port 24224
  </server>
</config>
EOL
    assert_equal exconf3, @m.expand(conf3, {}).to_s

    nonexconf4 = <<EOL
<config>
  type forward
  flush_interval 1s
  <for nodenum in 01>
    <for portnum in 24221 24222 24223 24224>
      <server>
        host node__nodenum__.local
        port ${portnum}
      </server>
    </for>
  </for>
  <for nodenum in 02>
    <for portnum in 24221 24222 24223 24224>
      <server>
        host node${nodenum}.local
        port __portnum__
      </server>
    </for>
  </for>
</config>
EOL
    conf4 = Fluent::Config.parse(nonexconf4, 'hoge').elements.first
    assert_equal nonexconf4, conf4.to_s
    exconf4 = <<EOL
<config>
  type forward
  flush_interval 1s
  <server>
    host node01.local
    port 24221
  </server>
  <server>
    host node01.local
    port 24222
  </server>
  <server>
    host node01.local
    port 24223
  </server>
  <server>
    host node01.local
    port 24224
  </server>
  <server>
    host node02.local
    port 24221
  </server>
  <server>
    host node02.local
    port 24222
  </server>
  <server>
    host node02.local
    port 24223
  </server>
  <server>
    host node02.local
    port 24224
  </server>
</config>
EOL
    assert_equal exconf4, @m.expand(conf4, {}).to_s
  end
end
