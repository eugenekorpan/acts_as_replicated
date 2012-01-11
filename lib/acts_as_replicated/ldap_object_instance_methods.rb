module ActsAsReplicated
  module LdapObjectInstanceMethods

    def find
      binding.search({:base => ar_object.net_ldap_dn}).first
    end

    def create
      result = binding.add(:dn => ar_object.net_ldap_dn, :attributes => attributes)
      raise binding.get_operation_result.message unless result
    end

    def update
      ops = ldap_adapter.mappings.collect do |obj_attr, ldap_attr|
        value = self.send(obj_attr)
        if value.blank?
          [:delete, ldap_attr, nil]
        else
          [:replace, ldap_attr, value]
        end
      end
      result = binding.modify(:dn => ar_object.net_ldap_dn, :operations => ops)
      raise binding.get_operation_result.message unless result
    end

    def destroy
      result = binding.delete :dn => ar_object.net_ldap_dn
      raise binding.get_operation_result.message unless result
    end

    def load
      reload!
    end

    def reload!
      return if ar_object.blank? || ar_object.new_record?
      return unless present?
      write_attributes(find)
      true
    end

    alias_method :reload, :reload!

    def attributes
      attrs = {}
      ldap_adapter.mappings.each do |obj_attr, ldap_attr|
        attrs.merge!({ldap_attr => self.send(obj_attr)})
      end
      attrs[:objectClass] = ldap_adapter.object_classes.map(&:to_s)
      attrs[:cn] = ar_object.send(ldap_adapter.common_name_attribute) if ar_object
      attrs
    end

    private

    def write_attributes entry
      ldap_adapter.mappings.each do |obj_attr, ldap_attr|
        attr_value = entry[ldap_attr].first
        self.send("#{obj_attr}=", attr_value)
      end
    end

    def present?
      find
    end

    def binding
      ldap_adapter.connection.binding
    end

  end
end
