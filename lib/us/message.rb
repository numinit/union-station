require 'syslog'
require 'json'
require 'uuidtools'

module UnionStation
  # Abstracts a single Union Station message.
  class Message
    EMERGENCY = Syslog::LOG_EMERG
    EMERG = Syslog::LOG_EMERG
    ALERT = Syslog::LOG_ALERT
    CRITICAL = Syslog::LOG_CRIT
    CRIT = Syslog::LOG_CRIT
    ERROR = Syslog::LOG_ERR
    ERR = Syslog::LOG_ERR
    WARNING = Syslog::LOG_WARNING
    WARN = Syslog::LOG_WARNING
    NOTICE = Syslog::LOG_NOTICE
    INFO = Syslog::LOG_INFO
    DEBUG = Syslog::LOG_DEBUG
    
    attr_reader :channel, :body, :level, :timestamp, :uuid
  
    # Creates a new Message object from some raw JSON data.
    # This JSON data is sent by applications that are connected to us.
    # There really aren't a lot of JSON keys to send. Here they are:
    #
    # +channel+: a unique name for this logging channel
    #
    # +level+: the log level, one of:
    # * 0: LOG_EMERG
    # * 1: LOG_ALERT
    # * 2: LOG_CRIT
    # * 3: LOG_ERR
    # * 4: LOG_WARNING
    # * 5: LOG_NOTICE
    # * 6: LOG_INFO
    # * 7: LOG_DEBUG
    # +body+: any message to send
    # 
    # At a bare minimum, the client must send the message body and its channel.
    # Level defaults to INFO.
    def self.from_json(json)
      obj = JSON.parse(json, :symbolize_names => true)
      self.new(obj[:channel], obj[:body], obj[:level])
    end
    
    # Creates a new message with the specified arguments.
    def initialize(channel, body, level = nil)      
      raise 'channel not provided' if channel.nil? || channel.empty?
      raise 'message body not provided' if body.nil?
      @channel, @body, @level, @timestamp, @uuid = channel, body, level || INFO, Time.now, UUIDTools::UUID.timestamp_create
    end
    
    # Dumps the current object to JSON.
    def to_json
      {:channel => @channel, :level => @level, :body => @body, :timestamp => (@timestamp.to_f * 1000).to_i, :uuid => @uuid.to_s}.to_json
    end
  end
end