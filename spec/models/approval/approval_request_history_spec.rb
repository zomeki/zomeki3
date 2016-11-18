require 'rails_helper'

RSpec.describe Approval::ApprovalRequestHistory, type: :model do
  it 'has a valid factory' do
    history = build(:approval_approval_request_history)
    expect(history).to be_valid
  end
end
