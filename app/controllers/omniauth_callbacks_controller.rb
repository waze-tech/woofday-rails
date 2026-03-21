class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access

  def google_oauth2
    user = User.from_omniauth(request.env["omniauth.auth"])

    if user.persisted?
      start_new_session_for(user)
      redirect_to root_path, notice: "Signed in with Google!"
    else
      redirect_to new_session_path, alert: "Could not sign in with Google."
    end
  end

  def failure
    redirect_to new_session_path, alert: "Authentication failed."
  end
end
