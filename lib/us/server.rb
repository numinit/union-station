module UnionStation
  # An abstraction for a UnionStation server. Many servers can run at once if
  # they're on different ports.
  class Server
    @@protocols = {}
    
    # Registers a new Protocol for use globally.
    # Uses some serious class hackery to set parents correctly.
    #
    # The protocol module name will be inferred from the +name+ argument.
    # 
    # +:tcp+ would yield +ProtocolTcp+ as the module name.
    #
    # +:web_socket+ would yield +ProtocolWebSocket+ as the module name.
    def self.register_protocol!(name, parent)
      # Use some meta-class hackery.
      # Make a new class as a child of the EventMachine connection
      # that we want to use. Include the Protocol methods to make
      # this class a dynamically generated Protocol class.
      
      # Infer the child from the name.
      protocol = "Protocol#{name.to_s.split('_').collect {|a| a.capitalize}.join}"
      child = UnionStation.const_get(protocol)
      raise "Protocol #{protocol_name} doesn't exist!" if child.nil? 
      
      # Now, make another class as a child of the newly-created class.
      # Looks like: EventMachine Protocol => Protocol => Child
      
      k = Class.new(parent) do
        def self.include(included_module)
          included_module.singleton_methods.each {|m| singleton_method_added(m)}
          included_module.instance_methods.each {|m| method_added(m)}
          super
        end
    
        include Protocol
      end
      
      c = Class.new(k) do
        def self.extend(included_module)
          super.include(included_module)
        end
        
        extend child
      end
      
      UnionStation.const_set("Synthesized#{child.name.to_s.rpartition('::').last}", c)
      
      @@protocols[name.to_s.to_sym] = c
    end
    
    # Creates a new Server. One Server acts as the hub for many connections and many
    # Protocol objects.
    def initialize
      @listeners, @connections = {}, []
    end
    
    # Starts the server synchronously.
    # 
    # Arguments are keys with hashes as values. The hash keys represent each protocol you wish to
    # start, and the hash values are Hashes themselves, with the arguments you want to pass to each protocol.
    #
    # See the documentation for each protocol for more information on their specific arguments.
    #
    # Example:
    #
    # <tt>
    # us = Server.new
    # </tt>
    #
    # <tt>
    # us.start!
    # :tcp => {:host => '127.0.0.1', :port => 1894},
    # :udp => {:port => 8000},
    # :unix => {:socket => '/var/run/union_station.sock'}
    # </tt>
    def start!(args = {})
      EM.epoll
      EM.run do
        @channel = EM::Channel.new
        args.each do |k, v|
          v = {} unless v.is_a?(Hash)
          @listeners[k] = @@protocols[k].start!(self, @channel, v) if !@@protocols.nil? && @@protocols.has_key?(k)
        end
        warn('no protocols loaded') if @listeners.empty?
      end
    end
    
    # Stops the server and all protocols, and makes sure that all connections are nicely closed.
    # If Union Station isn't daemonized, call this instead of UnionStation::stop!
    #
    # Takes a timeout in seconds. If all connections have not terminated in the timeframe given,
    # Union Station will be forced to stop.
    def stop!(timeout = 2.00)
      @listeners.each do |k, v|
        @@protocols[k].stop!(v)
      end
      
      # If there are connections still registered, let those close before
      # we kill the server.
      accum, step = 0, 0.2
      unless @connections.empty?
        EM.add_periodic_timer(step) do
          EM.stop if @connections.empty? || accum >= timeout
          accum += step
        end
      else
        EM.stop if EM.reactor_running?
      end
    end
    
    # Binds a connection to this server. Usually called by the connection.
    def bind(connection)
      @connections.push(connection)
    end
    
    # Unbinds a connection from this server. Usually called by the connection.
    def unbind(connection)
      @connections.delete(connection)
    end
    
    # Attaches to an EventMachine instance. Only called internally.
    def attach(ev)
      @ev, @connections = ev, []
    end
    
    private :attach
  end
end