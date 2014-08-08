require "mongoid"
require "sort_char"
require "knowledge_camp/step/version"
require "knowledge_camp/note"

module KnowledgeCamp
  class Step
    include Mongoid::Document
    include Mongoid::Timestamps
    include SortChar::Owner

    field :title, :type => String
    field :desc,  :type => String

    has_many   :notes,   :class_name  => Note.name
    belongs_to :stepped, :polymorphic => true

    def attrs
      {
        :id           => self.id.to_s,
        :title        => self.title,
        :desc         => self.desc,
        stepped_field => self.stepped_id.to_s,
        :created_at   => self.created_at,
        :updated_at   => self.updated_at
      }
    end

    def stepped_field
      :"#{stepped_type.split("::").last.underscore}_id"
    end

    module Owner
      def self.included(base)
        base.has_many :steps,
                      :class_name => Step.name,
                      :order      => "position asc",
                      :as         => :stepped
      end

      def notes
        Note.where(:step_id.in => self.step_ids)
      end
    end

    module NoteCreator
      def self.included(base)
        base.has_many :notes,
                      :class_name => Note.name

        Note.belongs_to :creator,
                        :class_name => base.name
      end
    end
  end
end
