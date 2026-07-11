require "test_helper"

module Airtable
  class SubmissionSyncTest < ActiveSupport::TestCase
    setup do
      ENV["AIRTABLE_API_KEY"] = "test-key"
      ENV["AIRTABLE_BASE_ID"] = "appTEST123"
      ENV["AIRTABLE_TABLE_NAME"] = "Applications"
    end

    teardown do
      ENV.delete("AIRTABLE_API_KEY")
      ENV.delete("AIRTABLE_BASE_ID")
      ENV.delete("AIRTABLE_TABLE_NAME")
    end

    test "creates an Airtable record with the submission fields, including the Slack ID" do
      stub = stub_request(:post, "https://api.airtable.com/v0/appTEST123/Applications")
        .with { |req|
          fields = JSON.parse(req.body)["fields"]
          fields["Slack_ID"] == "U123" && fields["Applicant"] == "Ada Lovelace" && fields["Email"] == "teen@example.com"
        }
        .to_return(status: 200, body: { id: "recABC123" }.to_json, headers: { "Content-Type" => "application/json" })

      record_id = SubmissionSync.new(submission).call

      assert_equal "recABC123", record_id
      assert_requested stub
    end

    test "uploads each photo to the created record" do
      stub_request(:post, "https://api.airtable.com/v0/appTEST123/Applications")
        .to_return(status: 200, body: { id: "recABC123" }.to_json)

      upload_stub = stub_request(:post, "https://content.airtable.com/v0/appTEST123/recABC123/Photos/uploadAttachment")
        .with { |req| JSON.parse(req.body)["filename"] == "progress.png" }
        .to_return(status: 200, body: "{}")

      photo = FakeUpload.new(filename: "progress.png", content_type: "image/png", contents: "fake-bytes")

      SubmissionSync.new(submission, photos: [ photo ]).call

      assert_requested upload_stub
    end

    test "raises when Airtable rejects the record" do
      stub_request(:post, "https://api.airtable.com/v0/appTEST123/Applications")
        .to_return(status: 422, body: { error: "INVALID_REQUEST" }.to_json)

      assert_raises(SubmissionSync::Error) do
        SubmissionSync.new(submission).call
      end
    end

    private

    def submission
      SubmissionForm.new(
        identity_uid: "ident!abc",
        email: "teen@example.com",
        slack_id: "U123",
        verification_status: "verified",
        ysws_eligible: true,
        legal_first_name: "Ada",
        legal_last_name: "Lovelace",
        project_description: "A synth.",
        policy_confirmed: true
      )
    end

    class FakeUpload
      def initialize(filename:, content_type:, contents:)
        @filename = filename
        @content_type = content_type
        @contents = contents
      end

      attr_reader :content_type

      def original_filename
        @filename
      end

      def read
        @contents
      end
    end
  end
end
