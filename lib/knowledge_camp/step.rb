require "mongoid"
require "knowledge_camp/step/version"
require "knowledge_camp/block"
require "knowledge_camp/note"

module KnowledgeCamp
  class Step
    include Mongoid::Document
    include Mongoid::Timestamps

    field :title,       :type => String
    field :continue,    :type => Hash,  :default => {}
    field :block_order, :type => Array, :default => []

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
    end

    def set_continue(*args)
      case args[0]
      when "step", :step
        self.continue = {:type => :step, :id => args[1]}
      when "select", :select
        self.continue = {:type => :select}.merge(args[1])
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
        :updated_at   => self.updated_at
      }
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
  end
end
