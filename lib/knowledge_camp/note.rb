module KnowledgeCamp
  class Note
    include Mongoid::Document
    include Mongoid::Timestamps
    include SelectionAddonsWithStepId

    field :content, :type => String

    belongs_to :selection

    validates :content, :selection_id, :presence => true

    def attrs
      {
        :id         => self.id.to_s,
        :content    => self.content,
        :step       => self.step.attrs,
        :created_at => self.created_at,
        :updated_at => self.updated_at
      }.merge(respond_to?(:creator_id) ?
              {:creator_id => self.creator_id.to_s} :
              {})
    end
  end
end
