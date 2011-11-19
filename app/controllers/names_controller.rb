class NamesController < ApplicationController
  def index
    if params[:last_name]
      last_name = params[:last_name].to_s.downcase
      redirect_to(name_path(last_name))
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        names = Name.order(:last_name).all.collect(&:last_name)
        render :json => names
      }
    end
  end

  def show
    @name = Name.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @name }
    end
  end
end
