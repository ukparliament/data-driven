class DivisionsController < ApplicationController
	def index
		@divisions = Division.all.resources
	end
end
