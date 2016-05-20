class Phone < ActiveRecord::Base
  # number

  belongs_to :row

  default_scope { order('created_at DESC') }

  def updated_at_ut
    updated_at.to_time.to_i
  end
end
