module KnowledgeCamp
  class Block
    include Mongoid::Document
    include Mongoid::Timestamps

    field :kind,    :type => Symbol
    field :content, :type => String

    belongs_to :step
    has_many   :selections

    def attrs
      {
        :id      => self.id.to_s,
        :kind    => self.kind,
        :content => self.content
      }
    end
  end
end
