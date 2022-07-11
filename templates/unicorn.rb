require "coalla-deploy/unicorn"
application_name = (ENV['RAILS_ENV'] == 'production') ? 'coalla.ru' : 'test.coalla.ru'
Coalla::Unicorn.init(self, deploy_to: "/var/www/virtual-hosts/#{application_name}",
                     timeout: 30,
                     worker_processes: 1)