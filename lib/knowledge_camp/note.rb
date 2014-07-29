module KnowledgeCamp
  class Note
    include Mongoid::Document
    include Mongoid::Timestamps

    field :content, :type => String
    field :kind,    :type => String

    belongs_to :step, :class_name => Step.name
  end
end
