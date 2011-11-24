require 'bundler/capistrano'

set :application, 'openfile-names'
set :repository, 'git://github.com/adamh/openfile-last-names.git'
set :deploy_to, "/home/adam/rails/#{application}"
set :scm, :git

role :app, 'web.densi.com'
role :web, 'web.densi.com'
role :db, 'web.densi.com', :primary => true

ssh_options[:keys] = "#{ENV['home']}/.ssh/id_dsa"
ssh_options[:forward_agent] = true

default_run_options[:pty] = true

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task(:precompile_assets, :roles => :web, :except => {:no_release => true}) do
    run("cd #{release_path} && bundle exec rake assets:precompile")
  end
end

after('deploy:update_code', 'deploy:precompile_assets')
after('deploy:update_code', 'deploy:cleanup')
