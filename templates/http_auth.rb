module Coalla
  module HttpAuth
    extend ActiveSupport::Concern

    included do
      before_action do
        if ::Rails.env.staging?
          authenticate_or_request_with_http_basic do |username, password|
            username == 'demo' && password == '1qaz3edc'
          end
        end
      end
    end

  end
end

ApplicationController.send(:include, Coalla::HttpAuth)