module KnowledgeCamp
  class Block
    include Mongoid::Document
    include Mongoid::Timestamps

    field :kind,    :type => Symbol
    field :content, :type => String

    has_many :selections
  end
end
