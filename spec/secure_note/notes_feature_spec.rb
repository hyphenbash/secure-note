feature 'Page/Notes Scenarios', fakefs: false do
  let(:valid_params) {
    {
        title: 'Test Note Title',
        body_text: 'This is a test note body text.',
        password: '12345'
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

  # before do
  #   FakeFS {
  #
  #     # TODO: should get rid of this!
  #     # Temp Fake - didn't have time for investigation of why
  #
  #     app_root = '../../..'
  #     gems_path = '../../.rvm/gems/ruby-2.3.3/gems'
  #
  #     lib_directory = File.expand_path("#{app_root}/lib/secure-note/views", __FILE__)
  #     FakeFS::FileSystem.clone(lib_directory)
  #
  #     %w(
  #       activesupport-5.1.4/lib/active_support/locale/en.yml
  #       activemodel-5.1.4/lib/active_model/locale/en.yml
  #       activerecord-5.1.4/lib/active_record/locale/en.yml
  #     ).each do |fp|
  #       file_path = File.expand_path("#{app_root}/#{gems_path}/#{fp}", __FILE__)
  #
  #       FakeFS::FileSystem.clone(file_path)
  #     end
  #   }
  # end

  feature 'Page/New Note' do
    before do
      visit '/secure-notes/new'
    end

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

        expect(page).to have_content valid_params[:title]
      end
    end
  end

  feature 'Page/Show Note' do
    before do
      visit '/secure-notes/new'
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
end