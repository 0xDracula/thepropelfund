class SubmissionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :identity_uid, :string
  attribute :identity_name, :string
  attribute :email, :string
  attribute :slack_id, :string
  attribute :verification_status, :string
  attribute :ysws_eligible, :boolean

  attribute :preferred_name, :string
  attribute :legal_first_name, :string
  attribute :legal_last_name, :string
  attribute :age, :integer
  attribute :school, :string
  attribute :coding_club, :string
  attribute :grant_purpose, :string
  attribute :phone, :string
  attribute :project_description, :string
  attribute :impact, :string
  attribute :estimated_time, :string
  attribute :money_use, :string
  attribute :amount_requested, :decimal
  attribute :uniqueness_explanation, :string
  attribute :inspiration, :string
  attribute :additional_notes, :string
  attribute :policy_confirmed, :boolean, default: false

  validates :email, presence: true
  validates :legal_first_name, presence: true
  validates :legal_last_name, presence: true
  validates :amount_requested, numericality: { greater_than: 0 }, allow_nil: true
  validates :policy_confirmed, acceptance: true

  def persisted?
    false
  end
end
