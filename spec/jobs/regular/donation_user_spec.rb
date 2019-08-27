require 'rails_helper'

RSpec.describe Jobs::DonationUser, type: :job do
  let(:args) { { email: 'captain-sensible@example.com', username: 'wot', name: 'captain', password: 'secret121321' } }

  before do
    SiteSetting.stubs(:enable_badges).returns(true)
  end

  it 'creates a new user with no rewards' do
    aggregate_failures do
      expect { subject.execute(args) }.to change { User.count }.by(1)
      user = User.find_by_email(args[:email])
      expect(user.badges).to be_empty
      expect(user.groups).to be_empty
    end
  end

  describe 'sending the signup email' do
    let(:user) { User.find_by_email(args[:email]) }

    it 'has an email token' do
      subject.execute(args)
      expect(user.email_tokens).not_to be_empty
    end

    it 'enqueues the signup email' do
      User.expects(:create!).returns(Fabricate(:user, args))
      Jobs.expects(:enqueue).with(
        :critical_user_email,
        type: :signup, user_id: user.id, email_token: user.email_tokens.first.token
      )
      subject.execute(args)
    end
  end

  describe 'rewards' do
    describe 'create user with rewards' do
      let(:user) { Fabricate(:user) }

      it 'does not create the rewards if the user does not persist' do
        User.expects(:create!).returns(user)
        user.expects(:persisted?).returns(false)
        DiscourseDonations::Rewards.expects(:new).never
        subject.execute(args)
      end

      it 'creates a User object without rewards' do
        User.expects(:create!).with(args).returns(user)
        subject.execute(args.merge(rewards: [], otherthing: nil))
      end
    end

    describe 'User rewards' do
      let(:user) { Fabricate(:user) }
      let(:badge) { Fabricate(:badge) }
      let(:grp) { Fabricate(:group) }

      before do
        User.stubs(:create!).returns(user)
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
end
