# Service Worker 전용 Push 구독 갱신 컨트롤러
# pushsubscriptionchange 이벤트에서 호출되며 CSRF 토큰을 전송할 수 없으므로
# CSRF 보호를 비활성화합니다.
class ServiceWorker::PushSubscriptionsController < ApplicationController
  skip_forgery_protection

  # POST /service_worker/push_subscriptions
  # Service Worker의 pushsubscriptionchange 이벤트에서 호출
  def create
    return render_unauthorized unless Current.user

    subscription = Current.user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    if subscription.update(subscription_params.slice(:p256dh_key, :auth_key))
      render json: { id: subscription.id, status: "subscribed" }, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def subscription_params
    params.require(:push_subscription).permit(:endpoint, :p256dh_key, :auth_key)
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
