class Tag < ApplicationRecord
  has_and_belongs_to_many :contacts

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save { self.name = name.strip }
end
