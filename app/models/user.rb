class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { homeowner: 0, engineer: 1, admin: 2 }, default: :homeowner

  has_many :projects, dependent: :destroy

  validates :name, presence: true

  def engineer_or_admin?
    engineer? || admin?
  end
end
