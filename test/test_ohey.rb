require 'minitest/autorun'
require 'ohey'
require 'json'


class OheyTest < Minitest::Test

  def load_test_json
    file = open("./test/data.json")
    json = file.read
    JSON.parse(json)
  end

  def parse(query)
    json = load_test_json
    parser = OHey.new()
    parser.run(query, json)
  end

  def query(q)
    json = load_test_json
    q = QuerySource.new(q)
    q.resolve_path(json)
    q.results
  end

  def test_paths
    assert_equal ["Linux"], query("kernel.name")
    assert_equal 24, query("kernel.modules")[0].count

    modkeys = query("kernel.modules.$key")
    assert_equal 24, modkeys.length
    assert modkeys.include?("psmouse")

    #allmods = query("kernel.modules.$object")
    #empty set, no child segment

    allmodrefcounts = query("kernel.modules.$object.refcount")
    assert_equal 24, allmodrefcounts.length
    assert_equal 22, allmodrefcounts.map { |x| x.to_i }.reduce(:+)

  end

  def test_parse
    #assert parse("select real, total, vendor_id from cpu")
    #assert parse("select real, total, vendor_id from cpu where total = 8")
    #assert parse("select $key from kernel.modules")
    #assert parse('select true from cpu where "fpu" = flags')
    #assert parse('select foo.bar.baz from cpu where "fpu" = flags')
    #assert parse('select * from filesystem where $child.blocksize != 512')
    #assert parse('select $key from filesystem where $object.blocksize != 512')
    #assert parse('select $key, $object.fs_type from filesystem where $object.fs_type != "hfs"')
    #assert parse('select * from network.interfaces where $key = "gif0"')
    #assert parse('select $key, $object.addresses from network.interfaces where "127.0.0.1" in $object.addresses')
  end


  def test_eval_simple
    o = parse("select foo, release, os from kernel")
    puts o
    #assert_equal [{"foo"=>nil, "release"=>"3.11.0-15-generic","os"=>"GNU/Linux"}], o
#
#    o = parse("select name, release, os from kernel")
#    assert_equal ["Linux", "3.11.0-15-generic","GNU/Linux"], o.flatten
#
#    o = parse("select systems.vbox from virtualization")
#    assert_equal ["guest"], o.flatten
#
#    o = parse("select total, free, mapped from memory")
#    assert_equal ["372020kB", "46580kB", "10032kB"], o.flatten
#
#    o = parse("select $key from kernel.modules")
#    puts o
#    assert_equal ["vboxsf", "dm_crypt", "ppdev", "parport_pc", "psmouse",
#                  "mac_hid", "nfsd", "serio_raw", "nfs_acl", "vboxvideo",
#                  "auth_rpcgss", "nfs", "fscache", "lockd", "drm", "i2c_piix4",
#                  "sunrpc", "ext2", "vboxguest", "lp", "parport", "vesafb",
#                  "video", "e1000"], o
#    assert_equal 24, o.length
#
#
#    o = parse("select $object.size from kernel.modules")
#    assert_equal ["43820", "23111", "17711", "32866", "104093", "13253",
#                  "296365", "13413", "12883", "12658", "59609", "187669",
#                  "63355", "95174", "306660", "22299", "278837", "73909",
#                  "244206", "17799", "42466", "13876", "19574", "152205"], o.flatten
#    assert_equal 24, o.flatten.length
#
#
    #puts "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    o = parse("select $key, $object.size from kernel.modules")
    puts o
#    assert_equal [["vboxsf", "43820"], ["dm_crypt", "23111"], ["ppdev", "17711"],
#                  ["parport_pc", "32866"], ["psmouse", "104093"], ["mac_hid", "13253"],
#                  ["nfsd", "296365"], ["serio_raw", "13413"], ["nfs_acl", "12883"],
#                  ["vboxvideo", "12658"], ["auth_rpcgss", "59609"], ["nfs", "187669"],
#                  ["fscache", "63355"], ["lockd", "95174"], ["drm", "306660"],
#                  ["i2c_piix4", "22299"], ["sunrpc", "278837"], ["ext2", "73909"],
#                  ["vboxguest", "244206"], ["lp", "17799"], ["parport", "42466"],
#                  ["vesafb", "13876"], ["video", "19574"], ["e1000", "152205"]], o
#
#
#    o = parse("select $size from kernel.modules")
#    ## TODO... size returns a scalar value
#    #          this breaks if you select vector values next to it
#    assert_equal 24, o[0][0]
#
  end

 def test_where_clause
#    o = parse("select $key, $object.refcount from kernel.modules where $object.refcount = 6")
#    puts "#{o}"
 end



    #                addresses is yet another hash... get the family key
    # select $key, $object.addresses.family from network.interfaces where "127.0.0.1" in $object.addresses
    # select $value from network.settings.net.local.inflight
    # select $value from network.settings where $key =~ 'net.inet.*'

end
