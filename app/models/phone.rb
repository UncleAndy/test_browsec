class Phone < ActiveRecord::Base
  # number, normalized

  belongs_to :row

  default_scope { order('created_at DESC') }

  before_save :normalize

  def normalize
    self.normalized = ::NumberService.normalize(number) if number.present?
  end

  def updated_at_ut
    updated_at.to_time.to_i
  end
end
