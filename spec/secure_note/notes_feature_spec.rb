feature 'Page/Notes Scenarios' do
  let(:valid_params) {
    {
        title: 'Test Note Title',
        body_text: 'This is a test note body text.',
        password: 'this is a test password'
    }
  }

  let(:invalid_params) {
    {
        title: '',
        body_text: '',
        password: ''
    }
  }

  let(:missing_title_error) { "Title can't be blank" }
  let(:missing_body_text_error) { "Body text can't be blank" }
  let(:missing_password_error) { "Password can't be blank" }

  feature 'New' do
    before do
      visit '/secure-notes/new'
    end

    context 'when invalid form data was entered' do
      scenario 'submission fails' do
        fill_post_note_form invalid_params

        expect(page).to have_content missing_title_error
        expect(page).to have_content missing_body_text_error
        expect(page).to have_content missing_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'submission succeeds' do
        fill_post_note_form valid_params

        expect(page).to have_selector 'h1', text: "Note: \"#{valid_params[:title]}\""
      end
    end
  end

  feature 'Show' do
    before do
      visit '/secure-notes/:uuid'
    end

    context 'when invalid form data was entered' do
      scenario 'submission fails' do
        fill_in_get_note_form invalid_params[:password]

        expect(page).to have_content missing_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'submission succeeds' do
        fill_in_get_note_form valid_params[:password]

        expect(page).to have_selector 'h1', text: "Note: \"#{valid_params[:title]}\""
        expect(page).to have_content
      end
    end
  end
end