#      __  __       _               _____ __        __  _
#     / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#    / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#   / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#   \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#             Established 1914 in Denver, CO - Travel by Rails today!

module UnionStation
  class Protocol < EM::P::LineAndTextProtocol
    # The Server that this protocol belongs to
    attr_accessor :server
    
    # Starts a generic server. By default, this throws a runtime error.
    def self.start!(server, channel, args = {})
      raise 'Using default Protocol::start. Override me!'
    end
    
    # Stops a generic server. By default, this throws a runtime error.
    def self.stop!(signature)
      raise 'Using default Protocol::stop. Override me!'
    end
    
    # Make a new connection and register with a Server and an EM::Channel.
    def initialize(server, channel)
      @server = server
      @channel = channel
    end
    
    # Called after initialization. Binds this connection to a Server and subscribes this
    # connection to a channel.
    def post_init
      @server.bind(self)
      @sid = @channel.subscribe do |data|
        begin
          self.send_data(Message.from_json(data).to_json)
        rescue JSON::ParserError
          self.close_connection
        end
      end
    end
    
    # Called when the client disconnects.
    def unbind
      @channel.unsubscribe(@sid)
      @server.unbind(self)
    end
    
    # Sends some data. Can easily be overridden by subclasses.
    def send_data(data)
      super
    end
    
    # Receives some data. Can easily be overridden by subclasses.
    # By default, this method replicates the data in question to all clients.
    def receive_data(data)
      @channel.push(data)
    end
  end
end