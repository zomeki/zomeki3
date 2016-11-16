require 'rails_helper'

RSpec.describe Sys::User, type: :model do
  let(:system_admin) { create(:sys_user, :system_admin) }
  let(:site_admin) { create(:sys_user, :site_admin) }

  context 'when id is 1' do
    subject { system_admin }
    it { should be_root }

    it 'can not be deleted' do
      expect { system_admin.destroy }.to raise_error
    end
  end

  context 'when id is not 1' do
    subject { site_admin }
    it { should_not be_root }

    it 'can not be deleted' do
      expect { site_admin.destroy }.to_not raise_error
    end
  end
end
