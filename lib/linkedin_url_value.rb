# frozen_string_literal: true

require "active_support"
require "active_model"
require "rails_values/whole_value_concern"
require "rails_values/exceptional_value"

module LinkedinUrlValue
  class Error < StandardError; end

  module Base
    include RailsValues::WholeValueConcern
    include Comparable

    def initialize(val)
      @raw_value = val
    end

    def <=>(other)
      return to_str <=> other.to_s if other.nil?

      to_str <=> LinkedinUrlValue.cast(other).to_str
    end

    def eql?(other)
      self == other
    end

    def hash
      to_str&.hash || @raw_value.hash
    end

    def to_str
      @raw_value.to_str
    end

    def to_s
      to_str
    end
  end

  class AsBlank
    include Base

    def blank?
      true
    end

    def to_str
      ""
    end
  end

  class Exceptional
    include Base

    attr_reader :reason

    def initialize(raw_value, reason = "has a invalid value of #{raw_value}")
      @raw_value = raw_value
      @reason = reason
    end

    def exceptional?
      true
    end

    def regular?
      false
    end

    def exceptional_errors(errors, attribute, _options = nil)
      errors.add(attribute, @reason)
    end
  end

  class Regular
    include Base
  end

  def self.cast(val)
    return val if val.is_a?(Base)
    return AsBlank.new(val) if val.blank?

    cleaned_url = clean_url(val)
    return Regular.new(cleaned_url) if cleaned_url.include?("https://www.linkedin.com/in/")

    Exceptional.new(val)
  rescue URI::InvalidURIError
    Exceptional.new(val)
  end

  def self.clean_url(url)
    url = "https://www.#{url}" if url.to_str.start_with?("linkedin.com")

    url = url.to_s.downcase.gsub("http://", "https://")
             .gsub(/\w+\.linkedin/, "www.linkedin")
             .gsub("https://linkedin.com", "https://www.linkedin.com")
             .chomp("/")

    uri = URI(url)
    uri.query = nil
    uri.fragment = nil
    uri.to_s
  end
end

require_relative "linkedin_url_value/railtie" if defined?(Rails) && defined?(Rails::Railtie)
