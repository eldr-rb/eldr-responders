require 'eldr'
require 'mongo_mapper'
require 'oat'
require 'oat/adapters/json_api'
require_relative '../lib/eldr/responders'
require 'slim'

MongoMapper.setup({'test' => {'uri' => 'mongodb://localhost:27017/eldr_responders'}}, 'test')

class Task
  include MongoMapper::Document
  ##
  # Keys
  ##
  key :text,          String
  key :name,          String
  key :bad_attribute, String
  key :done, Boolean, default: false

  validate :custom_validation

  def custom_validation
    errors.add(:bad_attribute, "Can't touch this!") unless self[:bad_attribute].nil?
  end

  ##
  # Key Settings
  ##
  validates_presence_of :text
  attr_accessible :text, :done, :name, :bad_attribute
end

module Serializers
  class Task < Oat::Serializer
    adapter ::Oat::Adapters::JsonAPI

    schema do
      type "tasks"
      property :text,       item.text
      property :done,       item.done
      property :bad_attribute, item.bad_attribute unless item.bad_attribute.blank?
    end
  end

  class Tasks < Oat::Serializer
    adapter ::Oat::Adapters::JsonAPI

    schema do
      type "tasks"
      link :self, href: '/tasks'
      collection :tasks, item, Task
    end
  end
end

class App < Eldr::App
  include Eldr::Sessions
  include Eldr::Responders
  use Rack::Session::Cookie, secret: 'sessions_secret'
  use Rack::Flash, :accessorize => [:notice, :error]

  set :views_dir,  File.join(__dir__, 'views')
  set :session_id, 'sessionsRawesome'

  get '/to-json' do
    bob = {name: 'bob'}
    respond bob
  end

  get '/tasks', name: 'all' do
    respond Task.all()
  end

  get '/tasks/:id' do
    respond Task.find params['id']
  end

  post '/tasks' do
    @task = Task.create(JSON.parse(request.body.read)['tasks'][0])
    respond @task
  end

  put '/tasks/:id' do
    @task = Task.find params['id']
    task_json = JSON.parse(request.body.read)['tasks'][0]
    begin
      @task.update_attributes!(task_json)
    rescue
    end
    respond @task
  end
end

run App
