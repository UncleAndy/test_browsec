class Phone < ActiveRecord::Base
  # number

  belongs_to :row

  default_scope { order('created_at DESC') }
end
