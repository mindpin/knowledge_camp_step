module KnowledgeCamp
  class Selection
    include Mongoid::Document
    include Mongoid::Timestamps

    field :head, :type => Integer
    field :tail, :type => Integer
    field :hard, :type => Boolean, :default => false

    belongs_to :block

    has_many :notes
    has_many :questions

    validate :block_id, :presence => true

    def self.create_or_merge(params)
      selections = all
        .where("(this.head >= #{params[:head]} && this.head <= #{params[:tail]}) || " +
               "(this.tail >= #{params[:head]} && this.tail <= #{params[:tail]})")

      selection_ids = selections.pluck(:id)

      return all.create(params) if selection_ids.blank?

      is_hard = params[:hard] || selections.where(:hard => true).any?

      heads = selections.pluck(:head) << params[:head]
      tails = selections.pluck(:tail) << params[:tail]

      selection = all.create(:head => heads.min,
                             :tail => tails.max,
                             :hard => is_hard)

      selection.questions = Question.where(:selection_id.in => selection_ids)
      selection.notes     = Note.where(:selection_id.in => selection_ids)

      selections.where(:id.ne => selection.id).destroy_all
     
      selection
    end
  end
end
