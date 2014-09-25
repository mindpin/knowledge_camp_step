module KnowledgeCamp
  module StepWithDefaultBlockAndSelection
    def default_block
      blocks.first
    end

    def selection_of(user)
      return if default_block.blank?

      criteria  = default_block.selections.where(:creator_id => user.id)
      selection = criteria.first

      return selection if selection
      size = default_block.content.to_s.size
      tail = size == 0 ? 0 : size - 1
      criteria.create(:head => 0, :tail => tail, :hard => false)
    end

    def note_of(user)
      selection = selection_of(user)
      selection && selection.notes.first
    end

    def question_of(user)
      selection = selection_of(user)
      selection && selection.questions.first
    end
  end
end
