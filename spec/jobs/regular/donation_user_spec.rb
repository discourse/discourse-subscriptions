require 'rails_helper'

RSpec.describe Jobs::DonationUser, type: :job do
  let(:args) { { email: 'captain-sensible@example.com', username: 'wot', name: 'captain', password: 'wot' } }

  before do
    SiteSetting.stubs(:enable_badges).returns(true)
  end

  it 'creates a new user with no rewards' do
    aggregate_failures do
      expect{ subject.execute(args) }.to change{ User.count }.by(1)
      user = User.find_by_email(args[:email])
      expect(user.badges).to be_empty
      expect(user.groups).to be_empty
    end
  end

  describe 'rewards' do
    let(:user) { Fabricate(:user) }
    let(:badge) { Fabricate(:badge) }
    let(:grp) { Fabricate(:group) }

    before do
      User.expects(:create!).returns(user)
    end

    it 'grants the user a badge' do
      subject.execute(args.merge(rewards: [{ type: 'badge', name: badge.name }]))
      aggregate_failures do
        expect(user.badges).to include(badge)
        expect(user.groups).to be_empty
      end
    end

    it 'adds the user to the group' do
      subject.execute(args.merge(rewards: [{ type: 'group', name: grp.name }]))
      aggregate_failures do
        expect(user.badges).to be_empty
        expect(user.groups).to include(grp)
      end
    end

    it 'has no collisions in badges' do
      Fabricate(:badge, name: 'weiner_schitzel')
      subject.execute(args.merge(rewards: [{ type: 'group', name: 'weiner_schitzel' }]))
      expect(user.badges).to be_empty
    end

    it 'has no collisions in groups' do
      Fabricate(:group, name: 'dude_ranch')
      subject.execute(args.merge(rewards: [{ type: 'badge', name: 'dude_ranch' }]))
      expect(user.groups).to be_empty
    end
  end
end
