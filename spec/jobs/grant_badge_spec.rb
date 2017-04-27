
RSpec.describe Jobs::GrantBadge, type: :job do
  let(:users) { [Fabricate(:user), Fabricate(:user)] }
  let(:badge) { Fabricate(:badge, name: 'el-grande') }

  before do
    SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(badge.name)
    PluginStore.set('discourse-donations', 'badge:grant', [users.first.email, users.last.email])
  end

  it 'grants all the users the badge' do
    Jobs::GrantBadge.new.execute(nil)
    aggregate_failures do
      expect(users.first.badges).to include(badge)
      expect(users.last.badges).to include(badge)
    end
  end
end
