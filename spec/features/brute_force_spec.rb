require 'spec_helper'
require 'support/features/feature_helpers'

feature 'visitor has consecutive bad logins' do
  before do
    Authenticate.configure do |config|
      config.max_consecutive_bad_logins_allowed = 2
      config.bad_login_lockout_period = 10.minutes
    end
    @user = create(:user)
  end

  scenario 'less than max bad logins does not lock account' do
    sign_in_with @user.email, 'badpassword'
    sign_in_with @user.email, 'badpassword'
    sign_in_with @user.email, @user.password

    expect_user_to_be_signed_in
  end

  scenario 'exceeds max bad logins and locks account' do
    sign_in_with @user.email, 'badpassword'
    sign_in_with @user.email, 'badpassword'
    sign_in_with @user.email, 'badpassword'

    expect_locked_account
    expect_lockout_time_to_be_displayed
    expect_user_to_be_signed_out
  end

  scenario 'user locks account, waits for lock to expire, logs in successfully' do
    sign_in_with @user.email, 'badpassword'
    sign_in_with @user.email, 'badpassword'
    sign_in_with @user.email, 'badpassword'

    Timecop.travel 20.minutes do
      sign_in_with @user.email, @user.password
      expect_user_to_be_signed_in
    end
  end

end


def expect_locked_account
  expect(page).to have_content 'Your account is locked'
end

def expect_lockout_time_to_be_displayed
  expect(page).to have_content '10 minutes'
end
