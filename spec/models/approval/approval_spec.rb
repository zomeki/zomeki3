require 'rails_helper'

RSpec.describe Approval::Approval, type: :model do
  let(:approval_flow) { create(:approval_approval_flow) }

  it 'has a valid factory' do
    approval = approval_flow.approvals.build(attributes_for :approval_approval)
    expect(approval).to be_valid
  end

  it 'is invalid without a index' do
    approval = approval_flow.approvals.build(attributes_for :approval_approval)
    approval.index = nil
    approval.validate
    expect(approval.errors[:index].size).to eq 1
  end
end
