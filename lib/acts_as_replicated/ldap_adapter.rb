require "net/ldap/filter"

module ActsAsReplicated
  class LdapAdapter
    attr_accessor :mappings, :connection, :dn, :object_classes, :common_name_attribute 

    def initialize klass
      @klass = klass
      @klass.send :attr_accessor, :ldap_object
      @connection = Connection.new
      @mappings = Hash.new
      @ldap_class = Object.const_set("#{@klass}LdapObject", Class.new)
      @ldap_class.send :include, LdapObjectInstanceMethods
      @ldap_class.send :attr_accessor, :ar_object, :ldap_adapter
    end

    def map mapping
      self.mappings.merge! mapping

      attribute = mapping.keys.first
      @ldap_class.send :attr_accessor, attribute

      @klass.send :delegate, attribute, :to => :ldap_object
      @klass.send :delegate, "#{attribute}=", :to => :ldap_object
    end

    def set_connection opts
      self.connection.init(opts)
    end

    def ldap_object_instance
      instance = @ldap_class.new
      instance.ldap_adapter = self
      instance
    end

    def search(criteria)
      ldap_adapted_criteria = convert_criteria(criteria)
      filter = build_filter(ldap_adapted_criteria)
      result = connection.search(:filter => filter, :base => escaped_dn)
      raise connection.binding.get_operation_result.message unless result
      result
    end

    private

    def escaped_dn
      Net::LDAP::DN.new(*dn).to_s
    end

    def convert_criteria args
      result = {}
      args.each do |k, v|
        result.merge!({@mappings[k] => v})
      end
      result
    end

    # args:
    #   {:first_name => name, :last_name => [name1, name2]}
    def build_filter(args)
      and_filters = []
      args.each do |k, v|
        if v.instance_of? Array
          or_filters = []
          v.each do |value|
            or_filters.push(Net::LDAP::Filter.eq(k.to_s, value.to_s))
          end
          filter = or_filters.shift
          or_filters.each { |f| filter = filter | f }
          and_filters.push(filter)
        else
          and_filters.push(Net::LDAP::Filter.eq(k.to_s, v.to_s))
        end
      end
      filter = and_filters.shift
      and_filters.each { |f| filter = filter & f }
      filter
    end
  end
end
