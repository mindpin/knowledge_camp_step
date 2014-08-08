require "spec_helper"

module KnowledgeCamp
  describe Step do
    let(:model)   {Stepped.create}
    let(:creator) {User.create}
    let(:step)    {model.steps.create}
    let(:note)    {step.notes.create(:creator => creator, :content => "content", :kind => "whatever")}

    before {note}

    it {expect(step.stepped).to eq model}
    it {expect(note.creator).to eq creator}
    it {expect(model.notes).to include note}
    it {expect(creator.notes).to include note}
  end
end
