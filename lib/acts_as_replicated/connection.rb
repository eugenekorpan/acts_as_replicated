module ActsAsReplicated
  class Connection
    attr_accessor :binding

    delegate :search, :to => :binding

    def init(configs)
      net_ldap = Net::LDAP.new(configs)
      test_connection(net_ldap)
    end

    def test_connection(net_ldap)
      if net_ldap.bind
        self.binding = net_ldap
      else
        raise "Could not connect to ldap server, please check your ldap server settings"
      end
    end
  end
end
