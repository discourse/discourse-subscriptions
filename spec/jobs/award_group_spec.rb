
RSpec.describe Jobs::AwardGroup, type: :job do
  it 'adds the user to a group' do
    user = Fabricate(:user)
    grp = Fabricate(:group)
    Jobs::AwardGroup.new.execute(email: user.email, group_name: grp.name)
    expect(user.groups).to include(grp)
  end
end
