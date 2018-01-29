feature 'Page/Notes Scenarios', fakefs: true do
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
  let(:wrong_password_error) { "Password is invalid" }

  before do
    FakeFS { FileUtils.mkdir_p('notes_directory') }
  end

  feature 'New' do
    before do
      visit '/secure-notes/new'
    end

    context 'when invalid form data was entered' do
      scenario 'submission fails' do
        fill_post_note_form_and_submit invalid_params

        expect(page).to have_content missing_title_error
        expect(page).to have_content missing_body_text_error
        expect(page).to have_content missing_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'submission succeeds' do
        fill_post_note_form_and_submit valid_params

        expect(page).to have_selector 'h1', text: "Note: \"#{valid_params[:title]}\""
      end
    end
  end

  feature 'Show' do
    before do
      note = create(:note, valid_params)

      visit "/secure-notes/#{note.uuid}"
    end

    context 'when invalid form data was entered' do
      scenario 'note access fails' do
        fill_in_get_note_form_and_submit invalid_params[:password]

        expect(page).to have_content wrong_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'note access succeeds' do
        fill_in_get_note_form_and_submit valid_params[:password]

        expect(page).to have_content valid_params[:title]
        expect(page).to have_content valid_params[:body_text]
      end
    end
  end
end