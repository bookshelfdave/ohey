require 'minitest/autorun'
require 'ohey'
require 'json'

class OheyPathTest < Minitest::Test
  def load_test_json
    file = open("./test/data.json")
    json = file.read
    JSON.parse(json)
  end


  def test_fields
    "kernel.name"
    "kernel" # the whole object, aka select * from kernel

    "kernel.modules.$key" #list of modules
    "kernel.modules.$object.size"

  end
end

