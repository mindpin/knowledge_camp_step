module KnowledgeCamp
  module StepWithDefaultBlockAndSelection
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
  end
end
