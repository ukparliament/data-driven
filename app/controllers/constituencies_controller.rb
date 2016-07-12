class ConstituenciesController < ApplicationController

  def index
    data = Constituency.all

    render json: data[:hierarchy]
  end

  def show

  end

end