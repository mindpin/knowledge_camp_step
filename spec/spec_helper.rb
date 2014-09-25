require "mongoid"
require "knowledge_camp_step"
Bundler.require(:test)
require "rspec"
require "pry"
ENV["MONGOID_ENV"] = "test"
Mongoid.load!("./spec/mongoid.yml")

class User
  include Mongoid::Document
  include KnowledgeCamp::Step::NoteCreator
  include KnowledgeCamp::Step::QuestionCreator
  include KnowledgeCamp::Step::SelectionCreator
end

class Stepped
  include Mongoid::Document
  include KnowledgeCamp::Step::Owner
end

RSpec.configure do |config|
  config.after(:each) do
    Mongoid.purge!
  end
end
