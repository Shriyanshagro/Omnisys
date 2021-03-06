class User < ActiveRecord::Base
  has_many :purchases
  has_many :sales
  has_many :stocks
  has_many :masters
  has_many :reports
  has_many :orders
  belongs_to :user
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable  :trackable, :recoverable,
  devise :database_authenticatable, :registerable,
          :rememberable, :validatable
end
