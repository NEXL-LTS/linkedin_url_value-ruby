# frozen_string_literal: true

require "rails_values"

module LinkedinUrlValue
  class Railtie < ::Rails::Railtie
    initializer "rails_values_railtie.configure_rails_initialization" do
      require_relative "job_serializer"
      Rails.application.config.active_job.custom_serializers << JobSerializer

      require_relative "active_model_converter"
      ActiveRecord::Type.register(:rv_linkedin_url_value) { ActiveModelConverter.new }
    end
  end
end
