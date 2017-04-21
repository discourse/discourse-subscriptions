require 'rails_helper'

module DiscourseDonations
  RSpec.describe DiscourseDonations::Rewards do
    let(:grp) { Fabricate(:group) }
    let(:user) { Fabricate(:user) }
    subject { described_class.new(user) }

    it 'adds the user to a group' do
      Group.expects(:find_by_name).with(grp.name).returns(grp)
      grp.expects(:add).with(user)
      expect(subject.add_to_group(grp.name)).to eq true
    end

    it 'does not add the user to a group' do
      Group.expects(:find_by_name).with(grp.name).returns(nil)
      expect(subject.add_to_group(grp.name)).to eq false
    end

    it 'grants the user a badge'
  end
end
