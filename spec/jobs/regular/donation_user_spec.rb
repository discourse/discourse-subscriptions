
RSpec.describe Jobs::DonationUser, type: :job do
  it { should respond_to(:execute).with(1).arguments  }

  it 'creates a new user' do
    args = { email: 'foo@example.com', username: 'something' }
    User.expects(:create).with(args)
    subject.execute(args)
  end
end
