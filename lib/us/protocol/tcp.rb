module UnionStation
  # Provides a line-separated TCP server.
  # Messages are separated with CRLF.
  module ProtocolTCP
    Server.register_protocol(:tcp, self, EM::P::LineAndTextProtocol)
    
    # Starts a TCP server.
    #
    # Arguments:
    # 
    # * +host+: the host to bind, defaults to localhost
    # * +port+: the port to listen on, defaults to 1894
    #
    # <tt>:tcp => {:host => 'localhost', :port => 1914}</tt>
    def start!(server, channel, args = {})
      args[:host] ||= 'localhost'
      args[:port] ||= 1894
      EM.start_server(args[:host], args[:port], self, server, channel)
    end
    
    # Stops a TCP server.
    def stop!(signature)
      EM.stop_server(signature)
    end
    
    def self.send_data(data)
      super(data + "\r\n")
    end
  end
end