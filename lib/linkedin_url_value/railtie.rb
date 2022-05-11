# frozen_string_literal: true

unless defined?(ValueValidator)
  require "rails_values/value_validator"
  ValueValidator = RailsValues::ValueValidator
end

module LinkedinUrlValue
  class Railtie < ::Rails::Railtie
    initializer "rails_values_railtie.configure_rails_initialization" do
      require_relative "job_serializer"
      Rails.application.config.active_job.custom_serializers << JobSerializer

      require "rails_values/simple_string_converter"
      ActiveRecord::Type.register(:rv_linkedin_url_value) do
        RailsValues::SimpleStringConverter.new(LinkedinUrlValue)
      end
    end
  end
end
