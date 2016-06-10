require 'sparql/client'
require 'rdf'

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
  client = SPARQL::Client.new("http://data.ukpds.org//repositories/TempWorkerSimple2")
  # query = sparql.select.where([:ss, :p, :o]).limit(10)
#   query = sparql.query("PREFIX parl: <http://data.parliament.uk/schema/parl#>
# PREFIX schema: <http://schema.org/>
# select ?person ?name ?value where { 
#     ?vote parl:division <http://data.parliament.uk/resource/00147668-0000-0000-0000-000000000000>;
#         parl:value ?value;
#         parl:member ?person.
#     ?person schema:name ?name .
# }")

division_uri = 'http://data.parliament.uk/resource/00147668-0000-0000-0000-000000000000' 
division_pattern = RDF::Query::Pattern.new(
  :vote, 
  'parl:division', 
  RDF::URI.new(division_uri))
value_pattern = RDF::Query::Pattern.new(
  :vote, 
  'parl:value', 
  :value)
member_pattern = RDF::Query::Pattern.new(
  :vote, 
  'parl:member', 
  :person)
name_pattern = RDF::Query::Pattern.new(
  :person, 
  'schema:name', 
  :name)

query = client
  .select
  .prefix("parl:<http://data.parliament.uk/schema/parl#>")
  .prefix("schema:<http://schema.org/>")
  .select(:person, :name, :value)
  .where(division_pattern, value_pattern, member_pattern, name_pattern)

query.each_solution do |solution|
    p solution
end

render :text => query


  # render :text => query
  #queryable = RDF::Repository.load("http://data.ukpds.org//repositories/TempWorkerSimple2")

#   sse = SPARQL.parse("PREFIX parl: <http://data.parliament.uk/schema/parl#>
# PREFIX schema: <http://schema.org/>
# select ?person ?name ?value where { 
#     ?vote parl:division <http://data.parliament.uk/resource/00147668-0000-0000-0000-000000000000>;
#         parl:value ?value;
#         parl:member ?person.
#     ?person schema:name ?name .
# }")
#   sse.execute(queryable) do |result|
#     p result
#   end

    # division = Division.find('http://data.parliament.uk/resource/00147668-0000-0000-0000-000000000000')
    # vote = division.votes.first
    # render :text => vote.member
    # a = Concept.find('http://data.parliament.uk/resource/00093447-0000-0000-0000-000000000002')

    # a = OralQuestion.first.tablingMember

    # render :text => a

    # a = WrittenQuestion.find('http://data.parliament.uk/resource/00041303-0000-0000-0000-000000000000')

    # render :text => a.writtenAnswer.text



      # a = Concept.find_by_sparql("PREFIX dcterms: <http://purl.org/dc/terms/>
      #       SELECT ?uri (COUNT(?question) as ?count)
      #       WHERE {
      #           ?question dcterms:subject ?uri
      #       }
      #       GROUP BY ?uri
      #       ORDER BY DESC(?count)
      #       LIMIT 50
      #       ")

      # render :text => a

    # @subjects = Subject.all.limit(50).resources

  	# render :text => "hello world controller"
  	# kirsty = Person.find('http://data.parliament.uk/members/4355')
  	# kirsty = Person.first
  	# kirsty = Person.where(:name => 'Earl of Oxford and Asquith').first
  	# kirsty = Person.all.limit(1)
  	# kirsty = Person.count
  	# kirsty = Person.where(p => p.hasRegisteredInterests.any(ri => ri.name == ''))
  	# kirsty = Person.where(:hasRegisteredInterests => .any? { |e|  })

  	# render :text => kirsty.resources[0]
  	# render :text => kirsty.hasRegisteredInterests.first.belongsTo


    # question = WrittenQuestion.find('http://data.parliament.uk/resource/10000000-0000-0000-0000-000000000003')

    # person = Person.where("<http://data.parliament.uk/resource/73800000-0000-0000-0000-000000000001> ?p ?o").first(:return_graph => false)
    # person = Person.find('http://data.parliament.uk/resource/73800000-0000-0000-0000-000000000001')
    # person = Person.where(name: 'Lord Alton of Liverpool').first

    # subject = Subject.find('http://data.parliament.uk/resource/29677800-0000-0000-0000-000000000002')
    # subject = Subject.where(label: 'Politics and government').first

    # render :text => person.writtenQuestions.first.subjects.first
    # render text: person.writtenQuestions.first.subjects

  	# c=Concept.find('')
  	# ms=c.questions.map { |q| q.member }
  	# m=Member.find('')
  	# ts=m.questions.map { |q| q.subject }
  end

  protected
  def resource_uri(id)
    "http://data.parliament.uk/resource/#{id}"
  end
  
end



# class RegisteredInterest
# 	include Tripod::Resource

# 	rdf_type 'http://data.parliament.uk/schema/parl#RegisteredInterest'

# 	field :name, 'http://data.parliament.uk/schema/parl#registeredInterest'

# 	linked_from :belongsTo, :hasRegisteredInterests, class_name: 'Person'
# end

