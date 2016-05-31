class Subject
  include Tripod::Resource

  rdf_type 'http://www.w3.org/2004/02/skos/core#Concept'

  field :label, 'http://www.w3.org/2004/02/skos/core#prefLabel'
  linked_from :writtenQuestions, :subjects, class_name: 'WrittenQuestion', multivalued: true
end