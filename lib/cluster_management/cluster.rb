class ClusterManagement::Cluster      
  class Services < BasicObject
    def initialize
      @h = ::Hash.new do |h, service_name|        
        h[service_name] = ::ClusterManagement::Service.service_class(service_name).new
      end
    end
    
    def [] service_name
      raise 'service_name not a Symbol' if service.class != Symbol
      @h[service_name.to_sym]
    end        
    
    protected
      def p msg
        ::Object.send :p, msg
      end
      
      def method_missing m
        @h[m]
      end
  end

  def initialize 
    @services = Services.new
        
    @boxes = Hash.new do |h, host|
      if config.ssh.include? host
        # check for custom ssh config
        box = Box.new(host.to_s, config.ssh[host])
      else
        # use global ssh config
        # OR use only the host
        box = config.ssh ? Box.new(host.to_s, config.ssh) : Box.new(host.to_s)
      end
      box.open
      h[host] = box
    end
  end
  
  attr_reader :boxes
  
  def services &b
    b ? @services.instance_eval(&b) : @services
  end
  
  attr_writer :config, :logger
  def config; @config || raise("config not defined!") end
  def logger; @logger || raise("logger not defined!") end
end
