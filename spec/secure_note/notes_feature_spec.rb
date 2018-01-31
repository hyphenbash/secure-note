feature 'Page/Notes Scenarios', fakefs: true do
  let(:valid_params) {
    {
        title: 'Test Note Title',
        body_text: 'This is a test note body text.',
        password: '12345'
    }
  }

  let(:updated_valid_params) {
    {
        title: 'Updated Test Note Title',
        body_text: 'This is an updated test note body text.',
        password: ''
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
    FakeFS {
      # TODO: should get rid of this!
      # Temp Fake - didn't have time for investigation of why

      app_root = '../../..'
      gems_path = "#{ENV['GEM_HOME']}/gems"

      views_directory = File.expand_path("#{app_root}/lib/secure-note/views", __FILE__)
      FakeFS::FileSystem.clone(views_directory)

      %w(
        activesupport-5.1.4/lib/active_support/locale/en.yml
        activemodel-5.1.4/lib/active_model/locale/en.yml
        activerecord-5.1.4/lib/active_record/locale/en.yml
      ).each do |fp|
        file_path = File.expand_path("#{gems_path}/#{fp}", __FILE__)
        FakeFS::FileSystem.clone(file_path)
      end
    }
  end

  before do
    visit '/secure-notes/new'
  end

  feature 'Page/New Note' do
    context 'when invalid form data was entered' do
      scenario 'submission fails' do
        fill_post_note_form invalid_params

        click_button 'Submit'

        expect(page).to have_content missing_title_error
        expect(page).to have_content missing_body_text_error
        expect(page).to have_content missing_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'submission succeeds' do
        fill_post_note_form valid_params

        click_button 'Submit'

        fill_in_get_note_form valid_params[:password]

        click_button 'Submit'

        expect(page).to have_content valid_params[:title]
        expect(page).to have_content valid_params[:body_text]
      end
    end
  end

  feature 'Page/Show Note' do
    before do
      fill_post_note_form valid_params

      click_button 'Submit'

      visit '/secure-notes'
      click_link 'View Note'
    end

    context 'when invalid form data was entered' do
      scenario 'note access fails' do
        fill_in_get_note_form invalid_params[:password]

        click_button 'Submit'

        expect(page).to have_content wrong_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'note access succeeds' do
        fill_in_get_note_form valid_params[:password]

        click_button 'Submit'

        expect(page).to have_content valid_params[:title]
        expect(page).to have_content valid_params[:body_text]
      end
    end
  end

  feature 'Page/Edit Note' do
    before do
      fill_post_note_form valid_params

      click_button 'Submit'

      visit '/secure-notes'
      click_link 'Edit Note'
    end

    context 'when invalid form data was entered' do
      scenario 'edit note access fails' do
        fill_in_get_note_form invalid_params[:password]

        click_button 'Submit'

        expect(page).to have_content wrong_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'edit note access succeeds' do
        fill_in_get_note_form valid_params[:password]

        click_button 'Submit'

        expect(page).to have_field 'Title', with: valid_params[:title]
        expect(page).to have_field 'Note', with: valid_params[:body_text]
      end
    end
  end

  feature 'Page Action/Update Note' do
    before do
      fill_post_note_form valid_params

      click_button 'Submit'

      visit '/secure-notes'

      click_link 'Edit Note'

      fill_in_get_note_form valid_params[:password]

      click_button 'Submit'
    end

    context 'when invalid updated form data was entered' do
      scenario 'submission fails' do
        fill_post_note_form invalid_params

        click_button 'Submit'

        expect(page).to have_content missing_title_error
        expect(page).to have_content missing_body_text_error
      end
    end

    context 'when valid updated form data was entered' do
      scenario 'submission succeeds' do
        fill_post_note_form updated_valid_params

        click_button 'Submit'

        fill_in_get_note_form valid_params[:password]

        click_button 'Submit'

        expect(page).to have_content updated_valid_params[:title]
        expect(page).to have_content updated_valid_params[:body_text]
      end
    end
  end

  feature 'Page/Remove Note' do
    before do
      fill_post_note_form valid_params

      click_button 'Submit'

      visit '/secure-notes'
      click_link 'Remove Note'
    end

    context 'when invalid form data was entered' do
      scenario 'remove note access fails' do
        fill_in_get_note_form invalid_params[:password]

        click_button 'Submit'

        expect(page).to have_content wrong_password_error
      end
    end

    context 'when valid form data was entered' do
      scenario 'remove note access succeeds' do
        fill_in_get_note_form valid_params[:password]

        click_button 'Submit'

        expect(page).to have_content valid_params[:title]
        expect(page).to have_content valid_params[:body_text]
        expect(page).to have_content 'Cancel'
        expect(page).to have_content 'Delete Note'
      end
    end
  end

  feature 'Page Action/Delete Note' do
    before do
      fill_post_note_form valid_params

      click_button 'Submit'

      visit '/secure-notes'

      click_link 'Remove Note'

      fill_in_get_note_form valid_params[:password]

      click_button 'Submit'
    end

    scenario 'when note is destroyed successfully' do
      click_button 'Delete Note'

      within 'table' do
        expect(page).not_to have_content valid_params[:title]
      end
    end
  end
end