module KnowledgeCamp
  class Question
    include Mongoid::Document
    include Mongoid::Timestamps
    include SelectionAddonsWithStepId

    field :content, :type => String

    belongs_to :selection

    def step_id
      selection.block.step.id
    end

    def attrs
      {
        :id         => self.id.to_s,
        :content    => self.content,
        :step_id    => self.step_id.to_s,
        :created_at => self.created_at,
        :updated_at => self.updated_at
      }.merge(respond_to?(:creator_id) ?
              {:creator_id => self.creator_id.to_s} :
              {})
    end
  end
end
