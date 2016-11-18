require 'rails_helper'

RSpec.describe Approval::ApprovalFlow, type: :model do
  it 'has a valid factory' do
    approval_flow = build(:approval_approval_flow)
    expect(approval_flow).to be_valid
  end

  it 'is invalid without a title' do
    approval_flow = build(:approval_approval_flow, title: nil)
    approval_flow.validate
    expect(approval_flow.errors[:title].size).to eq 1
  end
end
