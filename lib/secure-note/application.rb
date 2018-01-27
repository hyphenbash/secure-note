require 'dotenv/load'
require 'securerandom'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/activerecord'
require 'sinatra/bootstrap'
require 'slim'

module SecureNote
  class Application < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::Contrib
    register Sinatra::Bootstrap::Assets

    set :database_file, File.expand_path('../../../config/database.yml', __FILE__)
    set :views, File.expand_path('../views', __FILE__)

    configure :production, :development do
      enable :logging
    end

    get '/secure-notes' do
      @notes = Note.all
      slim :index
    end

    get '/secure-notes/new' do
      @note = Note.new
      slim :new
    end

    post '/secure-notes' do
      @note = Note.new(note_params)

      respond_to do |f|
        if @note.save!
          f.html { redirect "/secure-notes/#{@note.uuid}" }
          f.json { @note }
        else
          f.html { redirect '/secure-notes/new' }
        end
      end
    end

    get '/secure-notes/:uuid' do
      set_note
      slim :get_note_form
    end

    post '/secure-notes/:uuid' do
      set_note

      respond_to do |f|
        if @note && @note.authenticate(params[:password])
          f.html { slim :note }
        else
          f.html { slim :get_note_form }
        end
      end
    end

    private

    def set_note
      @note = Note.find_by(uuid: params[:uuid])
    end

    def permit_params(*permitted_params)
      params.select { |param| permitted_params.include? param.to_sym }
    end

    def note_params
      permit_params(
          :uuid,
          :title,
          :body_text,
          :password
      )
    end
  end
end
