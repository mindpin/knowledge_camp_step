module KnowledgeCamp
  class LearnRecord
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    belongs_to :tutorial

    validates :step_id, :presence => true
    validates :step_id, :uniqueness => {:scope => :user_id}
    
    def attrs
      {
        :id          => self.id.to_s,
        :tutorial_id => self.tutorial_id.to_s,
        :created_at  => self.created_at.to_s
      }.merge(respond_to?(:user_id) ?
              {:user_id => self.user_id.to_s} :
              {})
    end
  end
end