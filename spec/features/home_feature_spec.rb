require 'rails_helper'

feature 'home'  do
	context 'when visiting the home page' do
		scenario 'should display text Home' do
			visit root_path
			expect(page).to have_text 'Home'
		end
	end
end