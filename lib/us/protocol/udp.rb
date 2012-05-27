module UnionStation
  # Provides a UDP datagram server. One message is sent per datagram.
  module ProtocolUDP
    Server.register_protocol(:udp, self, EM::Connection)
    
    # Starts a UDP server.
    #
    # Arguments:
    # 
    # * +host+: the host to bind, defaults to localhost
    # * +port+: the port to listen on, defaults to 1894
    #
    # <tt>:udp => {:host => 'localhost', :port => 1914}</tt>
    def start!(server, channel, args = {})
      args[:host] ||= 'localhost'
      args[:port] ||= 1894
      EM.open_datagram_socket(args[:host], args[:port], self, server, channel)
    end
    
    # Stops a UDP server.
    def stop!(signature)
      # UDP is stateless. Silence is golden.
    end
  end
end