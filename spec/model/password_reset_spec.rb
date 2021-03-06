require 'spec_helper'
require 'authenticate/model/password_reset'

describe Authenticate::Model::PasswordReset do
  context 'forgot_password!' do
    subject { create(:user) }
    before { subject.forgot_password! }

    it 'generates a password reset token' do
      expect(subject.password_reset_token).to_not be_nil
    end

    it 'sets password reset sent at' do
      expect(subject.password_reset_sent_at).to_not be_nil
    end
  end

  context '#reset_password_period_valid?' do
    subject { create(:user) }

    it 'always true if reset_password_within config param is nil' do
      within = Authenticate.configuration.reset_password_within
      subject.password_reset_sent_at = 10.days.ago
      Authenticate.configuration.reset_password_within = nil
      expect(subject.reset_password_period_valid?).to be_truthy
      Authenticate.configuration.reset_password_within = within
    end

    it 'false if time exceeded' do
      subject.password_reset_sent_at = 10.minutes.ago
      expect(subject.reset_password_period_valid?).to be_falsey
    end

    it 'true if time within limit' do
      subject.password_reset_sent_at = 1.minutes.ago
      expect(subject.reset_password_period_valid?).to be_truthy
    end
  end

  context '#update_password' do
    subject { create(:user) }

    context 'within time limit' do
      before(:each) { subject.password_reset_sent_at = 1.minutes.ago }

      it 'allows password update within time limit' do
        expect(subject.update_password('password2')).to be_truthy
      end

      it 'clears password reset token' do
        subject.update_password 'password2'
        expect(subject.password_reset_token).to be_nil
      end

      it 'generates a new session token' do
        token = subject.session_token
        subject.update_password 'password2'
        expect(subject.session_token).to_not eq(token)
      end
    end

    context 'after time limit' do
      it 'stops password update' do
        subject.password_reset_sent_at = 6.minutes.ago
        expect(subject.update_password('password2')).to be_falsey
      end
    end

    context 'password_reset_sent_at is nil' do
      it 'stops password update' do
        subject.password_reset_sent_at = nil
        subject.password_reset_token = 'notNilResetToken'
        expect(subject.update_password('password2')).to be_falsey
      end
    end
  end
end

