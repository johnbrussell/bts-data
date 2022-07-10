class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  validates :name, presence: true
  validates :group, presence: true
  validates :bts_id, presence: true
end
