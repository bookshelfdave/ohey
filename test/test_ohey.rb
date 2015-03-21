require 'minitest/autorun'
require 'ohey'

class OheyTest < Minitest::Test
  def test_one
    assert_equal 1, 1
    # select real, total, vendor_id from cpu
    # select true from cpu where total = 8
    # select $key from kernel.modules
    # select $object from kernel.modules
      # is $value the same as $object in this case?



    #
    # select true from cpu where "fpu" in flags
    # select * from filesystem where $child.blocksize != 512
    #   filesystem is a hash, not a list!
    # select $key, $object.fs_type from filesystem.$each where $object.fs_type != "hfs"

#    "filesystem": {
#    "/dev/disk1": {
#      "block_size": 512,
#      "kb_size": 487350400,
#      "kb_used": 160322916,
#      "kb_available": 326771484,
#      "percent_used": "33%",
#      "mount": "/",
#      "fs_type": "hfs",
#      "mount_options": [
#        "local",
#        "journaled"
#      ]
#    },



    # select * from network.interfaces where $key = "gif0"
    # select $key, $object.addresses from network.interfaces where "127.0.0.1" in $object.addresses
    #                addresses is yet another hash... get the family key
    # select $key, $object.addresses.family from network.interfaces where "127.0.0.1" in $object.addresses
    # select $value from network.settings.net.local.inflight
    # select $value from network.settings where $key =~ 'net.inet.*'




  end
end
