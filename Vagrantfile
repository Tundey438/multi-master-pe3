Vagrant.configure("2") do |config|
  {
    'mcp' => '10.12.0.2',
    'm1'  => '10.12.0.3',
    'm2'  => '10.12.0.4',
    'm3'  => '10.12.0.5',
  }.each do |osname, ip|
    config.vm.define osname do |node|
      node.vm.box = "centos-64-x64-vbox4210-nocm"
      node.vm.host_name = "#{osname}.puppetlabs.vm"
      node.vm.network :private_network, ip: ip
      node.vm.provision :shell do |shell|
        shell.path = 'provision.sh'
      end
    end
  end
end
