#      __  __       _               _____ __        __  _
#     / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#    / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#   / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#   \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#             Established 1914 in Denver, CO - Travel by Rails today!

require 'eventmachine'

require 'us/server'
require 'us/message'
require 'us/protocol'

# The main Union Station module.
# Everything related to Union Station is contained within here!
module UnionStation
  PORT = 1914
  PORT_ALT = 1894
  
  # Starts Union Station as a daemon.
  #
  # See Server#start! for arguments.
  def self.start!(args = {})
    # Fork a child
    @@pid = Process.fork do
      @@server = Server.new
      Signal.trap('TERM') {@@server.stop!}
      @@server.start!(args)
    end
    
    # Detach it
    Process.detach(@@pid)
    
    @@pid
  end
  
  # Attempts to stop Union Station using the PID created
  # in ::start!, or the provided PID. This method will attempt to
  # stop the daemon nicely using SIGTERM, and will resort to SIGKILL if it
  # doesn't stop within the timeout. Timeout value is given in seconds, and
  # defaults to 3.00.
  #
  # This method will raise a RuntimeError if Union Station is not running or
  # if even SIGKILL failed.
  # 
  # Returns true if Union Station was terminated successfully, false if it
  # had to be killed.
  def self.stop!(pid = nil, timeout = 5.00)
    pid ||= @@pid
    
    wait_process = ->(pid, timeout) {
      accum, step = 0, 0.2
      while accum < timeout
        begin
          Process.kill(0, pid)
        rescue Errno::ESRCH
          break
        end
      
        sleep(step)
        accum += step
      end
      
      raise Errno::ETIMEDOUT if accum >= step
    }
    
    raise 'Union Station is not running.' if pid.nil?
    
    # Try to gracefully end it with SIGTERM, then resort to SIGKILL
    begin
      Process.kill('TERM', pid)
      wait_process.call(pid, timeout)
    rescue Errno::ESRCH
      raise 'Union Station is not running or PID is invalid.'
    rescue Errno::ETIMEDOUT
      begin
        Process.kill('KILL', pid)
        wait_process.call(pid, timeout)
        return false
      rescue Errno::ETIMEDOUT
        raise 'Could not stop Union Station, even with SIGKILL!'
      rescue Errno::ESRCH
        true
      end
    end
    
    true
  end
  
  # Registers a protocol. See Server::register_protocol! for arguments.
  def self.protocol(name, parent)
    Server.register_protocol!(name, parent)
  end
end

US = UnionStation