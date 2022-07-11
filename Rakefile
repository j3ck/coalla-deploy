require "bundler/gem_tasks"
require 'net/ssh'
require 'net/scp'
require 'fileutils'

task 'build:gem' do
  host = '5.9.118.111'
  user = 'deployer'
  Net::SSH.start(host, user, port: 60000) do |ssh|
    base_dir = "/home/#{user}/temp/coalla-gems"
    project_name = 'coalla-deploy'
    git_url = "http://git.coalla.ru/#{project_name}.git"
    gems_dir = '/var/www/virtual-hosts/gems.coalla.ru'
    output = ssh.exec! <<-SH
      mkdir --parents #{base_dir}
      cd #{base_dir}
      git clone #{git_url}
      cd #{project_name}
      source /etc/profile.d/rvm.sh
      rvm 1.9.3
      gem build coalla-deploy.gemspec
      cp -rf *.gem #{gems_dir}/gems
      cd #{gems_dir}
      source /etc/profile.d/rvm.sh
      rvm 1.9.3
      gem generate_index
      rm -R #{base_dir}
    SH
    puts output
  end
end