require 'em-websocket'

module UnionStation
  # Provides a WebSocket server to send and receive Union Station events.
  module ProtocolWebSocket
    # Starts a WebSocket server.
    #
    # Arguments:
    # 
    # * +host+: the host to bind, defaults to localhost
    # * +port+: the port to listen on, defaults to 1914
    #
    # <tt>:http => {:host => 'localhost', :port => 1914}</tt>
    def start!(server, channel, args = {})
      args[:host] ||= 'localhost'
      args[:port] ||= PORT_ALT
      EM.start_server(args[:host], args[:port], self, server, channel)
    end
    
    # Stops an HTTP server.
    def stop!(signature)
      EM.stop_server(signature)
    end
  end
  
  protocol :web_socket, EM::WebSocket::Connection
end