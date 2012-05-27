#      __  __       _               _____ __        __  _
#     / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#    / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#   / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#   \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#             Established 1914 in Denver, CO - Travel by Rails today!

module UnionStation
  class ProtocolTCP < Protocol
    Server.register_protocol(:tcp, self)
    
    # Starts a TCP server.
    #
    # Arguments:
    # 
    # * +host+: the host to bind, defaults to localhost
    # * +port+: the port to listen on, defaults to 1894
    def self.start!(server, channel, args = {})
      args[:host] ||= 'localhost'
      args[:port] ||= 1894
      EM.start_server(args[:host], args[:port], self, server, channel)
    end
    
    # Stops a TCP server.
    def self.stop!(signature)
      EM.stop_server(signature)
    end
    
    def send_data(data)
      super(data + "\r\n")
    end
  end
end