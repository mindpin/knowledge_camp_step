module KnowledgeCamp
  class Note
    include Mongoid::Document
    include Mongoid::Timestamps

    field :content, :type => String
    field :kind,    :type => String

    belongs_to :step, :class_name => Step.name

    validates :content, :step_id, :kind, :presence => true

    def attrs
      {
        :id         => self.id.to_s,
        :kind       => self.kind,
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
