require 'spec_helper'
include Vocabulary

describe QueryObject, type: :model do

  describe '#get_object' do
    it 'returns the object of a statement when given a graph, a subject, and a predicate' do
      subject = RDF::URI.new("http://id.test.com/1")
      predicate = Parl.indexed
      graph = RDF::Graph.new << RDF::Statement(subject, predicate, 'indexed')
      object = QueryObject.get_object(graph, subject, predicate)
      expect(object).to eq 'indexed'
    end
  end

end