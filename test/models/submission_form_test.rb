require "test_helper"

class SubmissionFormTest < ActiveSupport::TestCase
  def valid_attributes
    {
      email: "teen@example.com",
      legal_first_name: "Ada",
      legal_last_name: "Lovelace",
      project_description: "A synth I'm building from scratch.",
      policy_confirmed: true
    }
  end

  test "valid with the required fields and policy accepted" do
    form = SubmissionForm.new(valid_attributes)

    assert form.valid?
  end

  test "invalid without an email" do
    form = SubmissionForm.new(valid_attributes.merge(email: nil))

    assert_not form.valid?
    assert_includes form.errors[:email], "can't be blank"
  end

  test "invalid without a legal first or last name" do
    form = SubmissionForm.new(valid_attributes.merge(legal_first_name: "", legal_last_name: ""))

    assert_not form.valid?
    assert_includes form.errors[:legal_first_name], "can't be blank"
    assert_includes form.errors[:legal_last_name], "can't be blank"
  end

  test "invalid unless the policy checkbox is accepted" do
    form = SubmissionForm.new(valid_attributes.merge(policy_confirmed: false))

    assert_not form.valid?
    assert_includes form.errors[:policy_confirmed], "must be accepted"
  end

  test "invalid with a non-positive amount requested" do
    form = SubmissionForm.new(valid_attributes.merge(amount_requested: 0))

    assert_not form.valid?
    assert_includes form.errors[:amount_requested], "must be greater than 0"
  end

  test "amount requested is optional" do
    form = SubmissionForm.new(valid_attributes.merge(amount_requested: nil))

    assert form.valid?
  end
end
