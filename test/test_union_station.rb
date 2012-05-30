require 'test/unit'
require 'socket'

require 'union_station'

require 'us/protocol/tcp'
require 'us/protocol/udp'
require 'us/protocol/unix'

class UnionStationTest < Test::Unit::TestCase
  PORT = US::PORT
  
  def test_server_start_stop
    assert_nothing_raised do
      # Start the server
      pid = US.start!(:tcp => :defaults, :udp => :defaults, :unix => {:socket => "#{ENV['HOME']}/union_station.sock"})
      assert_not_same(pid, 0)
      
      sleep(1)
      
      # Stop the server
      ret = US.stop!
      assert_equal(true, ret)
    end
  end
  
  def test_tcp
    assert_nothing_raised do
      US.start!(:tcp => :defaults)
      sleep(1)
      
      $t = TCPSocket.new('localhost', PORT)
      
      1000.times do
        tx = US::Message.bare("unit_test", SecureRandom::hex)
        tx_json = tx.to_json
        
        $t.write(tx_json + "\r\n")
        
        rx = US::Message.from_json($t.gets)
        
        assert_equal(tx.channel, rx.channel)
        assert_equal(tx.level, rx.level)
        assert_equal(tx.body, rx.body)
      end
      
      $t.shutdown(:RDWR)
      
      US.stop!
    end
  end
  
  def test_udp
    assert_nothing_raised do
      US.start!(:udp => :defaults)
      sleep(1)
      
      $u = UDPSocket.new
      $u.connect('localhost', PORT)
      
      1000.times do
        tx = US::Message.bare("unit_test", SecureRandom::hex)
        tx_json = tx.to_json
        
        $u.write(tx_json)
        rx = US::Message.from_json($u.recv(1024))
          
        assert_equal(tx.channel, rx.channel)
        assert_equal(tx.level, rx.level)
        assert_equal(tx.body, rx.body)
      end
      
      $u.shutdown(:RDWR)
      
      US.stop!
    end
  end

  def test_unix
    assert_nothing_raised do
      socket = "#{ENV['HOME']}/union_station.sock"
      US.start!(:unix => {:socket => socket})
      sleep(1)
      
      $x = UNIXSocket.new(socket)
      
      1000.times do
        tx = US::Message.bare("unit_test", SecureRandom::hex)
        tx_json = tx.to_json
        
        $x.write(tx_json + "\r\n")
        rx = US::Message.from_json($x.gets)
          
        assert_equal(tx.channel, rx.channel)
        assert_equal(tx.level, rx.level)
        assert_equal(tx.body, rx.body)
      end
      
      $x.shutdown(:RDWR)
      File.delete(socket)
      
      US.stop!
    end
  end
  
=begin
  def test_multi
    assert_nothing_raised do
      socket = "#{ENV['HOME']}/union_station.sock"
      US.start!(:tcp => :defaults, :udp => :defaults, :unix => {:socket => socket})
      sleep(1)
      
      $t = TCPSocket.new('localhost', PORT)
      
      $u_tx = UDPSocket.new
      $u_tx.connect('localhost', PORT)
      
      $u_rx = UDPSocket.new
      $u_rx.connect('localhost', PORT)
      
      $x = UNIXSocket.new(socket)
      
      # TCP => UDP + UNIX
      1000.times do
        tx = US::Message.bare("unit_test", SecureRandom::hex)
        tx_json = tx.to_json
        
        $t.write(tx_json + "\r\n")
        rx_udp = US::Message.from_json($u_rx.recv(1024))
        rx_unix = US::Message.from_json($x.gets)
        
        assert_equal(tx.channel, rx_udp.channel)
        assert_equal(tx.level, rx_udp.level)
        assert_equal(tx.body, rx_udp.body)
        
        assert_equal(tx.channel, rx_unix.channel)
        assert_equal(tx.level, rx_unix.level)
        assert_equal(tx.body, rx_unix.body)
        
        assert_equal(rx_udp.uuid, rx_unix.uuid)
        assert_equal(rx_udp.timestamp, rx_unix.timestamp)
      end
      
      # UDP => TCP + UNIX
      1000.times do
        tx = US::Message.bare("unit_test", SecureRandom::hex)
        tx_json = tx.to_json
        
        $u_tx.write(tx_json)
        rx_tcp = US::Message.from_json($t.gets)
        rx_unix = US::Message.from_json($x.gets)
        
        assert_equal(tx.channel, rx_tcp.channel)
        assert_equal(tx.level, rx_tcp.level)
        assert_equal(tx.body, rx_tcp.body)
        
        assert_equal(tx.channel, rx_unix.channel)
        assert_equal(tx.level, rx_unix.level)
        assert_equal(tx.body, rx_unix.body)
        
        assert_equal(rx_tcp.uuid, rx_unix.uuid)
        assert_equal(rx_tcp.timestamp, rx_unix.timestamp)
      end

      # UNIX => TCP + UDP
      1000.times do
        tx = US::Message.bare("unit_test", SecureRandom::hex)
        tx_json = tx.to_json
        
        $x.write(tx_json + "\r\n")
        rx_tcp = US::Message.from_json($t.gets)
        rx_udp = US::Message.from_json($u_rx.recv(1024))
        
        assert_equal(tx.channel, rx_tcp.channel)
        assert_equal(tx.level, rx_tcp.level)
        assert_equal(tx.body, rx_tcp.body)
        
        assert_equal(tx.channel, rx_udp.channel)
        assert_equal(tx.level, rx_udp.level)
        assert_equal(tx.body, rx_udp.body)
        
        assert_equal(rx_tcp.uuid, rx_udp.uuid)
        assert_equal(rx_tcp.timestamp, rx_udp.timestamp)
      end
      
      $t.shutdown(:RDWR)
      $u_rx.shutdown(:RD)
      $u_tx.shutdown(:WR)
      $x.shutdown(:RDWR)
      
      File.delete(socket)
      
      US.stop!
    end
  end
=end
  
  def test_message
    100.times do |i|
      body = if i % 5 == 0
        [i, i + 1, i + 2, 'str']
      elsif i % 4 == 0
        {:idx => i, :msg => 'str'}
      elsif i % 3 == 0
        "test message, index #{i}"
      end
      
      m1 = US::Message.bare('test', i % 8, body)
      m2 = US::Message.from_json(m1.to_json)
        
      assert_equal(m1.level, m2.level)
      assert_equal(m1.channel, m2.channel)
      assert_equal(m1.body, m2.body)
    end
  end
end
