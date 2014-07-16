require "mongoid"
require "sort_char"
require "knowledge_camp/step/version"

module KnowledgeCamp
  class Step
    include Mongoid::Document
    include Mongoid::Timestamps
    include SortChar::Owner

    field :title, :type => String
    field :desc,  :type => String

    belongs_to :stepped, :polymorphic => true

    module Owner
      def self.included(base)
        base.has_many :steps,
                      :class_name => Step.name,
                      :order      => "position asc",
                      :as         => :stepped
        
      end
    end
  end
end
