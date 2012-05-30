module UnionStation
  # Provides a line-separated TCP server.
  # Messages are separated with CRLF.
  module ProtocolTcp
    # Starts a TCP server.
    #
    # Arguments:
    # 
    # * +host+: the host to bind, defaults to localhost
    # * +port+: the port to listen on, defaults to 1894
    #
    # <tt>:tcp => {:host => 'localhost', :port => 1894}</tt>
    def start!(server, channel, args = {})
      args[:host] ||= 'localhost'
      args[:port] ||= PORT
      EM.start_server(args[:host], args[:port], self, server, channel)
    end
    
    # Stops a TCP server.
    def stop!(signature)
      EM.stop_server(signature)
    end
    
    # Receives one line of TCP data.
    def receive_line(line)
      line.strip!
      @channel << line unless line.empty?
    end
    
    def send_data(data)
      super(data + "\r\n")
    end
  end
  
  protocol :tcp, EM::P::LineAndTextProtocol
end