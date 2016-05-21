class RowsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_row, only: [:edit, :update, :destroy]
  before_filter :set_page, only: [:index, :edit, :update]
  before_filter :set_per_page, only: [:index]

  def index
    rows = current_user.rows

    if params[:search].present?
      rows = rows.search(params[:search])
    end

    if @per_page > 0
      @rows = rows.page(@page).per(@per_page)
    else
      @rows = rows.all
    end
  end

  def new
    @row = current_user.rows.new
  end

  def create
    @row = current_user.rows.new(new_row_params)

    if @row.save
      params[:row][:phones].split("\n").each do |num|
        num = num.chomp
        phone = @row.phones.new({:number => num})
        phone.save
      end
      redirect_to rows_path
    else
      redirect_to new_row_path, :notice => I18n.t('errors.rows.new_save')
    end
  end

  def edit
  end

  def update
    if @row.update_attributes(new_row_params)
      redirect_to rows_path(:page => params[:row][:page])
    else
      redirect_to edit_row_path(:page => params[:row][:page]), :notice => I18n.t('errors.rows.update_save')
    end
  end

  def destroy
    @row.remove_avatar!
    @row.delete
    redirect_to rows_path
  end

  def export
    send_data ::ExportService.export(current_user), :type => 'text/csv; charset=UTF-8;', :disposition => "attachment; filename=contacts.csv"
  end

  def import_form
  end

  def import
    file = params[:contacts]
    ::ExportService.import(file.read, current_user)
    redirect_to rows_path, :notice => I18n.t('rows.import_success')
  end

  private

  def set_row
    @row_id = params[:id].to_i
    @row = Row.find(@row_id)
  end

  def set_page
    @page = 1
    @page = params[:page].to_i if params[:page].present?
  end

  def set_per_page
    params_size = if params[:size].present?
      session[:page_size] = params[:size]
    else
      session[:page_size] || 5
    end

    if params_size.present?
      if params_size == 'all'
        @per_page = -1
      else
        @per_page = params_size.to_i
      end
    end
  end

  def new_row_params
    params.require(:row).permit(:name, :context, :avatar)
  end
end
