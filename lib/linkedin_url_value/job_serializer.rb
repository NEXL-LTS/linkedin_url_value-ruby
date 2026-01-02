# frozen_string_literal: true

module LinkedinUrlValue
  class JobSerializer < ActiveJob::Serializers::ObjectSerializer
    def klass
      LinkedinUrlValue::Regular
    end

    def serialize?(argument)
      argument.is_a?(klass)
    end

    def serialize(value)
      super("value" => value.to_str)
    end

    def deserialize(hash)
      LinkedinUrlValue.cast(hash["value"])
    end
  end
end
