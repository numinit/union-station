#     __  __       _               _____ __        __  _
#    / / / /____  (_)____  ____   / ___// /_____ _/ /_(_)____  ____
#   / / / // __ \/ // __ \/ __ \  \__ \/ __/ __ `/ __/ // __ \/ __ \
#  / /_/ // / / / // /_/ / / / / ___/ / /_/ /_/ / /_/ // /_/ / / / /
#  \____//_/ /_/_/ \____/_/ /_/ /____/\__/\__,_/\__/_/ \____/_/ /_/
#            Established 1914 in Denver, CO - Travel by Rails today!

require 'eventmachine'

require 'us/server.rb'
require 'us/message.rb'

# The main Union Station module.
# Everything related to Union Station is contained within here!
# This project was inspired by {BlodeJS}[https://github.com/benlemasurier/blode].
module UnionStation
  # Starts Union Station as a daemon.
  #
  # Takes :host and :port as arguments. If :socket is provided, a Unix
  # socket will be used. This takes precedence over any other arguments.
  # This method will raise an error from EventMachine if the address or socket
  # is already in use.
  # 
  # Defaults:
  #
  # * Host: 127.0.0.1
  # * Port: 1894
  # * Socket: nil
  def self.start!(args = {})
    args[:host] ||= '127.0.0.1'
    args[:port] ||= 1894
    args[:host] = args[:socket] if !args[:socket].nil? && !args[:socket].empty?
    
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
  # in UnionStation::start, or the provided PID. This method will attempt to
  # stop the daemon nicely using SIGTERM, and will resort to SIGKILL if it
  # doesn't stop within the timeout. Timeout value is given in seconds, and
  # defaults to 3.00.
  #
  # This method will raise a RuntimeError if Union Station is not running or
  # if even SIGKILL failed.
  # 
  # Returns true if Union Station was terminated
  # successfully, false if it had to be killed.
  def self.stop!(pid = nil, timeout = 3.00)
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
      end
    end
    
    true
  end
end
