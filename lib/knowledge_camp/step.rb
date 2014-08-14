require "mongoid"
require "sort_char"
require "knowledge_camp/step/version"
require "knowledge_camp/note"

module KnowledgeCamp
  class Step
    CONTINUE_TYPES = [:end, :id, :select].freeze

    include Mongoid::Document
    include Mongoid::Timestamps
    include SortChar::Owner

    field :title,         :type => String
    field :desc,          :type => String
    field :continue_type, :type => Symbol
    field :continue

    has_many   :notes,   :class_name  => Note.name
    belongs_to :stepped, :polymorphic => true

    validate :validate_continue_and_continue_type

    def validate_continue_and_continue_type
      return if continue_type.nil?

      if !CONTINUE_TYPES.include?(self.continue_type.to_sym)
        return errors.add(:continue_type, "Invalid continue_type value!")
      end

      message = case self.continue_type
                when :end
                  cond = self.continue == :end
                  cond ? nil : "Invalid `:end' continue value!"
                when :id
                  cond = self.continue.is_a?(Hash) && self.continue[:id]
                  cond ? nil : "Invalid `:id' continue value!"
                when :select
                  cond = self.continue.is_a?(Hash) && self.continue[:select]
                  cond ? nil : "Invalid `:select' continue value!"
                end

      errors.add(:continue, message) if message
    end

    def attrs_simple
      {:id => self.id.to_s, :title => self.title}
    end

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
