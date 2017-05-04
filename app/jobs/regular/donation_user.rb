
module Jobs
  class DonationUser < ::Jobs::Base
    def execute(args)
      User.create(args)
    end
  end
end
