require "spec_helper"

module KnowledgeCamp
  describe Step do
    let(:model)   {Stepped.create}
    let(:creator) {User.create}
    let(:step1)   {model.steps.create(:title => "1hao")}
    let(:step2)   {model.steps.create(:title => "2hao")}
    let(:step3)   {model.steps.create(:title => "3hao")}
    let(:block1)  {step1.add_content("text", "b1")}
    let(:block2)  {step1.add_content("text", "b2")}
    let(:block3)  {step1.add_content("text", "b3")}
    let(:sel1)    {block1.selections.create(:head => 0, :tail => 8)}
    let(:sel2)    {block1.selections.create(:head => 14, :tail => 20, :hard => true)}
    let(:note)    {sel1.notes.create(:creator => creator, :content => "content", :kind => "whatever")}
    let(:ques)    {sel1.questions.create(:content => "Why?")}

    let(:end_cont)    {:end}
    let(:id_cont1)    {step2.attrs_simple}
    let(:id_cont2)    {step3.attrs_simple}
    let(:select_cont) {{
      :question => "选择下一个Step.",
      :options  => [id_cont1, id_cont2]
    }}

    before {note;ques;step1;step2;step3}

    it {expect(step1.stepped).to eq model}
    it {expect(note.creator).to eq creator}
    it {expect(sel1.notes).to include note}
    it {expect(sel1.questions).to include ques}
    it {expect(creator.notes).to include note}

    it {
      expect(model.steps[0]).to eq step1
      expect(model.steps[1]).to eq step2
      expect(model.steps[2]).to eq step3
    }

    it {
      expect(Step.all[0]).to eq step1
      expect(Step.all[1]).to eq step2
      expect(Step.all[2]).to eq step3
    }

    context "continue" do
      context "step" do
        before {step1.set_continue("step", step2.id.to_s)}

        it {expect(step1).to be_valid}
      end

      context "select" do
        before {step1.set_continue("select", select_cont)}

        it {expect(step1).to be_valid}
      end

      context "end" do
        before {step1.set_continue(false)}

        it {expect(step1).to be_valid}
      end
    end

    context "blocks" do
      before {block1;block2;block3}

      def blocks(*args)
        args.map(&:id).map(&:to_s)
      end

      it {expect(step1.blocks).to eq [block1, block2, block3]}

      context "move up block2" do
        before {step1.content_up(block2.id.to_s)}

        it {expect(step1.blocks).to eq [block2, block1, block3]}
      end

      context "move down block2" do
        before {step1.content_down(block2.id.to_s)}

        it {expect(step1.blocks).to eq [block1, block3, block2]}
      end

      context "move down block1" do
        before {step1.content_down(block1.id.to_s)}

        it {expect(step1.blocks).to eq [block2, block1, block3]}
      end

      context "move up block1" do
        before {step1.content_up(block1.id.to_s)}

        it {expect(step1.blocks).to eq [block1, block2, block3]}
      end

      context "move up block3" do
        before {step1.content_up(block3.id.to_s)}

        it {expect(step1.blocks).to eq [block1, block3, block2]}
      end

      context "move down block3" do
        before {step1.content_down(block3.id.to_s)}

        it {expect(step1.blocks).to eq [block1, block2, block3]}
      end
    end

    context "text selection in blocks" do
      before {sel1;sel2;sel3}

      context "no merge" do
        let(:sel3) {block1.selections.create_or_merge(:head => 9, :tail => 13)}

        it {expect(sel3.head).to be 9}
        it {expect(sel3.tail).to be 13}
        it {expect(sel3.hard).to be false}
        it {expect(block1.selections.size).to eq 3}
        it {expect(block1.selections).to include(sel1, sel3, sel2)}
      end

      context "merging sel1" do
        let(:sel3) {block1.selections.create_or_merge(:head => 4, :tail => 12)}

        it {expect(sel3.head).to be 0}
        it {expect(sel3.tail).to be 12}
        it {expect(sel3.hard).to be false}
        it {expect(block1.selections.size).to eq 2}
        it {expect(block1.selections).to include(sel3, sel2)}
        it {expect(sel3.notes).to include(note)}
        it {expect(sel3.questions).to include(ques)}
      end

      context "merging sel2" do
        let(:sel3) {block1.selections.create_or_merge(:head => 16, :tail => 22)}

        it {expect(sel3.head).to be 14}
        it {expect(sel3.tail).to be 22}
        it {expect(sel3.hard).to be true}
        it {expect(block1.selections.size).to eq 2}
        it {expect(block1.selections).to include(sel1, sel3)}
      end

      context "merging sel1 & sel2" do
        let(:sel3) {block1.selections.create_or_merge(:head => 4, :tail => 16)}

        it {expect(sel3.head).to be 0}
        it {expect(sel3.tail).to be 20}
        it {expect(sel3.hard).to be true}
        it {expect(block1.selections.size).to eq 1}
        it {expect(block1.selections).to include(sel3)}
        it {expect(sel3.notes).to include(note)}
        it {expect(sel3.questions).to include(ques)}
      end
    end
  end
end
