#     __  __       _               _____ __        __  _
#    / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#   / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#  / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#  \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#            Established 1914 in Denver, CO - Travel by Rails today!

module UnionStation
  class ServerConnection < EM::Connection
    attr_accessor :server
    
    def initialize(server)
      @server = server
      @server.connections.push(self)
    end
    
    def receive_data(data)
      begin
        json = Message.from_json(data).to_json
        @server.connections.each do |c|
          c.send_data(json) unless c == self
        end
      rescue
        close_connection
      end
    end
    
    def unbind
      @server.connections.delete(self)
    end
  end
  
  class Server
    attr_accessor :connections, :channel
    
    def attach(ev)
      @ev, @connections = ev, []
    end
    
    def start!(args = {})
      EM.run do
        if !args[:socket].nil? && !args[:socket].empty?
          self.attach(EM.start_unix_domain_server(args[:socket], ServerConnection, self) {|c| c.server = self})
        else
          self.attach(EM.start_server(args[:host], args[:port], ServerConnection, self) {|c| c.server = self})
        end
      end
    end
    
    def stop!
      EM.stop_server(@ev)
      unless wait_and_stop!
      EM.add_periodic_timer(0.5) { wait_and_stop! }
      end
    end
    
    def wait_and_stop!
      EM.stop if @connections.empty?
      @connections.empty?
    end
    
    private :wait_and_stop!
  end
end