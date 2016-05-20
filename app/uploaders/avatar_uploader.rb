# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  process :resize_to_fit => [128, 128]

  def store_dir
    "images/avatars"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{model.random_string}#{File.extname(original_filename)}" if original_filename.present?
  end
end
