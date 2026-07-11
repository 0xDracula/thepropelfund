module Airtable
  class SubmissionSync
    Error = Class.new(StandardError)

    def initialize(submission, photos: [])
      @submission = submission
      @photos = photos
    end

    def call
      record_id = create_record
      photos.each { |photo| upload_attachment(record_id, photo) }
      record_id
    rescue Faraday::Error => e
      raise Error, "Airtable request failed: #{e.message}"
    end

    private

    attr_reader :submission, :photos

    def create_record
      response = connection.post("/v0/#{base_id}/#{table_name}") do |req|
        req.body = { fields: fields }.to_json
      end

      raise Error, "Airtable record create failed: #{response.status} #{response.body}" unless response.success?

      JSON.parse(response.body).fetch("id")
    end

    def upload_attachment(record_id, photo)
      response = upload_connection.post("/v0/#{base_id}/#{record_id}/Photos/uploadAttachment") do |req|
        req.body = {
          contentType: photo.content_type,
          filename: photo.original_filename,
          file: Base64.strict_encode64(photo.read)
        }.to_json
      end

      raise Error, "Airtable attachment upload failed: #{response.status} #{response.body}" unless response.success?
    end

    def fields
      {
        "Applicant" => "#{submission.legal_first_name} #{submission.legal_last_name}".strip,
        "Email" => submission.email,
        "Slack_ID" => submission.slack_id,
        "Verification_Status" => submission.verification_status,
        "YSWS_Eligible" => submission.ysws_eligible,
        "Preferred_Name" => submission.preferred_name,
        "Legal_First_Name" => submission.legal_first_name,
        "Legal_Last_Name" => submission.legal_last_name,
        "Age" => submission.age,
        "School" => submission.school,
        "Coding_Club" => submission.coding_club,
        "Grant_Purpose" => submission.grant_purpose,
        "Phone" => submission.phone,
        "Project_Description" => submission.project_description,
        "Impact" => submission.impact,
        "Estimated_Time" => submission.estimated_time,
        "Money_Use" => submission.money_use,
        "Amount_Requested" => submission.amount_requested&.to_f,
        "Uniqueness_Explanation" => submission.uniqueness_explanation,
        "Inspiration" => submission.inspiration,
        "Additional_Notes" => submission.additional_notes,
        "Policy_Confirmed" => submission.policy_confirmed,
        "Identity_UID" => submission.identity_uid,
        "Submitted_At" => Time.current.iso8601
      }.compact
    end

    def connection
      @connection ||= build_connection("https://api.airtable.com")
    end

    def upload_connection
      @upload_connection ||= build_connection("https://content.airtable.com")
    end

    def build_connection(url)
      Faraday.new(url: url) do |f|
        f.headers["Authorization"] = "Bearer #{api_key}"
        f.headers["Content-Type"] = "application/json"
        f.adapter Faraday.default_adapter
      end
    end

    def api_key
      ENV.fetch("AIRTABLE_API_KEY")
    end

    def base_id
      ENV.fetch("AIRTABLE_BASE_ID")
    end

    def table_name
      ENV.fetch("AIRTABLE_TABLE_NAME", "Applications")
    end
  end
end
