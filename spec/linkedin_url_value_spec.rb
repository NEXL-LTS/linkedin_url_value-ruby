# frozen_string_literal: true

RSpec.describe LinkedinUrlValue do
  require "rails_values/rspec/whole_value_role"

  def cast(*args)
    described_class.cast(*args)
  end

  describe "Behaves like a rails value" do
    let(:regular_value) { "https://www.linkedin.com/in/example" }
    let(:blank_value) { nil }
    let(:exceptional_value) { "http://exceptional" }

    context "when regular value" do
      subject { cast("https://www.linkedin.com/in/example") }

      it_behaves_like "Whole Value"
      it { is_expected.to be_regular }
      it { is_expected.not_to be_exceptional }
      it { is_expected.not_to be_blank }
    end

    context "when blank value" do
      subject { cast(blank_value) }

      it_behaves_like "Whole Value"

      it { is_expected.not_to be_regular }
      it { is_expected.not_to be_exceptional }
      it { is_expected.to be_blank }

      it "blank has same API as regular" do
        missing_methods = cast(regular_value).public_methods - subject.public_methods
        expect(missing_methods).to be_blank
      end
    end

    context "when exceptional value" do
      subject { cast(exceptional_value) }

      it_behaves_like "Whole Value"

      it { is_expected.not_to be_regular }
      it { is_expected.to be_exceptional }
      it { is_expected.not_to be_blank }

      it "returns exceptional if only path" do
        record = SimpleModel.new
        subject.exceptional_errors(record.errors, :email, {})
        expect(record.errors.full_messages)
          .to contain_exactly("Email has a invalid value of #{exceptional_value}")
      end

      it "blank has same API as regular" do
        missing_methods = cast(regular_value).public_methods - subject.public_methods
        expect(missing_methods).to be_blank
      end
    end

    describe "Equality" do
      it "same regular value is equal" do
        first_cast = cast(regular_value)
        second_cast = cast(regular_value)
        expect(first_cast).to eq(second_cast)
        expect(first_cast).to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 1)
      end

      it "regular values are case-insensitive" do
        first_cast = cast(regular_value.downcase)
        second_cast = cast(regular_value.upcase)
        expect(first_cast).to eq(second_cast)
        expect(first_cast).to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 1)
      end

      it "regular values can be compared against blank" do
        first_cast = cast(regular_value)
        second_cast = cast(blank_value)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end

      it "regular values can be compared against exceptional" do
        first_cast = cast(regular_value)
        second_cast = cast(exceptional_value)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end

      it "exceptional values can be compared blank exceptional" do
        first_cast = cast(blank_value)
        second_cast = cast(exceptional_value)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end
    end
  end

  describe "Examples" do
    it "works" do
      value = cast("https://www.linkedin.com/in/example")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "works if casted multiple times" do
      value = cast(cast("https://www.linkedin.com/in/example"))
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "works if blank casted multiple times" do
      value = cast(cast(nil))
      expect(value.to_s).to eq("")
      expect(value.to_str).to eq("")
      expect(value).to be_blank
      expect(value).not_to be_regular
      expect(value).not_to be_exceptional
    end

    it "works if exceptional value casted multiple times" do
      value = cast(cast("{}"))
      expect(value.to_s).to eq("{}")
      expect(value.to_str).to eq("{}")
      expect(value).not_to be_blank
      expect(value).not_to be_regular
      expect(value).to be_exceptional
    end

    it "removes trailing /" do
      value = cast("https://www.linkedin.com/in/example/")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "removes trailing anchor code" do
      value = cast("https://www.linkedin.com/in/example#anchor")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "removes query string" do
      value = cast("https://www.linkedin.com/in/example?q=1")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "appends https://www if missing" do
      value = cast("linkedin.com/in/example")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "inserts www if missing" do
      value = cast("https://linkedin.com/in/example")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "swaps country code with www" do
      value = cast("https://za.linkedin.com/in/example")
      expect(value.to_s).to eq("https://www.linkedin.com/in/example")
      expect(value.to_str).to eq("https://www.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "exception if not user profile url" do
      value = cast("https://www.linkedin.com/company/nexl-co/mycompany/")
      expect(value.to_s).to eq("https://www.linkedin.com/company/nexl-co/mycompany/")
      expect(value.to_str).to eq("https://www.linkedin.com/company/nexl-co/mycompany/")
      expect(value).to be_present
      expect(value).not_to be_regular
      expect(value).to be_exceptional
    end

    it "exceptional if not valid url" do
      value = cast("https://{}.linkedin.com/in/example")
      expect(value.to_s).to eq("https://{}.linkedin.com/in/example")
      expect(value.to_str).to eq("https://{}.linkedin.com/in/example")
      expect(value).to be_present
      expect(value).not_to be_regular
      expect(value).to be_exceptional
    end
  end
end
