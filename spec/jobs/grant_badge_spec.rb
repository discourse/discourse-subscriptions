
RSpec.describe Jobs::GrantBadge, type: :job do
  let(:users) { [Fabricate(:user), Fabricate(:user)] }
  let(:badge) { Fabricate(:badge, name: 'el-grande') }

  before do
    SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(badge.name)
  end

  it 'grants all the users the badge'
end
