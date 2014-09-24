module KnowledgeCamp
  module SelectionAddonsWithStepId
    def step_id=(sid)
      step = Step.find(sid)
      raise NoContentBlock.new("step没有内容块") if step.default_block.blank?
      self.selection = step.default_selection
    end

    def step_id
      selection.block.step.id
    end
  end
end
