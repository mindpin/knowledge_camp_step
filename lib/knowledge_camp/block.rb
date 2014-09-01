module KnowledgeCamp
  class Block
    include Mongoid::Document
    include Mongoid::Timestamps

    field :kind,    :type => Symbol
    field :content, :type => String

    has_many :selections

    def attrs
      {
        :id              => self.id.to_s,
        :kind            => self.kind,
        :content         => self.content,
        :virtual_file_id => self.virtual_file_id
      }
    end
  end
end
