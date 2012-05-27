#      __  __       _               _____ __        __  _
#     / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#    / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#   / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#   \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#             Established 1914 in Denver, CO - Travel by Rails today!

module UnionStation
  class ProtocolUnix < Protocol
    Server.register_protocol(:unix, self)
    
    # Starts a UNIX domain server.
    #
    # Arguments:
    #
    # * +socket+: the socket file to bind
    def self.start!(server, channel, args = {})
      args[:socket] ||= File.join('/var', 'run', 'union_station.sock')
      EM.start_unix_domain_server(args[:socket], self, server, channel)
    end
    
    # Stops a UNIX domain server.
    def self.stop!(signature)
      EM.stop_server(signature)
    end
  end
end