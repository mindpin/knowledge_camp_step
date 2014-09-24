require "mongoid"
require "knowledge_camp/step/version"
require "knowledge_camp/block"
require "knowledge_camp/selection_addons_with_step_id"
require "knowledge_camp/note"
require "knowledge_camp/question"
require "knowledge_camp/step_with_default_block_and_selection"

module KnowledgeCamp
  NoContentBlock = Class.new(Exception)

  class Step
    include Mongoid::Document
    include Mongoid::Timestamps
    include StepWithDefaultBlockAndSelection

    field :title,       :type => String
    field :continue,    :type => Hash,    :default => {}
    field :block_order, :type => Array,   :default => []

    has_many :learn_records
    belongs_to :stepped, :polymorphic => true

    validate :validate_continue

    default_scope ->{order(:id.asc)}

    def add_content(kind, content)
      params = case kind.to_s
               when "text"
                 {:kind => kind, :content => content}
               when "image", "video"
                 {:kind => kind, :virtual_file_id => content}
               end

      block = Block.create(params)

      self.block_order << block.id.to_s
      self.save
      block
    end

    def default_block
      blocks.first
    end

    def default_selection
      return if default_block.blank?

      criteria  = default_block.selections
      selection = criteria.first

      return selection if selection
      size = default_block.content.to_s.size
      tail = size == 0 ? 0 : size - 1
      criteria.create(:head => 0, :tail => tail, :hard => false)
    end

    def note
      default_selection && default_selection.notes.first
    end

    def question
      default_selection && default_selection.questions.first
    end

    def note_id
      note && note.id
    end

    def question_id
      question && question.id
    end

    def is_hard?
      default_selection && default_selection.hard
    end
    
    def blocks
      self.block_order.map {|id| Block.find(id)}
    end

    def content_up(block_id)
      move_content(:up, block_id)
    end

    def content_down(block_id)
      move_content(:down, block_id)
    end

    def remove_content(block_id)
      Block.find(block_id).destroy
      self.block_order.delete(block_id)
      self.save
    end

    def set_continue(*args)
      case args[0]
      when "step", :step
        self.continue = {:type => :step, :id => args[1].to_s}
      when "select", :select
        param = args[1].clone

        param[:options].each do |option|
          option[:id] = option[:id].to_s
        end

        self.continue = {:type => :select}.merge(param)
      when false, :end, "end"
        self.continue = {:type => :end}
      end

      self.save
    end

    def attrs_simple
      {:id => self.id.to_s, :text => self.title}
    end

    def attrs
      {
        :id           => self.id.to_s,
        :title        => self.title,
        :blocks       => self.blocks.map(&:attrs),
        :continue     => continue,
        stepped_field => self.stepped_id.to_s,
        :created_at   => self.created_at,
        :updated_at   => self.updated_at,
        :is_hard      => !!self.is_hard?
      }.merge(self.question_id ?
              {:question_id => self.question_id.to_s} :
              {})
       .merge(self.note_id ?
              {:note_id => self.note_id.to_s} :
              {})
    end

    def stepped_field
      :"#{stepped_type.split("::").last.underscore}_id"
    end

    private

    def move_content(dir, block_id)
      return if !self.block_order.include?(block_id)

      index = self.block_order.index(block_id)

      up_first = index == 0 && dir == :up
      down_last = index == self.block_order.size - 1 && dir == :down

      return if up_first || down_last

      new_index = case dir
                  when :up then index - 1
                  when :down then index + 1
                  end

      self.block_order.insert(new_index, self.block_order.delete_at(index))
      self.save
    end

    def validate_continue
      return if continue.blank?

      keys = continue.keys.map(&:to_s)

      message = case continue[:type].to_s
                when "end"
                  cond = keys | %W(type) == keys
                  cond ? nil : "Invalid `:end' continue value!"
                when "id"
                  cond = keys | %W(type id) == keys
                  cond ? nil : "Invalid `:id' continue value!"
                when "select"
                  cond = keys | %W(type question options) == keys
                  cond ? nil : "Invalid `:select' continue value!"
                end

      errors.add(:continue, message) if message
    end

    module Owner
      def self.included(base)
        base.has_many :steps,
                      :class_name => Step.name,
                      :order      => :id.asc,
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

    module QuestionCreator
      def self.included(base)
        base.has_many :questions,
                      :class_name => Question.name

        Question.belongs_to :creator,
                            :class_name => base.name
      end
    end
  end
end
