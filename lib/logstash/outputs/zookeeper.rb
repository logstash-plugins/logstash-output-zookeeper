# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "zk"

# An output plugin that send data to zookeeper.
class LogStash::Outputs::Zookeeper < LogStash::Outputs::Base
  config_name "zookeeper"

  default :codec, 'plain'
  
  # This is the zookeeper ip list.
  # The format is `host1:port1,host2:port2`
  config :ip_list, :validate => :string, :default => "localhost:2181"
  
  # The znode path you want to write.
  # If the path not exist, we will create it. 
  config :path, :validate => :string, :default => "/logstash"

  # Znode we created is permanent or ephemeral.
  config :ephemeral, :validate => :boolean, :default => false

  public
  def register
    @zk = ZK.new(@ip_list)

    if @zk.exists?(@path) == false
      if ephemeral == true
        @zk.create(@path, '', :mode => :ephemeral)
      else
        @zk.create(@path, '')
      end
    end

    @codec.on_event do |event, data|
      begin
        @zk.set(@path, data)
        rescue LogStash::ShutdownSignal
          @logger.info('Zookeeper plugin got shutdown signal')
        rescue => e
          # May raise ZK::Exceptions::NoNode or ZK::Exceptions::BadVersion
          @logger.warn('Zookeeper threw exception, restarting', :exception => e)
      end
    end
  end # def register

  public
  def receive(event)
    if event == LogStash::SHUTDOWN
      return
    end
    @codec.encode(event)
  end # def event
end # class LogStash::Outputs::Zookeeper
