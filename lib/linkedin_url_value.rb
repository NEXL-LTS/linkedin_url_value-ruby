# frozen_string_literal: true

require "active_support"
require "active_model"
require "rails_values/whole_value_concern"

module LinkedinUrlValue
  class Error < StandardError; end

  class Base
    include RailsValues::WholeValueConcern
    include Comparable

    def initialize(val)
      @raw_value = val&.downcase
    end

    def <=>(other)
      return to_str <=> other.to_s if other.nil?

      to_str <=> other.to_str
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

    def inspect
      "#<#{self.class.name} val:#{@raw_value} id:#{object_id}>"
    end
  end

  class AsBlank < Base
    def blank?
      true
    end

    def to_str
      ""
    end
  end

  class Exceptional < Base
    def exceptional?
      true
    end
  end

  class Regular < Base
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

    url = url.to_s
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
