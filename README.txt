This is very rare case when you need directory service not only to authenticate but you also store some data in it.
The idea was to patch ActiveRecord and to give developer ability to work with such kind of distributed data as with common ActiveRecord objects.

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
