require 'rails_helper'

module DiscourseDonations
  RSpec.describe DiscourseDonations::Rewards do
    let(:grp) { Fabricate(:group) }
    let(:user) { Fabricate(:user) }
    subject { described_class.new(user) }

    it 'adds the user to a group' do
      Group.expects(:find_by_name).with(grp.name).returns(grp)
      grp.expects(:add).with(user)
      subject.expects(:log_group_add).once
      subject.add_to_group(grp.name)
    end

    it 'does not add the user to a group' do
      Group.expects(:find_by_name).with(grp.name).returns(nil)
      grp.expects(:add).never
      subject.expects(:log_group_add).never
      expect(subject.add_to_group(grp.name)).to be_falsy
    end

    it 'logs the group add' do
      GroupActionLogger.any_instance.expects(:log_add_user_to_group)
      subject.add_to_group(grp.name)
    end

    describe '.grant_badge' do
      let(:badge) { Fabricate(:badge) }

      before { SiteSetting.stubs(:enable_badges).returns(true) }

      it 'grants the user a badge' do
        BadgeGranter.expects(:grant).with(badge, user)
        subject.grant_badge(badge.name)
      end

      it 'does not grant the user a badge when the badge does not exist' do
        Badge.stubs(:find_by_name).returns(nil)
        BadgeGranter.expects(:grant).never
        expect(subject.grant_badge('does not exist')).to be_falsy
      end

      it 'does not grant the user a badge when badges are disabled' do
        SiteSetting.stubs(:enable_badges).returns(false)
        BadgeGranter.expects(:grant).never
        subject.grant_badge(badge.name)
      end
    end
  end
end
