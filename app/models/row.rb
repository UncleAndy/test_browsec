class Row < ActiveRecord::Base
  # name, avatar, context

  mount_uploader :avatar, AvatarUploader

  default_scope { order('created_at DESC') }
  scope :search, lambda {|str| where('name LIKE ?', "%#{str}%")}

  belongs_to :user

  has_many :phones

  def random_string
    @randomstring ||= SecureRandom.hex(10)
  end

  def updated_at_ut
    updated_at.to_time.to_i
  end
end
