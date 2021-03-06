RSpec.describe SecureNote::Application do
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
        body_text: 'This is a test note body text.',
        password: ''
    }
  }

  describe 'GET Routes' do
    it 'access index page (/secure-notes)' do
      get '/secure-notes'
      expect(last_response).to be_ok
    end

    it 'access new page (/secure-notes/new)' do
      get '/secure-notes/new'
      expect(last_response).to be_ok
    end

    it 'access get password protected view note form (/secure-notes/:uuid/view)' do
      allow_any_instance_of(Note).to receive(:save_to_file!)

      note = create(:note, valid_params)

      get "/secure-notes/#{note.uuid}/view"
      expect(last_response).to be_ok
    end

    it 'access get password protected edit note form (/secure-notes/:uuid/edit)' do
      allow_any_instance_of(Note).to receive(:save_to_file!)

      note = create(:note, valid_params)

      get "/secure-notes/#{note.uuid}/edit"
      expect(last_response).to be_ok
    end

    it 'access get password protected remove note form (/secure-notes/:uuid/remove)' do
      allow_any_instance_of(Note).to receive(:save_to_file!)

      note = create(:note, valid_params)

      get "/secure-notes/#{note.uuid}/remove"
      expect(last_response).to be_ok
    end
  end
end