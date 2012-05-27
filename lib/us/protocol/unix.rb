module UnionStation
  # Provides a UNIX socket server.
  module ProtocolUnix
    Server.register_protocol(:unix, self, EM::P::LineAndTextProtocol)
    
    # Starts a UNIX domain server.
    #
    # Arguments:
    #
    # * +socket+: the socket file to bind
    #
    # <tt>:unix => {:socket => '/var/run/union_station.sock'}</tt>
    def start!(server, channel, args = {})
      args[:socket] ||= File.join('/var', 'run', 'union_station.sock')
      EM.start_unix_domain_server(args[:socket], self, server, channel)
    end
    
    # Stops a UNIX domain server.
    def stop!(signature)
      EM.stop_server(signature)
    end
  end
end