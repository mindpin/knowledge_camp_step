# KnowledgeCamp::Step

## Installation

Add this line to your application's Gemfile:

```ruby
gem "knowledge_camp_step", :github => "mindpin/knowledge_camp_step", :tag => "v0.0.1"
```

And then execute:

```bash
$ bundle
```

## Usage

```ruby
class SomeStepOwnerModel
  include Mongoid::Document
  include KnowledgeCamp::Step
end

instance = SomeStepOwnerModel.create

instance.steps
```

## Contributing

1. Fork it ( https://github.com/mindpin/knowledge_camp_step/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
