require 'rails'

module Coalla

  module Deploy

    module Generators

      class InitGenerator < ::Rails::Generators::Base

        source_root File.expand_path('../../../../../../templates', __FILE__)

        def copy_build_scripts
          copy_file 'build-production.sh', 'build-production.sh'
          copy_file 'build-staging.sh', 'build-staging.sh'
          copy_file 'Capfile', 'Capfile'
          copy_file 'Gemfile.linux', 'Gemfile.linux'
          copy_file 'unicorn.rb', 'config/unicorn.rb'
          copy_file 'deploy.rb', 'config/deploy.rb'
          copy_file 'assets.rake', 'lib/tasks/assets.rake'
          copy_file 'staging.rb', 'config/deploy/staging.rb'
          copy_file 'production.rb', 'config/deploy/production.rb'
          copy_file 'http_auth.rb', 'config/initializers/http_auth.rb'
        end
      end

    end
  end

end