class ConstituenciesController < ApplicationController

  def index
    data = Constituency.all

    format(data)
  end

  def show
    constituency_uri = resource_uri(params[:id])
    data = Constituency.find(constituency_uri)

    format(data)
  end

end