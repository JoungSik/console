# Web Push 구독 관리 컨트롤러
class Mypage::PushSubscriptionsController < Mypage::ApplicationController
  skip_forgery_protection

  # POST /mypage/push_subscriptions
  def create
    subscription = Current.user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    if subscription.update(
      p256dh_key: subscription_params[:p256dh_key],
      auth_key: subscription_params[:auth_key]
    )
      render json: { id: subscription.id, status: "subscribed" }, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /mypage/push_subscriptions/:id
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
