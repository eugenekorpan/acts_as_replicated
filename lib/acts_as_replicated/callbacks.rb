module ActsAsReplicated
  module Callbacks

    def self.included(base)
      base.class_eval do
        after_create     :create_ldap_entry
        after_update     :update_ldap_entry
        after_destroy    :remove_ldap_entry
        after_initialize :init_ldap_adapter

        def create_ldap_entry
          ldap_object.create
        end

        def update_ldap_entry
          ldap_object.update
        end

        def remove_ldap_entry
          ldap_object.destroy
        end

        def init_ldap_adapter
          with_ldap_object do
            self.ldap_object.ar_object = self
            self.ldap_object.reload!
          end
        end

      end
    end

  end
end
