require 'rails_helper'

feature 'home'  do
	context 'when visiting the home page' do
		before(:each) do
			visit root_path
		end

		scenario 'should display text Home' do
			expect(page).to have_text 'Home'
		end

		scenario 'should have a link for concepts' do
			expect(page).to have_link 'Concepts'
		end

		scenario 'should have a link for people' do
			expect(page).to have_link 'People'
		end

		# scenario 'the link for concepts should take you to the concepts index' do
		# 	click_link('Concepts')
		# 	stub_request(:post, "http://data.ukpds.org/repositories/TempWorkerSimple").
  #        	with(:body => "query=PREFIX+dcterms%3A+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2F%3E%0A%09%09%09%09%09%09SELECT+%3Furi%0A%09%09%09%09%09%09WHERE+%7B%0A%09%09%09%09%09%09++++%3Fquestion+dcterms%3Asubject+%3Furi%0A%09%09%09%09%09%09%7D%0A%09%09%09%09%09%09GROUP+BY+%3Furi%0A%09%09%09%09%09%09ORDER+BY+DESC%28COUNT%28%3Fquestion%29%29%0A%09%09%09%09%09%09LIMIT+50%0A%09%09%09%09%09%09",
  #                :headers => {'Accept'=>'application/sparql-results+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  #        	to_return(:status => 200, :body => "", :headers => {})
		# 	expect(current_path).to eq '/concepts'
		# end
	end
end