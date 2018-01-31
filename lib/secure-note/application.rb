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
    use Rack::MethodOverride

    register Sinatra::ActiveRecordExtension
    register Sinatra::Contrib
    register Sinatra::Bootstrap::Assets

    set :database_file, File.expand_path('../../../config/database.yml', __FILE__)
    set :views, File.expand_path('../views', __FILE__)

    enable :sessions

    configure :development, :test do
      enable :logging
    end

    before '/secure-notes/:uuid' do
      set_note
    end

    before '/secure-notes/:uuid/*' do
      set_note
    end

    after '/secure-notes/:uuid/*' do
      session[:notice] = nil
    end

    get '/secure-notes' do
      @notes = Note.all
      notice = session[:notice]
      session[:notice] = nil

      slim :index, :locals => { notice: notice }
    end

    post '/secure-notes' do
      @note = Note.new(note_params)

      respond_to do |f|
        if @note.save
          f.html { status :created; redirect note_view_path, session[:notice] = "Note #{@note.title} was successfully created." }
          f.json { @note.protected_body_text }
        else
          f.html { slim :new }
          f.json { @note.errors.to_json }
        end
      end
    end

    get '/secure-notes/new' do
      @note = Note.new
      slim :new
    end

    get '/secure-notes/:uuid/view' do
      slim :get_note_form, :locals => { action: 'view', notice: session[:notice] }
    end

    post '/secure-notes/:uuid/view' do
      respond_to do |f|
        if @note && @note.verify_password(params[:password])
          f.html { slim :note }
          f.json { json @note }
        else
          f.html { status :unauthorized; slim :get_note_form, :locals => { action: 'view', notice: session[:notice] } }
          f.json { status :unauthorized; @note.errors.to_json }
        end
      end
    end

    get '/secure-notes/:uuid/edit' do
      slim :get_note_form, :locals => { action: 'edit', notice: session[:notice] }
    end

    post '/secure-notes/:uuid/edit' do
      respond_to do |f|
        if @note && @note.verify_password(params[:password])
          f.html { slim :edit }
          f.json { json @note }
        else
          f.html { status :unauthorized; slim :get_note_form, :locals => { action: 'edit', notice: session[:notice] } }
          f.json { status :unauthorized; @note.errors.to_json }
        end
      end
    end

    get '/secure-notes/:uuid/remove' do
      slim :get_note_form, :locals => { action: 'remove', notice: session[:notice] }
    end

    post '/secure-notes/:uuid/remove' do
      respond_to do |f|
        if @note && @note.verify_password(params[:password])
          f.html { slim :remove }
          f.json { json @note }
        else
          f.html { status :unauthorized; slim :get_note_form, :locals => { action: 'remove', notice: session[:notice] } }
          f.json { status :unauthorized; @note.errors.to_json }
        end
      end
    end

    patch '/secure-notes/:uuid' do
      respond_to do |f|
        if @note.update(note_params)
          f.html { status :ok; redirect note_view_path, session[:notice] = "Note #{@note.title} was successfully updated." }
          f.json { @note.protected_body_text }
        else
          f.html { slim :edit }
          f.json { @note.errors.to_json }
        end
      end
    end

    delete '/secure-notes/:uuid' do
      @note.destroy

      respond_to do |f|
        f.html { status :ok; redirect index_path, session[:notice] = "Note #{@note.title} was successfully removed." }
        f.json { { message: "#{@note.title} was successfully removed." } }
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

    def index_path
      '/secure-notes'
    end

    def note_view_path
      "/secure-notes/#{@note.uuid}/view"
    end
  end
end
