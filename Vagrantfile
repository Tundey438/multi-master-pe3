Vagrant.configure("2") do |config|
  config.vm.box = "centos-64-x64-vbox4210-nocm"


  # Need to classify m1/m2 with the other classes and activemq_brokers
  config.vm.define 'mcp' do |node|
    node.vm.hostname = 'mcp'
    node.vm.network :forwarded_port, guest: 443, host: 4443
    node.vm.network :private_network, :ip => '10.12.0.2'
    # No firewall please
    node.vm.provision :shell, :inline => "/sbin/service iptables stop"
    # Update DNS
    node.vm.provision :shell, :inline => "/bin/echo -e '127.0.0.1 localhost localhost.localdomain\n10.12.0.2 mcp\n10.12.0.3 m1\n10.12.0.4 m2\n10.12.0.5 m3' > /etc/hosts"
    # Install PE as all-in-one
    node.vm.provision :shell, :inline => "/vagrant/pe3/puppet-enterprise-installer -a /vagrant/answers/mcp.answers"
    # Classify m1 host
    node.vm.provision :shell, :inline => "/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:add name=m1 groups=puppet_master"
    # Classify m2 host
    node.vm.provision :shell, :inline => "/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:add name=m2 groups=puppet_master"
    # Classify m3 host
    node.vm.provision :shell, :inline => "/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:add name=m3 groups=puppet_master"
    # Classify m1/m2 as brokers
    node.vm.provision :shell, :inline => "/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:variables name=mcp variables='activemq_brokers=m1\\,m2'"
    # Add mcp & m3 as brokers of m2
    node.vm.provision :shell, :inline => "/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:variables name=m2 variables='activemq_brokers=m3'"
    # Update the modulepath to include /vagrant for pe_mcollective
    node.vm.provision :shell, :inline => "sed /etc/puppetlabs/puppet/puppet.conf -i -e 's^modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^modulepath = /vagrant:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^'"
    # Move the current pe_mcollective module away
    node.vm.provision :shell, :inline => "/bin/mv /opt/puppet/share/puppet/modules/pe_mcollective /tmp"
    # Populate the pe_shared_ca module for m1/m2 nodes
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet apply --modulepath /vagrant:/opt/puppet/share/puppet/modules /vagrant/pe_shared_ca/usage/update_module.pp"
    # Cause a puppet run to happen, even if one is currently in progress
    node.vm.provision :shell, :inline => "/sbin/service pe-puppet stop && /sbin/service pe-httpd reload && sleep 10 && /opt/puppet/bin/puppet agent -t && sleep 10 && /opt/puppet/bin/puppet agent -t ; exit 0"
    # Allow m1/m2 to save to puppetdb
    node.vm.provision :shell, :inline => "/bin/echo -e 'm1\nm2\nm3' >> /etc/puppetlabs/puppetdb/certificate-whitelist && /sbin/service pe-puppetdb restart"
  end
  config.vm.define 'm1' do |node|
    node.vm.hostname = 'm1'
    node.vm.network :private_network, :ip => '10.12.0.3'
    # No firewall please
    node.vm.provision :shell, :inline => "/sbin/service iptables stop"
    # Update DNS
    node.vm.provision :shell, :inline => "/bin/echo -e '127.0.0.1 localhost localhost.localdomain\n10.12.0.2 mcp\n10.12.0.3 m1\n10.12.0.4 m2\n10.12.0.5 m3' > /etc/hosts"
    # Install PE as master-only with mcp as puppetdb/console
    node.vm.provision :shell, :inline => "/vagrant/pe3/puppet-enterprise-installer -a /vagrant/answers/m1.answers"
    # Update the modulepath to include /vagrant for pe_mcollective
    node.vm.provision :shell, :inline => "sed /etc/puppetlabs/puppet/puppet.conf -i -e 's^modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^modulepath = /vagrant:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^'"
    # Move the current pe_mcollective module away
    node.vm.provision :shell, :inline => "/bin/mv /opt/puppet/share/puppet/modules/pe_mcollective /tmp"
    # Rebootstrap SSL certs off of mcp's CA
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet apply --modulepath /vagrant:/opt/puppet/share/puppet/modules /vagrant/pe_shared_ca/usage/is_ca_server.pp"
    # Generate new master cert for m1
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet cert generate m1 --dns_alt_names m1,puppet && /sbin/service pe-httpd start && /opt/puppet/bin/puppet agent -t ; exit 0"
  end
  config.vm.define 'm2' do |node|
    node.vm.hostname = 'm2'
    node.vm.network :private_network, :ip => '10.12.0.4'
    node.vm.provision :hosts
    # No firewall please
    node.vm.provision :shell, :inline => "/sbin/service iptables stop"
    # Update DNS
    node.vm.provision :shell, :inline => "/bin/echo -e '127.0.0.1 localhost localhost.localdomain\n10.12.0.2 mcp\n10.12.0.3 m1\n10.12.0.4 m2\n10.12.0.5 m3' > /etc/hosts"
    # Install PE as master-only with mcp as puppetdb/console
    node.vm.provision :shell, :inline => "/vagrant/pe3/puppet-enterprise-installer -a /vagrant/answers/m2.answers"
    # Update the modulepath to include /vagrant for pe_mcollective
    node.vm.provision :shell, :inline => "sed /etc/puppetlabs/puppet/puppet.conf -i -e 's^modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^modulepath = /vagrant:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^'"
    # Move the current pe_mcollective module away
    node.vm.provision :shell, :inline => "/bin/mv /opt/puppet/share/puppet/modules/pe_mcollective /tmp"
    # Rebootstrap SSL certs off of mcp's CA
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet apply --modulepath /vagrant:/opt/puppet/share/puppet/modules /vagrant/pe_shared_ca/usage/is_ca_server.pp"
    # Generate new master cert for m2
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet cert generate m2 --dns_alt_names m2,puppet && /sbin/service pe-httpd start && /opt/puppet/bin/puppet agent -t ; exit 0"
    # Test the mco ping
    node.vm.provision :shell, :inline => "sleep 10 && sudo -i -u peadmin mco ping"
  end
  config.vm.define 'm3' do |node|
    node.vm.hostname = 'm3'
    node.vm.network :private_network, :ip => '10.12.0.5'
    # No firewall please
    node.vm.provision :shell, :inline => "/sbin/service iptables stop"
    # Update DNS
    node.vm.provision :shell, :inline => "/bin/echo -e '127.0.0.1 localhost localhost.localdomain\n10.12.0.2 mcp\n10.12.0.3 m1\n10.12.0.4 m2\n10.12.0.5 m3' > /etc/hosts"
    # Install PE as master-only with mcp as puppetdb/console
    node.vm.provision :shell, :inline => "/vagrant/pe3/puppet-enterprise-installer -a /vagrant/answers/m3.answers"
    # Update the modulepath to include /vagrant for pe_mcollective
    node.vm.provision :shell, :inline => "sed /etc/puppetlabs/puppet/puppet.conf -i -e 's^modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^modulepath = /vagrant:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^'"
    # Move the current pe_mcollective module away
    node.vm.provision :shell, :inline => "/bin/mv /opt/puppet/share/puppet/modules/pe_mcollective /tmp"
    # Rebootstrap SSL certs off of mcp's CA
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet apply --modulepath /vagrant:/opt/puppet/share/puppet/modules /vagrant/pe_shared_ca/usage/is_ca_server.pp"
    # Generate new master cert for m1
    node.vm.provision :shell, :inline => "/opt/puppet/bin/puppet cert generate m3 --dns_alt_names m3,puppet && /sbin/service pe-httpd start && /opt/puppet/bin/puppet agent -t ; exit 0"
  end
end
