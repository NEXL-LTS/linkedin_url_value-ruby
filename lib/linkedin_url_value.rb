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
    url = prepend_correct_protocol(url.to_str)

    url = url.to_s.downcase.gsub(/\w+\.linkedin/, "www.linkedin").chomp("/")

    return url unless url.to_str.start_with?("https://www.linkedin.com/in/")

    uri = URI(safe_encode(url))
    uri.query = nil
    uri.fragment = nil
    uri.to_s.downcase
  end

  def self.prepend_correct_protocol(url)
    url = "https://#{url}" if url.start_with?("www.linkedin.com")
    url = "https://www.#{url}" if url.start_with?("linkedin.com")
    url = "https://www.#{url}" if url.start_with?("linkedin.com")

    url.gsub("http://", "https://")
       .gsub("https://linkedin.com", "https://www.linkedin.com")
  end

  def self.safe_encode(url)
    path = url.gsub("https://www.linkedin.com/in/", "")
    path = path.split("/").first(1).map { |p| URI.encode_www_form_component(p) }.join("/")
    ["?", "=", "#", "%"].each do |c|
      path = path.gsub(URI.encode_www_form_component(c), c)
    end
    "https://www.linkedin.com/in/#{path}"
  end
end

require_relative "linkedin_url_value/railtie" if defined?(Rails) && defined?(Rails::Railtie)
