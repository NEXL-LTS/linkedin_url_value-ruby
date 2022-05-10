# LinkedinUrlValue

Rails value to Work with use Linkedin profile urls.
* handles various formats and converts them all to a standard format of `https://www.linkedin.com/in/<username>`
* auto encodes utf-8 characters

## Installation

Add to your Gemfile:

```ruby
gem 'linkedin_url_value', github: "NEXL-LTS/linkedin_url_value-ruby", branch: "main"
gem "rails_values", github: "NEXL-LTS/rails_values", branch: "main"
```

## Usage

```ruby
class Person < ApplicationRecord
  attribute :linkedin_url, :rv_linkedin_url_value
end

person = Person.new
person.linkedin_url = "linkedin.com/in/example"
puts person.linkedin_url.to_str # => "https://www.linkedin.com/in/example"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NEXL-LTS/linkedin_url_value-ruby.
