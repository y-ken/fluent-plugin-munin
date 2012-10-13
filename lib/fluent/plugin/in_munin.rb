module Fluent
  class MuninInput < Fluent::Input
    Plugin.register_input('munin', self)

    def initialize
      require 'munin-ruby'
      super
    end

    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 4949
    config_param :interval, :string, :default => '1m'
    config_param :tag_prefix, :string
    config_param :service, :string, :default => 'all'
    config_param :nest_result, :string, :default => nil
    config_param :nest_key, :string, :default => 'result'
    config_param :record_hostname, :string, :default => nil

    def configure(conf)
      super
      @hostname = get_munin_hostname
      @interval = Config.time_value(@interval)
      service_list = get_service_list
      @services = @service == 'all' ? service_list : @service.split(',')
      @record_hostname = Config.bool_value(@record_hostname) || false
      @nest_result = Config.bool_value(@nest_result) || false
      $log.info "munin-node connected: #{@hostname} #{service_list}"
      $log.info "following munin-node service: #{@service}"
    end

    def start
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      disconnect
      @munin.disconnect(false)
      Thread.kill(@thread)
    end

    def run
      loop do 
        @services.each do |key|
          tag = "#{@tag_prefix}.#{key}".gsub('__HOSTNAME__', @hostname).gsub('${hostname}', @hostname)
          record = Hash.new
          record.store('hostname', @hostname) if @record_hostname
          record.store('service', key)
          if (@nest_result)
            record.store(@nest_key, fetch(key))
          else
            record.merge!(fetch(key).to_hash)
          end
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

    def get_munin_hostname
      @munin ||= get_connection
      begin
        return @munin.nodes.join(',')
      rescue Munin::ConnectionError
        @munin = get_connection
        retry
      end
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
