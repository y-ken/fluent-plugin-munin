module Fluent
  class MuninInput < Fluent::Input
    Plugin.register_input('munin', self)
    require 'munin-ruby'
    def initialize
      super
    end

    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 4949
    config_param :interval, :integer, :default => 1
    config_param :tag_prefix, :string
    config_param :service, :string, :default => nil
    config_param :record_hostname, :string, :default => nil

    def configure(conf)
      super
      service_list = get_service_list
      $log.info "munin-node provides #{service_list.inspect}"
      @services = @service.nil? ? service_list : @service.split(',')
      @record_hostname = @record_hostname || false
      @hostname = `hostname`.chomp
    end

    def start
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      disconnect
      @thread.join
    end

    def run
      loop do 
        @services.each do |key|
          tag = "#{@tag_prefix}.#{key}".gsub('__HOSTNAME__', @hostname).gsub('${hostname}', @hostname)
          record = Hash.new
          record.store('hostname', @hostname) if @record_hostname
          record.store('service', key)
          record.merge!(fetch(key).to_hash)
          Engine.emit(tag, Engine.now, record)
        end
        disconnect
        sleep @interval
      end
    end

    def get_connection
      return Munin::Node.new(@host, @port)
    end

    def disconnect
      @munin.disconnect
      @munin.connection.close
    end

    def get_service_list
      @munin ||= get_connection
      begin
        return @munin.list 
      rescue Munin::ConnectionError
        @munin = get_connection
        retry
      end
    end

    def fetch(key)
      @munin ||= get_connection
      begin
        values = @munin.fetch(key)
        return values[key]
      rescue Munin::ConnectionError
        @munin = get_connection
        retry
      end
    end
  end
end
