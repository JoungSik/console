class Mypage::PushRegistrationsController < Mypage::ApplicationController
  def create
    registration = PushRegistration.transaction do
      Current.session.push_registrations
             .where(platform: registration_params[:platform])
             .where.not(firebase_installation_id: registration_params[:firebase_installation_id])
             .destroy_all

      PushRegistration.find_or_initialize_by(
        firebase_installation_id: registration_params[:firebase_installation_id]
      ).tap do |push_registration|
        push_registration.assign_attributes(
          user: Current.user,
          session: Current.session,
          platform: registration_params[:platform],
          device_model: registration_params[:device_model],
          os_version: registration_params[:os_version],
          app_version: registration_app_version,
          last_registered_at: Time.current
        )
        push_registration.save!
      end
    end

    render json: {
      id: registration.id,
      status: "registered",
      destroy_url: mypage_push_registration_path(registration)
    }, status: :created
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def destroy
    registration = Current.session.push_registrations.find(params[:id])
    registration.destroy!

    render json: { status: "unregistered" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "not_found" }, status: :not_found
  end

  private

  def registration_app_version
    return Rails.application.config.x.app_version if registration_params[:platform] == "web"

    registration_params[:app_version]
  end

  def registration_params
    params.require(:push_registration).permit(
      :firebase_installation_id,
      :platform,
      :device_model,
      :os_version,
      :app_version
    )
  end
end
