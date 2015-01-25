describe 'ExampleApp' do
  before do
    app
    Task.destroy_all
  end

  describe "html" do
    describe "valid" do
      it "should return all tasks" do
        task = Task.create(text: 'clean weather')
        get '/tasks'
        last_response.status.should == 200
      end

      it "should return a task" do
        task = Task.create(text: 'test')
        get "/tasks/#{task.id}"
        last_response.status.should == 200
      end

      it "should create a task" do
        task = Task.new(text: 'Random')
        post "/tasks", ::Serializers::Tasks.new([task]).to_json
        last_response.status.should == 303
        Task.first(text: 'Random').should be_an_instance_of Task
      end

      it "should update a task" do
        task = Task.create(text: 'cats')
        task_update = Task.new(text: 'Random')
        put "/tasks/#{task.id}", Serializers::Tasks.new([task_update]).to_json
        last_response.status.should == 303
        task.reload
        task.text.should == task_update.text
      end
    end

    describe "invalid" do
      it "should fail to create a task" do
        task = Task.new(name: 'invalid')
        post "/tasks", Serializers::Tasks.new([task]).to_json
        last_response.status.should == 303
        Task.first(name: 'invalid').should be_nil
      end

      it "should fail to update a task" do
        task = Task.create(text: 'cats')
        task_update = Task.new(text: 'Random', bad_attribute: 'dogs')
        put "/tasks/#{task.id}", Serializers::Tasks.new([task_update]).to_json
        last_response.status.should == 303
        old_text = task.text
        task.reload
        task.text.should == old_text
      end
    end
  end

  describe "json" do
    before do
      header "Accept", "application/json"
      header "CONTENT_TYPE", "application/json"
    end

    describe "valid" do
      it "should return all tasks" do
        task = Task.create(text: 'clean weather')
        get '/tasks'
        last_response.status.should == 200
        last_response.body.should == Serializers::Tasks.new(Task.all()).to_json
      end

      it "should return a task" do
        task = Task.create(text: 'test')
        get "/tasks/#{task.id}"
        last_response.status.should == 200
        last_response.body.should == Serializers::Tasks.new([task]).to_json
      end

      it "should create a task" do
        task = Task.new(text: 'Random')
        post "/tasks", Serializers::Tasks.new([task]).to_json
        JSON.parse(last_response.body)['tasks'][0]['text'].should == task.text
      end

      it "should update a task" do
        task = Task.create(text: 'cats')
        task_update = Task.new(text: 'Random')
        put "/tasks/#{task.id}", Serializers::Tasks.new([task_update]).to_json
        JSON.parse(last_response.body)['tasks'][0]['text'].should == task_update.text
      end
   end

    describe "invalid" do
      it "should fail to create a task" do
        task = Task.new(name: 'invalid')

        post "/tasks", Serializers::Tasks.new([task]).to_json
        last_response.status.should == 400

        Task.find_by_name('invalid').should be_nil

        JSON.parse(last_response.body)['errors']['text'][0].should == "can't be blank"
      end

      it "should fail to update a task" do
        task = Task.create(text: 'cats')
        task_update = Task.new(text: 'new_tex', bad_attribute: 'Random')

        put "/tasks/#{task.id}", Serializers::Tasks.new([task_update]).to_json
        last_response.status.should == 400

        task.reload
        task.text.should == task.text

        JSON.parse(last_response.body)['errors']['bad_attribute'][0].should == "Can't touch this!"
      end
    end
  end

  it "should return json using to_json" do
    header "Accept", "application/json"
    header "CONTENT_TYPE", "application/json"

    bob = {'name' => 'bob'}

    get '/to-json'
    JSON.parse(last_response.body).should == bob.to_h
  end
end
