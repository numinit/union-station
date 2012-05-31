module UnionStation
  # The base module for Union Station protocols.
  module Protocol
    # The Server that this protocol belongs to
    attr_accessor :server
    
    # Starts a generic server. By default, this throws a runtime error.
    def start!(server, channel, args = {})
      raise 'Using default Protocol::start. Override me!'
    end
    
    # Stops a generic server. By default, this throws a runtime error.
    def stop!(signature)
      raise 'Using default Protocol::stop. Override me!'
    end
    
    # Step 1: Initialize a new Protocol.
    def initialize(*args)
      super
      # Attempt to set Socket::SO_REUSEADDR. Note that this will require
      # a pretty new version of EventMachine.
      set_sock_opt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true if respond_to?(:set_sock_opt)
      
      raise ArgumentError if args.count < 2
      @server = args[0]
      @channel = args[1]
    end
    
    # Step 2: Bind to a server and subscribe to its channel.
    def post_init
      super
      @server.bind(self)
      @sid = @channel.subscribe do |data|
        begin
          send_data(Message.from_json(data).to_json)
        rescue RuntimeError, JSON::ParserError => err
        end
      end
    end
    
    # Step 3: Disconnect.
    def unbind
      super
      @channel.unsubscribe(@sid)
      @server.unbind(self)
    end
  end
end