require 'minitest/autorun'
require 'ohey'
require 'json'
require 'jsonpath'

class OheyTest < Minitest::Test
  def parse(query)
    O.parse(query)
  end

  def test_parse
    assert parse("select real, total, vendor_id from cpu")
    assert parse("select real, total, vendor_id from cpu where total = 8")
    assert parse("select $key from kernel.modules")
    assert parse('select true from cpu where "fpu" = flags')
    assert parse('select foo.bar.baz from cpu where "fpu" = flags')
    assert parse('select * from filesystem where $child.blocksize != 512')
    assert parse('select $key from filesystem where $object.blocksize != 512')
    assert parse('select $key, $object.fs_type from filesystem where $object.fs_type != "hfs"')
    assert parse('select * from network.interfaces where $key = "gif0"')
    assert parse('select $key, $object.addresses from network.interfaces where "127.0.0.1" in $object.addresses')
  end

  def load_test_json
    file = open("./test/data.json")
    json = file.read
    JSON.parse(json)
  end

  def test_eval_simple
    json = load_test_json()
    Query::json = json
    o = O.parse("select name, release, os from kernel")
    assert_equal ["Linux", "3.11.0-15-generic","GNU/Linux"], o.value

    o = O.parse("select systems.vbox from virtualization")
    assert_equal ["guest"], o.value

    o = O.parse("select total, free, mapped from memory")
    assert_equal ["372020kB", "46580kB", "10032kB"], o.value


    o = O.parse("select $key, $object.size from kernel.modules")
    puts ">>>> #{o.value}"
  end

  def test_eval_object
    json = load_test_json()
    Query::json = json
    #o = O.parse("select $key from kernel.modules")
    #puts o.value
    #
    #o = O.parse("select $key from filesystem")
    #puts o.value

    #puts "--------------------------------------------------"
    #puts "--------------------------------------------------"
    #puts "--------------------------------------------------"
    ##o = O.parse("select $object.mount from filesystem")
    #puts o.value
  end


    #                addresses is yet another hash... get the family key
    # select $key, $object.addresses.family from network.interfaces where "127.0.0.1" in $object.addresses
    # select $value from network.settings.net.local.inflight
    # select $value from network.settings where $key =~ 'net.inet.*'

end
