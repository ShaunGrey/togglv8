describe 'Workspaces' do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @user = @toggl.me(all=true)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
    @project = @toggl.create_project({ 'name' => 'project with a task', 'wid' => @workspace_id })
  end

  after :all do
    @toggl.delete_project(@project['id'])
  end

  it 'updates workspace data' do
    new_values = {
      'default_currency': 'EUR', 
      'default_hourly_rate': 50, 
      'name': "Sean's ws", 
      'only_admins_may_create_projects': false, 
      'only_admins_see_billable_rates': true, 
      'rounding': 1, 
      'rounding_minutes': 60
    }
    
    expected = new_values.clone
    
    workspace_updated = @toggl.update_workspace(@workspace_id, new_values)
    expect(workspace_updated).to include(expected)    
  end
  
  it 'shows users' do
    users = @toggl.users(@workspace_id)
    expect(users.length).to eq 1
    expect(users.first['id']).to eq Testing::USER_ID
    expect(users.first['email']).to eq Testing::EMAIL
    expect(users.first['fullname']).to eq Testing::USERNAME
    expect(users.first['default_wid']).to eq @workspace_id
  end

  context 'tasks', :pro_account do
    before :each do
      @task = @toggl.create_task('name' => 'workspace task', 'pid' => @project['id'])
    end

    after :each do
      @toggl.delete_task(@task['id'])
    end

    it 'shows tasks' do
      tasks = @toggl.tasks(@workspace_id)
      expect(tasks.length).to eq 1
      expect(tasks.first['name']).to eq 'workspace task'
      expect(tasks.first['pid']).to eq @project['id']
      expect(tasks.first['wid']).to eq @workspace_id
    end
  end
end
