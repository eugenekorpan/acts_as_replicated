module ActsAsReplicated
  module InstanceMethods

    def initialize *args, &block
      @ldap_object = klass.ldap.ldap_object_instance
      super
    end

    def klass
      self.class
    end

    def net_ldap_dn
      Net::LDAP::DN.new(*dn)
    end

    def dn
      return nil if new_record?
      ["uid", id.to_s] + klass.ldap.dn
    end

    def with_ldap_object
      self.ldap_object = klass.ldap.ldap_object_instance unless self.ldap_object
      yield
    end

    def reload
      ldap_object.reload
      super
    end

  end
end
