#      __  __       _               _____ __        __  _
#     / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#    / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#   / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#   \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#             Established 1914 in Denver, CO - Travel by Rails today!

module UnionStation
  class Server
    @@protocols = {}
    
    # Registers a new Protocol for use globally.
    def self.register_protocol(name, protocol)
      @@protocols[name.to_s.to_sym] = protocol
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
    # us.start!
    # :tcp => {:host => '127.0.0.1', :port => 1894},
    # :udp => {:port => 8000},
    # :unix => {:socket => '/var/run/union_station.sock'}
    # </tt>
    def start!(args = {})
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
    def stop!(timeout = 3.0)
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
      end
    end
    
    def bind(connection)
      @connections.push(connection)
    end
    
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