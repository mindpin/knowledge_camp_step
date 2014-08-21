require "spec_helper"

module KnowledgeCamp
  describe Step do
    let(:model)   {Stepped.create}
    let(:creator) {User.create}
    let(:step1)   {model.steps.create(:desc => "12345678910111213141516")}
    let(:step2)   {model.steps.create}
    let(:step3)   {model.steps.create}
    let(:sel1)    {step1.selections.create(:head => 0, :tail => 8)}
    let(:sel2)    {step1.selections.create(:head => 14, :tail => 20, :hard => true)}
    let(:note)    {sel1.notes.create(:creator => creator, :content => "content", :kind => "whatever")}
    let(:ques)    {sel1.questions.create(:content => "Why?")}

    let(:end_cont)    {:end}
    let(:id_cont1)    {step2.attrs_simple}
    let(:id_cont2)    {step3.attrs_simple}
    let(:select_cont) {{
      :select => {
        :question => "选择下一个Step.",
        :options  => [id_cont1, id_cont2]
      }
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

    context "text selection in steps" do
      before {sel1;sel2;sel3}

      context "no merge" do
        let(:sel3) {step1.selections.create_or_merge(:head => 9, :tail => 13)}

        it {expect(sel3.head).to be 9}
        it {expect(sel3.tail).to be 13}
        it {expect(sel3.hard).to be false}
        it {expect(step1.selections.size).to eq 3}
        it {expect(step1.selections).to include(sel1, sel3, sel2)}
      end

      context "merging sel1" do
        let(:sel3) {step1.selections.create_or_merge(:head => 4, :tail => 12)}

        it {expect(sel3.head).to be 0}
        it {expect(sel3.tail).to be 12}
        it {expect(sel3.hard).to be false}
        it {expect(step1.selections.size).to eq 2}
        it {expect(step1.selections).to include(sel3, sel2)}
        it {expect(sel3.notes).to include(note)}
        it {expect(sel3.questions).to include(ques)}
      end

      context "merging sel2" do
        let(:sel3) {step1.selections.create_or_merge(:head => 16, :tail => 22)}

        it {expect(sel3.head).to be 14}
        it {expect(sel3.tail).to be 22}
        it {expect(sel3.hard).to be true}
        it {expect(step1.selections.size).to eq 2}
        it {expect(step1.selections).to include(sel1, sel3)}
      end

      context "merging sel1 & sel2" do
        let(:sel3) {step1.selections.create_or_merge(:head => 4, :tail => 16)}

        it {expect(sel3.head).to be 0}
        it {expect(sel3.tail).to be 20}
        it {expect(sel3.hard).to be true}
        it {expect(step1.selections.size).to eq 1}
        it {expect(step1.selections).to include(sel3)}
        it {expect(sel3.notes).to include(note)}
        it {expect(sel3.questions).to include(ques)}
      end
    end

    context "when set wrong continue_type & continue value" do
      context "when wrong continue_type value" do
        before {step1.continue_type = :haha}
        
        it {expect(step1).to be_invalid}
      end

      context "when wrong end value" do
        before do
          step1.continue_type = :end
          step1.continue = id_cont1
        end

        it {expect(step1).to be_invalid}

        it {
          step1.continue = end_cont
          expect(step1).to be_valid
          step1.save
          expect(step1.continue).to eq end_cont
        }
      end

      context "when wrong id value" do
        before do
          step1.continue_type = :id
          step1.continue = select_cont
        end

        it {expect(step1).to be_invalid}

        it {
          step1.continue = id_cont1
          expect(step1).to be_valid
          step1.save
          expect(step1.continue).to eq id_cont1
        }
      end

      context "when wrong select value" do
        before do
          step1.continue_type = :select
          step1.continue = end_cont
        end

        it {expect(step1).to be_invalid}

        it {
          step1.continue = select_cont
          expect(step1).to be_valid
          step1.save
          expect(step1.continue).to eq select_cont
        }
      end
    end
  end
end
