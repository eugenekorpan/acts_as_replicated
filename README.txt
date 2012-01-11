Usage:
  
  OpenDS server sample:

  acts_as_replicated do |conf|
    conf.map :first_name => :givenName
    conf.map :last_name  => :sn
    conf.map :city       => :l

    conf.set_connection({
      :host => "localhost",
      :port => 1389,
      :auth => {
            :method   => :simple,
            :username => "cn=Directory Manager",
            :password => "111111"
       }
    })

    conf.dn                    = ["ou", "users", "dc", "acts_as_replicated", "dc", "com"]
    conf.object_classes        = [:top, :inetOrgPerson]
    conf.common_name_attribute = :full_name
  end
