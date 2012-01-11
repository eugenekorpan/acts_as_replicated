require "active_record"
require "net/ldap"
require "net/ldap/dn"
require "acts_as_replicated/version"
require "acts_as_replicated/callbacks"
require "acts_as_replicated/connection"
require "acts_as_replicated/ldap_adapter"
require "acts_as_replicated/instance_methods"
require "acts_as_replicated/ldap_object_instance_methods"
require "acts_as_replicated/active_record_patch"

module ActsAsReplicated

  def acts_as_replicated
    self.class_attribute :ldap

    self.ldap = LdapAdapter.new(self)
    yield(self.ldap)

    self.send(:include, Callbacks)
    self.send(:include, InstanceMethods)
    self.send(:include, ActiveRecordPatch)
  end
  
end

ActiveRecord::Base.send :extend, ActsAsReplicated
