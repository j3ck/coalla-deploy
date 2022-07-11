# Rails assets pipeline
load 'deploy/assets'

set :stages, %w(staging production)
require 'capistrano/ext/multistage'

set :repository, 'http://git.coalla.ru/coalla.git'
ssh_options[:port] = 60000
set :user, 'deployer'
set(:deploy_to) { "/var/www/virtual-hosts/#{application}" }
set(:unicorn_service) { "/etc/init.d/unicorn-#{application}" }
set :use_whenever, File.exists?(File.join(File.expand_path('..', File.dirname(__FILE__)), 'config', 'schedule.rb'))
set :use_sphinx, File.exists?(File.join(File.expand_path('..', File.dirname(__FILE__)), 'config', 'thinking_sphinx.yml'))
set :use_delayed_job, File.exists?(File.join(File.expand_path('..', File.dirname(__FILE__)), 'bin', 'delayed_job'))

# RVM configuration
require 'rvm/capistrano'
set :rvm_type, :system
set :rvm_ruby_string, '2.0.0'

default_run_options[:pty] = true
set :scm, :git
set :deploy_via, :copy
set :keep_releases, 3

desc 'Make symlink'
task :make_symlink, :roles => :app do
  run "ln -nfs #{shared_path}/system/uploads #{release_path}/public/uploads"
end

desc 'Make a symlink to robots.txt according to rails_env'
task :symlink_robots_txt, :roles => :app do
  run "ln -nfs #{release_path}/config/deploy/#{rails_env}/robots.txt #{release_path}/public/robots.txt"
end

after 'deploy:create_symlink', :make_symlink

# Removed 'deployment' flag, cause it needs Gemfile.lock exists in repository
# This can't be done due to Windows problems with nokogiri, ImageMagick etc
set :bundle_flags, '--quiet'
require 'bundler/capistrano'

# Unicorn recipe
namespace :deploy do
  task :restart, roles: :app, except: {no_release: true} do
    run "sudo #{unicorn_service} upgrade"
  end

  task :sudo_migrate do
    run("cd #{deploy_to}/current && rvmsudo -u www-data bundle exec rake db:migrate RAILS_ENV=#{rails_env}")
  end
end

# Sitemap copy
after 'deploy:update_code', 'deploy:copy_old_sitemap'
after 'deploy:update_code', :symlink_robots_txt
namespace :deploy do
  task :copy_old_sitemap do
    run "if [ -e #{previous_release}/public/sitemap.xml.gz ]; then cp #{previous_release}/public/sitemap* #{current_release}/public/; fi"
  end
end

# Backup database
require 'yaml'
task :backup_database, :roles => :db do
  if previous_release
    db = YAML::load(ERB.new(IO.read(File.join(File.expand_path('..', File.dirname(__FILE__)), 'config', 'database.yml'))).result)["#{rails_env}"]
    run "export PGPASSWORD='#{db['password']}' && pg_dump --username=#{db['username']} --format=custom --file=#{File.join(previous_release, 'db.backup')} #{db['database']} --host=#{db['host']}"
  end
end

task :update_gemfile, :roles => :app do
  run "cat #{current_release}/Gemfile.linux >> #{current_release}/Gemfile"
end

set :use_sudo, false
after :deploy, 'deploy:cleanup'
before 'deploy:restart', 'deploy:sudo_migrate'
after 'deploy:update_code', :backup_database
before 'bundle:install', :update_gemfile

after 'deploy:assets:precompile' do
  run "cd #{release_path} && bundle exec rake tmp:cache:clear RAILS_ENV=#{rails_env}"
  run "cd #{release_path} && bundle exec rake assets:non_digested RAILS_ENV=#{rails_env}"
end

if use_whenever
  set :whenever_command, "rvm use #{rvm_ruby_string} && bundle exec whenever"
  set :whenever_environment, defer { stage }
  require 'whenever/capistrano'
end

if use_sphinx

  require 'thinking_sphinx/capistrano'

# Sphinx Recipes
  namespace :thinking_sphinx do

    def rake(*tasks)
      rake = fetch(:rake, 'rake')
      tasks.each do |t|
        run "if [ -d #{release_path} ]; then cd #{release_path}; else cd #{current_path}; fi; rvmsudo -u www-data #{rake} RAILS_ENV=#{rails_env} #{t}"
      end
    end

    desc 'Symlink Sphinx indexes'
    task :symlink_indexes, roles: [:app] do
      run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
    end

  end

# Sphinx Steps
  after 'deploy:sudo_migrate', 'thinking_sphinx:stop'
  after 'deploy:sudo_migrate', 'thinking_sphinx:index'
  after 'deploy:sudo_migrate', 'thinking_sphinx:start'
  after 'deploy:finalize_update', 'thinking_sphinx:symlink_indexes'

end

# Delayed job
if use_delayed_job

  require 'delayed/recipes'

  set(:delayed_job_command) { "rvmsudo -u www-data RAILS_ENV=#{fetch(:rails_env)} bundle exec bin/delayed_job" }
  after 'deploy:stop', 'delayed_job:stop'
  after 'deploy:start', 'delayed_job:start'
  after 'deploy:restart', 'delayed_job:restart'

end