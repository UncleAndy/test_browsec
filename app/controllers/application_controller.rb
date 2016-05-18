class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    user_images_path(:user_id => current_user.id)
  end

  def check_user_permission
    if (!current_user.present? || current_user.id != params[:user_id].to_i)
      redirect_to root_path, notice: I18n.t('errors.no_user_permission')
    end
  end
end
