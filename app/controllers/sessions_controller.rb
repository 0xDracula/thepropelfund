class SessionsController < ApplicationController
  def new
    redirect_to root_path if current_identity
  end

  def create
    auth = request.env["omniauth.auth"]
    raw_info = auth&.extra&.raw_info || {}

    session[:identity] = {
      uid: auth&.uid,
      name: auth&.info&.name,
      email: auth&.info&.email,
      slack_id: raw_info["slack_id"],
      verification_status: raw_info["verification_status"],
      ysws_eligible: raw_info["ysws_eligible"]
    }

    redirect_to root_path, notice: "Signed in as #{session[:identity][:name]}"
  end

  def failure
    @message = params[:message]
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
