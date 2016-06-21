class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    format([
      houses: url_for(controller: 'houses', format: :json),
      concepts: url_for(controller: 'concepts', format: :json),
      oralQuestions: url_for(controller: 'oral_questions', format: :json),
      writtenQuestions: url_for(controller: 'written_questions', format: :json),
      divisions: url_for(controller: 'divisions', format: :json),
      people: url_for(controller: 'people', format: :json),
    ])
  end

  protected
  def resource_uri(id)
    "http://id.ukpds.org/#{id}"
    # "http://data.parliament.uk/resource/#{id}"
  end

  def format(data)
    respond_to do |format|
      format.html
      format.any(:xml, :json) { render request.format.to_sym => data[:hierarchy] }

      format.rdf {
        result = ""
        data[:graph].each_statement do |statement|
          result << RDF::NTriples::Writer.serialize(statement)
        end

        render :text => result
      }
    end
  end

end

