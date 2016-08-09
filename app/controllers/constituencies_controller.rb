class ConstituenciesController < ApplicationController

  def index
    if(request.format.html?)
      redirect_to("#{DataDriven::Application.config.petitions}/constituencies")
      return ''
    end

    data = Constituency.all

    format(data)
  end

  def show
    if(request.format.html?)
      redirect_to("#{DataDriven::Application.config.petitions}/constituencies/#{params[:id]}")
      return ''
    end

    constituency_uri = resource_uri(params[:id])
    data = Constituency.find(constituency_uri)

    format(data)
  end

end