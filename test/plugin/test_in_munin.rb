require 'helper'

class MuninInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    host                   localhost
    port                   4949
    interval               30
    tag_prefix             input.munin
    record_hostname yes
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::MuninInput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
    d = create_driver %[
      host                   localhost
      port                   4949
      interval               30
      tag_prefix             input.munin
      record_hostname yes
    ]
    d.instance.inspect
    assert_equal 'localhost', d.instance.host
    assert_equal 4949, d.instance.port
    assert_equal 30, d.instance.interval
    assert_equal 'input.munin', d.instance.tag_prefix
    assert_equal 'yes', d.instance.record_hostname
  end
end

