class WrittenQuestion
  include Tripod::Resource

  rdf_type 'http://data.parliament.uk/schema/parl#WrittenParliamentaryQuestion'
  linked_to :tablingMember, 'http://data.parliament.uk/schema/parl#tablingMember',class_name: 'Member'
  linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Subject', multivalued: true

end