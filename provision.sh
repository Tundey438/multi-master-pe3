#!/bin/sh


if service iptables status > /dev/null ; then
  echo 'Disable iptables'
  service iptables stop
  chkconfig iptables off
fi

# Update DNS
cat > /etc/hosts <<EOF
127.0.0.1 localhost localhost.localdomain
10.12.0.2 mcp mcp.puppetlabs.vm
10.12.0.3 m1 m1.puppetlabs.vm
10.12.0.4 m2 m2.puppetlabs.vm
10.12.0.5 m3 m3.puppetlabs.vm
EOF

if [ ! -d /opt/puppet ] ; then
  /vagrant/pe3/puppet-enterprise-installer -a /vagrant/answers/`hostname -s`.answers
fi

sed /etc/puppetlabs/puppet/puppet.conf -i -e 's^modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^modulepath = /vagrant:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules^'
mv /opt/puppet/share/puppet/modules/pe_mcollective /tmp

if [ $(hostname -s) = 'mcp' ] ; then
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:add name=m1 groups=puppet_master
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:add name=m2 groups=puppet_master
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:add name=m3 groups=puppet_master
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production nodegroup:variables name=puppet_master variables='activemq_network_ttl=3'
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:variables name=mcp variables='activemq_brokers=m1'
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:variables name=m1 variables='activemq_brokers=m2'
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:variables name=m2 variables='activemq_brokers=m3'
  /opt/puppet/bin/puppet apply -e 'include pe_shared_ca::update_module'
  service pe-puppet stop && service pe-httpd reload && sleep 10 && /opt/puppet/bin/puppet agent -t && sleep 10 && /opt/puppet/bin/puppet agent -t ; exit 0
  echo -e 'pe-internal-dashboard\nmcp\nm1\nm2\nm3' >> /etc/puppetlabs/puppetdb/certificate-whitelist && /sbin/service pe-puppetdb restart
else
  /opt/puppet/bin/puppet apply /vagrant/pe_shared_ca/usage/is_ca_server.pp
  /opt/puppet/bin/puppet cert generate $(hostname -s) --dns_alt_names $(hostname -s),puppet && service pe-httpd start && /opt/puppet/bin/puppet agent -t ; exit 0
fi

sleep 10 && sudo -i -u peadmin mco ping
