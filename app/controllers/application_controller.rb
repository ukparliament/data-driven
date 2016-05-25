class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index

  	# render :text => "hello world controller"

  	kirsty = Person.find('http://data.parliament.uk/members/4355')
  	# kirsty = Person.first
  	# kirsty = Person.where(:name => 'Earl of Oxford and Asquith').first
  	# kirsty = Person.all.limit(1)
  	# kirsty = Person.count
  	# kirsty = Person.where(p => p.hasRegisteredInterests.any(ri => ri.name == ''))
  	# kirsty = Person.where(:hasRegisteredInterests => .any? { |e|  })

  	# render :text => kirsty.resources[0]
  	render :text => kirsty.hasRegisteredInterests.first.belongsTo






  	# c=Concept.find('')
  	# ms=c.questions.map { |q| q.member }


  	# m=Member.find('')
  	# ts=m.questions.map { |q| q.subject }
  end
end

class Person
	include Tripod::Resource

	rdf_type 'http://schema.org/Person'

	field :name, 'http://schema.org/name'
  field :party, 'http://data.parliament.uk/schema/parl#party'

  linked_to :hasRegisteredInterests, 'http://data.parliament.uk/schema/parl#hasRegisteredInterest', class_name: 'RegisteredInterest', multivalued: true
end

class RegisteredInterest
	include Tripod::Resource

	rdf_type 'http://data.parliament.uk/schema/parl#RegisteredInterest'

	field :name, 'http://data.parliament.uk/schema/parl#registeredInterest'

	linked_from :belongsTo, :hasRegisteredInterests, class_name: 'Person'
end

