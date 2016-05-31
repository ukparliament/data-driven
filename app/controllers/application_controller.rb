class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index

    @subjects = Subject.all.limit(50).resources

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
end


class WrittenQuestion
  include Tripod::Resource

  rdf_type 'http://data.parliament.uk/schema/parl#WrittenParliamentaryQuestion'
  linked_to :tablingMember, 'http://data.parliament.uk/schema/parl#tablingMember',class_name: 'Person'
  linked_to :subjects, 'http://purl.org/dc/terms/subject', class_name: 'Subject', multivalued: true

end

class Person
	include Tripod::Resource

	rdf_type 'http://schema.org/Person'

	field :name, 'http://schema.org/name'
  field :image, 'http://schema.org/image', uri: true

  linked_from :writtenQuestions, :tablingMember, class_name: 'WrittenQuestion', multivalued: true

  # linked_to :hasRegisteredInterests, 'http://data.parliament.uk/schema/parl#hasRegisteredInterest', class_name: 'RegisteredInterest', multivalued: true
end

# class RegisteredInterest
# 	include Tripod::Resource

# 	rdf_type 'http://data.parliament.uk/schema/parl#RegisteredInterest'

# 	field :name, 'http://data.parliament.uk/schema/parl#registeredInterest'

# 	linked_from :belongsTo, :hasRegisteredInterests, class_name: 'Person'
# end

