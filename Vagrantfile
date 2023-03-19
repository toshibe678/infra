VAGRANTFILE_API_VERSION = "2"

# vagrant up時にプラグインを自動でインストールしたい場合に使用する。
def install_plugin(plugin)
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

# ファイルシステムのマウント用プラグイン入れる
install_plugin "vagrant-vbguest"

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"

  config.vm.hostname = "dev.test"

  # ip 設定
  config.vm.network "private_network", ip: "192.168.254.100"

  # VirtualboxのGUI上で見える名前など設定
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
    v.name = "infra-server"
  end
  # ホスト上のフォルダをVMにマウントする。
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox", owner: 'vagrant', group: 'vagrant', mount_options: ['dmode=776', 'fmode=775']
  config.vm.synced_folder ".", "/app", type: "virtualbox", owner: 'vagrant', group: 'vagrant', mount_options: ['dmode=776', 'fmode=775']

  # 初回時にコマンド実行したい場合にここに追記してください
  config.vm.provision "shell", inline: <<-SHELL
    apt update && apt upgrade -y && apt install -y ansible sshpass
    echo "127.0.0.1 dev.test" >> /etc/hosts
  SHELL

#   # ansibleで設定行う
#   config.vm.provision "ansible_local", run: "always" do |ansible|
#     ansible.limit = "dev"
#     ansible.galaxy_role_file = "./ansible/requirements.yml"
#     ansible.galaxy_roles_path = './ansible/roles'
#     ansible.inventory_path = "./ansible/hosts_all.yml"
#     ansible.playbook = "./ansible/all.yml"
#     # Ansible Vault を使う場合は以下の行を追加
#     ansible.vault_password_file = "./ansible/.ansible_vault_pass"
#   end

  # OS共通でコマンド実行したい場合にここに追記してください
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    echo "Start of the command always executed at the end"
  SHELL
end
