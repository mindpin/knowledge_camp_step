require "spec_helper"

module KnowledgeCamp
  describe Step do
    let(:model)   {Stepped.create}
    let(:creator) {User.create}
    let(:step1)   {model.steps.create}
    let(:step2)   {model.steps.create}
    let(:step3)   {model.steps.create}
    let(:note)    {step1.notes.create(:creator => creator, :content => "content", :kind => "whatever")}

    let(:end_cont)    {:end}
    let(:id_cont1)    {step2.attrs_simple}
    let(:id_cont2)    {step3.attrs_simple}
    let(:select_cont) {{
      :select => {
        :question => "选择下一个Step.",
        :options  => [id_cont1, id_cont2]
      }
    }}

    before {note}

    it {expect(step1.stepped).to eq model}
    it {expect(note.creator).to eq creator}
    it {expect(model.notes).to include note}
    it {expect(creator.notes).to include note}

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
