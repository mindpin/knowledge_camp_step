module KnowledgeCamp
  module SelectionAddonsWithStepId
    extend ActiveSupport::Concern

    included {
      before_validation :set_selection!
    }

    def set_selection!
      return if @step.blank?
      self.selection = @step.selection_of(creator)
    end
    
    def step_id=(sid)
      @step = Step.find(sid)
      raise NoContentBlock.new("step没有内容块") if @step.default_block.blank?
    end

    def step_id
      selection.block.step.id
    end
  end
end
