require 'test/unit'

require 'union_station'
require 'us/client.rb'

class UnionStationTest < Test::Unit::TestCase  
  def test_server_start
    assert_nothing_raised do
      pid = UnionStation.start!
      assert_not_same(pid, 0)
      puts "Union Station running, pid #{pid}"
      sleep(1)
    end
  end
  
  def test_server_stop
    assert_nothing_raised do
      UnionStation.stop!
      puts "Union Station stopped, tests complete."
    end
  end
  
  def test_server_message
    100.times do |i|
      body = if i % 5 == 0
        [i, i + 1, i + 2, 'str']
      elsif i % 4 == 0
        {:idx => i, :msg => 'str'}
      elsif i % 3 == 0
        "test message, index #{i}"
      end
      
      m1 = UnionStation::Message.new('test',  i % 8, body)
      m2 = UnionStation::Message.from_json(m1.to_json)
        
      assert_equal(m1.level, m2.level)
      assert_equal(m1.channel, m2.channel)
      assert_equal(m1.body, m2.body)
      assert_not_nil(m1.timestamp)
      assert_not_nil(m2.timestamp)
      assert_not_nil(m1.uuid)
      assert_not_nil(m2.uuid)
    end
  end
end