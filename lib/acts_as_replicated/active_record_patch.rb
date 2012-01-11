module ActsAsReplicated
  module ActiveRecordPatch
    def self.included(base)
      base.class_eval do
        private
        def self.relation
          if @relation && @relation.instance_of?( ActiveRecord::Relation )
            @relation = ActiveRecord::PatchedRelation.new(self, arel_table)
          else
            @relation ||= ActiveRecord::PatchedRelation.new(self, arel_table)
          end
          finder_needs_type_condition? ? @relation.where(type_condition) : @relation
        end
      end
    end
  end

  class LdapSearchAdapter
    attr_accessor :conditions, :klass

    def perform
      lsvp = LdapSearchValuesParser.new(conditions, klass)
      ldap_entries = klass.ldap.search(lsvp.ldap_conditions)
      ids = ldap_entries.map{ |entry| entry.uid.first }

      mysql_conditions = lsvp.mysql_conditions.merge({:id => ids})
      klass.where(mysql_conditions)
    end

  end

  class LdapSearchValuesParser
    extend ActiveSupport::Memoizable
    attr_accessor :klass, :conditions

    def initialize(conditions, klass)
      @conditions = conditions
      @klass = klass
    end

    def ldap_conditions
      c = {}
      ldap_attrs.each do |attr|
        c.merge!({attr => conditions[attr.to_s]})
      end
      c
    end
    memoize :ldap_conditions

    def mysql_conditions
      c = {}
      mysql_attrs.each do |attr|
        c.merge!({attr => conditions[attr.to_s]})
      end
      c
    end
    memoize :mysql_conditions

    def ldap_attrs
      @ldap_attrs ||= klass.ldap.mappings.keys.map(&:to_sym) & conditions.keys.map(&:to_sym)
    end

    def mysql_attrs
      @mysql_attrs ||= conditions.keys.map(&:to_sym) - ldap_attrs
    end
  end
end

module ActiveRecord
  class PatchedRelation < Relation
    def to_a
      if ldap_fields.blank?
        super
      else
        lsa = ActsAsReplicated::LdapSearchAdapter.new
        lsa.conditions = self.where_values_hash
        lsa.klass = klass
        lsa.perform
      end
    end

    private

    def ldap_fields
      self.ldap.mappings.keys.map & self.where_values_hash.keys.map(&:to_sym)
    end
  end
end
