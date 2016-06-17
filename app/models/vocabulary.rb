module Vocabulary
	class Skos
		@@prefix = 'http://www.w3.org/2004/02/skos/core#'

		def self.prefLabel
			RDF::URI.new("#{@@prefix}prefLabel")
		end
	end
	
	class Schema
		@@prefix = 'http://schema.org/'
		
		def self.name
			RDF::URI.new("#{@@prefix}name")
		end

		def self.Person
			RDF::URI.new("#{@@prefix}Person")
		end

		def self.text
			RDF::URI.new("#{@@prefix}text")
		end
	end
	
	class Dcterms
		@@prefix = 'http://purl.org/dc/terms/'

		def self.subject
			RDF::URI.new("#{@@prefix}subject")
		end

		def self.date
			RDF::URI.new("#{@@prefix}date")
		end
	end
	
	class Parl
		@@prefix = 'http://data.parliament.uk/schema/parl#'

		def self.OralParliamentaryQuestion
			RDF::URI.new("#{@@prefix}OralParliamentaryQuestion")
		end

		def self.WrittenParliamentaryQuestion
			RDF::URI.new("#{@@prefix}WrittenParliamentaryQuestion")
		end

		def self.member
			RDF::URI.new("#{@@prefix}member")
		end

		def self.house
			RDF::URI.new("#{@@prefix}house")
		end

		def self.count
			RDF::URI.new("#{@@prefix}count")
		end

		def self.voteValue
			RDF::URI.new("#{@@prefix}voteValue")
		end

		def self.divisionTitle
			RDF::URI.new("#{@@prefix}divisionTitle")
		end

		def self.division
			RDF::URI.new("#{@@prefix}division")
		end
	end
	
	class Rdfs
		@@prefix = 'http://www.w3.org/2000/01/rdf-schema#'

		def self.label
			RDF::URI.new("#{@@prefix}label")
		end
	end
end
