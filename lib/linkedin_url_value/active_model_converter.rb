# frozen_string_literal: true

require "sorbet-runtime"

module LinkedinUrlValue
  class ActiveModelConverter < ActiveModel::Type::Value
    extend T::Sig

    sig { params(value: T.untyped).returns(T.any(AsBlank, Exceptional, Regular)) }
    def cast(value)
      LinkedinUrlValue.cast(value)
    end

    sig { params(value: T.untyped).returns(String) }
    def serialize(value)
      value.to_s
    end
  end
end
