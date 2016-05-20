class PhonesController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_row
  before_filter :set_phone, only: [:edit, :update, :destroy]

  def index
    @phones = @row.phones
  end

  def new
    @phone = @row.phones.new
  end

  def create
    @phone = @row.phones.new(phones_params)

    if @phone.save
      redirect_to row_phones_path(@row)
    else
      redirect_to new_row_phone_path(@row), :notice => I18n.t('errors.phones.new_save')
    end
  end

  def edit
  end

  def update
    if @phone.update_attributes(phones_params)
      redirect_to row_phones_path(@row)
    else
      redirect_to edit_row_phone_path(@row), :notice => I18n.t('errors.phones.update_save')
    end
  end

  def destroy
    @phone.delete
    redirect_to row_phones_path(@row)
  end

  private

  def set_row
    @row_id = params[:row_id].to_i
    @row = Row.find(@row_id)
  end

  def set_phone
    @phone_id = params[:id].to_i
    @phone = Phone.find(@phone_id)
  end

  def phones_params
    params.require(:phone).permit(:number)
  end
end
