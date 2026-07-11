class SubmissionsController < ApplicationController
  before_action :require_identity

  def new
    @submission = SubmissionForm.new(identity_attributes)
  end

  def create
    @submission = SubmissionForm.new(submission_params.to_h.merge(identity_attributes))

    if @submission.valid?
      redirect_to submit_thanks_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
  end

  private

  def identity_attributes
    {
      identity_uid: current_identity.uid,
      identity_name: current_identity.name,
      email: current_identity.email,
      slack_id: current_identity.slack_id,
      verification_status: current_identity.verification_status,
      ysws_eligible: current_identity.ysws_eligible
    }
  end

  def submission_params
    params.require(:submission).permit(
      :preferred_name, :legal_first_name, :legal_last_name, :age, :school, :coding_club,
      :grant_purpose, :phone, :project_description, :impact, :estimated_time, :money_use,
      :amount_requested, :uniqueness_explanation, :inspiration, :additional_notes, :policy_confirmed
    )
  end
end
