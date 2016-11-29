require 'rails_helper'

RSpec.describe Approval::Assignment, type: :model do
  it 'has a valid factory' do
    assignment = build(:approval_assignment)
    expect(assignment).to be_valid
  end

  it 'is invalid without a user' do
    assignment = build(:approval_assignment, user_id: nil)
    assignment.validate
    expect(assignment.errors[:user_id].size).to eq 1
  end
end
