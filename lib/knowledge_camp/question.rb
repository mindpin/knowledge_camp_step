module KnowledgeCamp
  class Question
    include Mongoid::Document
    include Mongoid::Timestamps

    field :content, :type => String

    belongs_to :selection
  end
end
