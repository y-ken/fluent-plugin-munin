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
    config_param :convert_type, :string, :default => 'no'
    config_param :record_hostname, :string, :default => nil

    def configure(conf)
      super

      @interval = Config.time_value(@interval)
      @nest_result = Config.bool_value(@nest_result) || false
      @convert_type = Config.bool_value(@convert_type) || false
      @record_hostname = Config.bool_value(@record_hostname) || false

      self
    end

    def configure_munin
      retry_interval = 30
      max_retry_interval = retry_interval * 2 ** (8 - 1)
      begin
        @munin = get_connection
        @hostname = @munin.nodes.join(',')
        service_list = get_service_list
        @services = @service == 'all' ? service_list : @service.split(',')
        $log.info "munin: munin-node ready ", :hostname=>@hostname, :service_list=>service_list
        $log.info "munin: activating service ", :service=>@services
      rescue => e
        $log.warn "munin: connect failed ",  :error_class=>e.class, :error=>e.message, :retry_interval=>retry_interval
        sleep retry_interval
        retry_interval *= 2 if retry_interval < max_retry_interval
        retry
      end
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
      configure_munin
      loop do
        emit_collected_service
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
      @munin = get_connection
      return @munin.list
    end

    def emit_collected_service
      @services.each do |key|
        tag = "#{@tag_prefix}.#{key}".gsub(/(\${[a-z]+}|__[A-Z]+__)/, get_placeholder)
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
      rescue => e
      $log.warn "munin: fetch failed ",  :error_class=>e.class, :error=>e.message
    end

    def fetch(key)
      @munin = get_connection
      values = @munin.fetch(key)
      return convert_type(values[key]) if @convert_type
      return values[key]
    end

    def convert_type(ary)
      data = Hash.new
      ary.each do |key,value|
        if value == value.to_f.to_s
          data.store(key, value.to_f)
        elsif value == value.to_i.to_s
          data.store(key, value.to_i)
        else
          data.store(key, value)
        end
      end
      return data
    end
    
    def get_placeholder
      return {
        '__HOSTNAME__' => @hostname,
        '${hostname}' => @hostname,
      }
    end
  end
end
