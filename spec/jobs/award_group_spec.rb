
RSpec.describe Jobs::AwardGroup, type: :job do
  let(:users) { [Fabricate(:user), Fabricate(:user)] }
  let(:grp) { Fabricate(:group, name: 'chimichanga') }

  before do
    SiteSetting.stubs(:discourse_donations_reward_group_name).returns(grp.name)
    PluginStore.set('discourse-donations', 'group:add', [users.first.email, users.last.email])
  end

  it 'adds the users to the group' do
    Jobs::AwardGroup.new.execute
    aggregate_failures do
      expect(users.first.groups).to include(grp)
      expect(users.last.groups).to include(grp)
    end
  end
end
