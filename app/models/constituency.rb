class Constituency < QueryObject
  include Vocabulary

  def self.all
    result = self.query('
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX parl: <http://data.parliament.uk/schema/parl#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX osadm: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>
      CONSTRUCT {
          ?constituency
              rdfs:label ?constituencyLabel ;
              osadm:gssCode ?gssCode ;
              parl:member ?member ;
              schema:name ?member_name .
      }
      WHERE {
        ?constituency rdf:type parl:Constituency ;
              rdfs:label ?constituencyLabel ;
              osadm:gssCode ?gssCode ;
              parl:member ?member .
        ?member
              schema:name ?member_name .
      }
    ')

    constituencies = result.subjects(unique: true).map do |subject|
      constituency_label_pattern = RDF::Query::Pattern.new(
          subject,
          Rdfs.label,
          :constituency_label
      )
      constituency_label = result.first_literal(constituency_label_pattern)

      gss_code_pattern = RDF::Query::Pattern.new(
          subject,
          Osadm.gssCode,
          :gss_code
      )
      gss_code = result.first_literal(gss_code_pattern)

      member_pattern = RDF::Query::Pattern.new(
          subject,
          Parl.member,
          :member
      )
      member_id = self.get_id(result.first_object(member_pattern))

      member_name_pattern = RDF::Query::Pattern.new(
          subject,
          Schema.name,
          :member_name
      )
      member_name = result.first_literal(member_name_pattern)

      {
          :id => self.get_id(subject),
          :constituency_label => constituency_label.to_s,
          :gss_code => gss_code.to_s,
          :member => {
              :id => member_id,
              :name => member_name.to_s
          }
      }
    end

    hierarchy = {
        :constituencies => constituencies
    }

    { :graph => result, :hierarchy => hierarchy }
  end

  def self.find

  end

end