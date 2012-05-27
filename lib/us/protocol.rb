module UnionStation
  # The base class for Union Station protocols.
  # Inherits from LineAndTextProtocol since it's all JSON.
  module Protocol
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
        self.send(data)
      end
    end
    
    # Called when the client disconnects.
    def unbind
      @channel.unsubscribe(@sid)
      @server.unbind(self)
    end
    
    # Sends some data. Can easily be overridden by subclasses.
    def send(data)
      begin
        self.send_data(Message.from_json(data).to_json)
      rescue RuntimeError, JSON::ParserError => err
        warn err.to_s.gsub(/(\r|\n)/, '')
        self.close_connection
      end
    end
    
    # Receives some data. Can easily be overridden by subclasses.
    # By default, this method replicates the data in question to all clients.
    def receive_data(data)
      @channel.push(data)
    end
  end
end