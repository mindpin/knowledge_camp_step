module KnowledgeCamp
  module HasManyLearnRecords
    def self.included(base)
      base.has_many :learn_records,
                    :class_name => LearnRecord.name

      LearnRecord.belongs_to :user,
                             :class_name => base.name
    end
  end
end
