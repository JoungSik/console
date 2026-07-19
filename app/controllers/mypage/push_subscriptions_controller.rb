class Mypage::PushSubscriptionsController < Mypage::ApplicationController
  def create
    subscription = Current.user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    if subscription.update(subscription_params.slice(:p256dh_key, :auth_key))
      render json: { id: subscription.id, status: "subscribed" }, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = Current.user.push_subscriptions.find(params[:id])
    subscription.destroy

    render json: { status: "unsubscribed" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Subscription not found" }, status: :not_found
  end

  private

  def subscription_params
    params.require(:push_subscription).permit(:endpoint, :p256dh_key, :auth_key)
  end
end
