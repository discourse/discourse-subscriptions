require 'rails_helper'

RSpec.describe Jobs::DonationUser, type: :job do
  let(:args) { { email: 'fsfs4@example.com', username: 'sxsomething', name: 'ssbrian', password: 'ssecret-yo' } }

  before do
    SiteSetting.stubs(:enable_badges).returns(true)
  end

  it 'creates a new user' do
    expect{ subject.execute(args) }.to change{ User.count }.by(1)
  end

  describe 'rewards' do
    let(:user) { Fabricate(:user, args) }
    let(:badge) { Fabricate(:badge) }

    it 'has the badge' do
      User.expects(:create!).returns(user)
      subject.execute(args.merge(rewards: { type: 'badge', name: badge.name }))
      expect(user.badges).to include(badge)
    end
  end
end
