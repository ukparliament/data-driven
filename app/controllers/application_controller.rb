require 'socket'

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    data = {
      :hierarchy => {
        :houses => url_for(controller: 'houses'),
        :concepts => url_for(controller: 'concepts'),
        :oralQuestions => url_for(controller: 'oral_questions'),
        :writtenQuestions => url_for(controller: 'written_questions'),
        :divisions => url_for(controller: 'divisions'),
        :people => url_for(controller: 'people'),
        :committees => url_for(controller: 'committees'),
        :petitions => url_for(controller: 'petitions'),
        :constituencies => url_for(controller: 'constituencies',
        :order_papers => url_for(controller: 'order_papers'),
        :order_paper_items => url_for(controller: 'order_paper_items'))
      }
    }

    @hostname = Socket.gethostname

    @is_it_in_production = Rails.env.production?

    format(data)
  end

  protected

  def rdf_uri(id)
    uri = resource_uri(id)
    RDF::URI.new(uri)
  end

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

  def json_ld(data)
    json_ld = nil
    JSON::LD::API::fromRDF(data[:graph]) do |expanded|
      json_ld = JSON::LD::API.compact(expanded, nil)
    end
    json_ld.to_json
  end

  def update_graph(subject_id, predicate, object, is_insert)
    repo = SPARQL::Client::Repository.new("#{DataDriven::Application.config.database}/statements")    
    client = repo.client
    graph = RDF::Graph.new << create_pattern(subject_id, predicate, object)
    is_insert == true ? client.insert_data(graph) : client.delete_data(graph)
  end

  def create_pattern(subject_id, predicate, object)
    s = rdf_uri(subject_id)
    p = predicate
    o = object
    RDF::Statement(s, p, o)
  end


end

