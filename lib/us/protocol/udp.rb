module UnionStation
  # Provides a UDP datagram server. One message is sent per datagram.
  module ProtocolUdp
    # Starts a UDP server.
    #
    # Arguments:
    # 
    # * +host+: the host to bind, defaults to localhost
    # * +port+: the port to listen on, defaults to 1894
    #
    # <tt>:udp => {:host => 'localhost', :port => 1894}</tt>
    def start!(server, channel, args = {})
      args[:host] ||= 'localhost'
      args[:port] ||= PORT
      EM.open_datagram_socket(args[:host], args[:port], self, server, channel)
    end
    
    # Stops a UDP server.
    def stop!(signature)
      # UDP is stateless. Silence is golden.
      # Still, remove ourself from the list of connections so the server can safely stop.
      signature.server.unbind(signature)
    end
    
    # Receives one UDP datagram.
    def receive_data(data)
      @channel << data
    end
  end
  
   protocol :udp, EM::Connection
end