# Firebase Cloud Messaging 설정

Console은 Firebase Installation ID(FID)와 FCM HTTP v1 API를 사용해 Web, Android, iOS 푸시 알림을 발송한다.

## 시스템 통합 구조

```text
Web / Hotwire Native
        │
        ▼
Rails Core ─────────────── Rails Engine Plugins
  │  인증·세션                 │  Todo, Journal
  │  사용자 설정               │  플러그인별 알림 생성
  │  FCM 등록·발송             │
  └──────────────┬─────────────┘
                 ▼
        Firebase Cloud Messaging
          ├── Web Push
          ├── Android
          └── APNs → iOS
```

Rails 코어는 사용자, 로그인 세션, FCM 등록과 공통 알림 전달을 관리한다. 플러그인은 `User#send_push_notification`을 호출해 알림을 요청하며 FCM SDK나 Firebase 인증 정보를 직접 다루지 않는다. 플러그인별 알림 활성화 상태는 `PushNotificationSetting`에서 관리한다.

알림은 다음 순서로 전달된다.

1. Web 또는 Native 앱이 FID를 획득한다.
2. 클라이언트가 현재 로그인 세션으로 `POST /mypage/push_registrations`를 호출한다.
3. Rails가 FID, 플랫폼, 사용자와 로그인 세션을 `PushRegistration`에 저장한다.
4. 플러그인 또는 코어 Job이 `User#send_push_notification`을 호출한다.
5. `Fcm::NotificationSender`가 FCM HTTP v1 API로 각 FID에 메시지를 발송한다.
6. FCM이 `UNREGISTERED`를 반환하면 Rails가 해당 등록을 삭제한다.

등록은 로그인 세션에 종속된다. 로그아웃으로 `Session`이 삭제되면 해당 세션의 등록도 함께 삭제된다. 한 로그인 세션에는 플랫폼별 활성 등록을 하나만 두며, FID가 변경되면 기존 등록을 새 등록으로 교체한다. 비활성 상태는 별도로 저장하지 않고 구독 해제 시 `PushRegistration`을 삭제한다.

등록 API는 Rails의 표준 collection/member CRUD를 사용한다.

| 동작 | Method | 경로 |
|---|---|---|
| 등록 생성 또는 갱신 | `POST` | `/mypage/push_registrations` |
| 등록 삭제 | `DELETE` | `/mypage/push_registrations/:id` |

생성 응답은 등록의 `id`와 `destroy_url`을 반환한다. 클라이언트는 설정 페이지에서 전달받거나 생성 응답으로 받은 `destroy_url`을 사용한다. 서버는 member 삭제 시에도 항상 현재 로그인 세션의 등록으로 조회 범위를 제한한다.

## Firebase 프로젝트

1. Firebase Console에서 프로젝트를 생성한다.
2. Google Cloud Console에서 Firebase Cloud Messaging API를 활성화한다.
3. 같은 프로젝트에 Web, Android, iOS 앱을 등록한다.
4. 프로젝트 설정의 서비스 계정 메뉴에서 서버용 서비스 계정 JSON 키를 발급한다.

모든 플랫폼은 같은 Firebase 프로젝트를 사용해야 한다. 다른 Firebase 프로젝트에서 발급된 FID에는 현재 서버 자격증명으로 메시지를 보낼 수 없다.

## Rails credentials

다음 명령으로 환경별 credentials를 편집한다.

```bash
bin/rails credentials:edit
```

서비스 계정 JSON의 필드를 `service_account` 아래에 그대로 옮기고 Web 앱 설정을 추가한다.

```yaml
firebase:
  project_id: console-project
  service_account:
    private_key: |-
      -----BEGIN PRIVATE KEY-----
      ...
      -----END PRIVATE KEY-----
    client_email: firebase-adminsdk@example.iam.gserviceaccount.com
  web:
    api_key: ...
    auth_domain: console-project.firebaseapp.com
    storage_bucket: console-project.firebasestorage.app
    messaging_sender_id: ...
    app_id: ...
    measurement_id: ...
    vapid_public_key: ...
```

서비스 계정 JSON에서 `client_email`과 `private_key`만 옮긴다. JSON 파일이나 private key를 저장소에 추가하지 않는다. `firebase_installation_id` 요청 파라미터는 Rails 로그 필터링 대상이다.

## Web

Firebase Console의 프로젝트 설정 > Cloud Messaging > Web Push certificates에서 VAPID 키를 생성하고 public key를 `firebase.web.vapid_public_key`에 저장한다.

Web 앱은 다음 구성요소를 사용한다.

- Firebase JavaScript SDK `12.17.1` (Firebase 공식 CDN, Importmap)
- `app/javascript/firebase_messaging.js`
- `app/javascript/controllers/web_push_subscription_controller.js`
- `/service-worker.js`

FCM Web Messaging은 운영 환경에서 HTTPS가 필요하다. 사용자가 마이페이지의 푸시 알림 설정에서 알림을 켜면 브라우저 권한을 요청하고 FID를 Rails에 등록한다.

Firebase Web 설정과 foreground 메시지 listener는 Web 푸시 구독 카드가 렌더링된 동안에만 활성화한다. 푸시 설정 페이지에서는 테스트 메시지를 OS 알림으로 확인할 수 있으며, 다른 Console 화면을 보고 있을 때는 foreground 메시지를 OS 알림으로 직접 표시하지 않는다. 페이지가 background이거나 닫힌 경우의 알림은 `/service-worker.js`가 처리한다.

## Android

Android Hotwire Native 프로젝트에서 다음 작업이 필요하다.

1. Firebase Android 앱을 등록하고 package name을 실제 앱과 일치시킨다.
2. `google-services.json`을 Native 프로젝트에 추가한다.
3. Firebase Messaging SDK를 추가한다.
4. `<application>`에 FID 기반 Messaging API를 활성화한다.

   ```xml
   <meta-data
       android:name="firebase_messaging_installation_id_enabled"
       android:value="true" />
   ```

5. Android 13 이상에서 `POST_NOTIFICATIONS` 권한을 요청하고, 그 이하 버전에서도 `NotificationManagerCompat.areNotificationsEnabled()`로 시스템 알림 허용 여부를 확인한다.
6. FCM 등록 콜백에서 받은 FID를 `push-notification` Bridge로 전달한다.
7. 알림을 눌렀을 때 `data.url`을 Hotwire Native 화면으로 연다.

## iOS

iOS Hotwire Native 프로젝트에서 다음 작업이 필요하다.

1. Firebase Apple 앱을 등록하고 bundle ID를 실제 앱과 일치시킨다.
2. `GoogleService-Info.plist`를 Native 프로젝트에 추가한다.
3. Firebase Messaging SDK와 Push Notifications capability를 추가한다.
4. APNs 인증 키를 Firebase Console에 업로드한다.
5. `Info.plist`에서 `FirebaseMessagingInstallationIdEnabled`를 `YES`로 설정한다.
6. `UNUserNotificationCenter.current().notificationSettings()`로 현재 권한을 조회하고 사용자 알림 권한과 remote notification 등록을 처리한다.
7. FCM 등록 콜백에서 받은 FID를 `push-notification` Bridge로 전달한다.
8. 알림을 눌렀을 때 `data.url`을 Hotwire Native 화면으로 연다.

## Hotwire Native Bridge 계약

Bridge component 이름은 `push-notification`이다.
Android와 iOS Bridge adapter는 이 component를 지원 목록에 등록해야 한다.

### Web에서 Native로 보내는 이벤트

| 이벤트 | 요청 데이터 | 동작 |
|---|---|---|
| `connect` | 없음 | 현재 권한과 등록 상태 조회 |
| `subscribe` | 없음 | 권한 요청 후 FCM 등록 |
| `unsubscribe` | `firebaseInstallationId` | 해당 FCM 등록 해제 |

Native 응답의 `data` 형식은 다음과 같다.

```json
{
  "firebaseInstallationId": "firebase-installation-id",
  "platform": "ios",
  "permission": "granted",
  "registered": true
}
```

- `platform`은 `android` 또는 `ios`만 사용한다.
- 미등록 상태에서는 `firebaseInstallationId`를 생략할 수 있다.
- `permission`은 `granted`, `denied`, `prompt` 중 하나를 사용한다.
- `registered`는 Native FCM 등록이 실제로 존재하는지를 나타내며 항상 포함한다.
- 실패 응답은 `error` 오류 코드를 포함한다. 사용자 안내 문구는 Rails 화면에서 상황에 맞는 I18n 메시지를 사용한다.

```json
{
  "error": "permission_denied"
}
```

권한과 구독은 별도 상태다. `connect`는 OS 권한을 요청하지 않고 현재 상태만 조회한다. `subscribe`만 필요한 경우 권한을 요청하며, `unsubscribe`는 Native FCM 등록을 제거한 뒤 결과를 반환한다. 앱이 foreground로 복귀해 WebView가 다시 visible 상태가 되면 Bridge가 `connect`를 다시 전송하므로 Native adapter는 최신 권한과 등록 상태를 반환해야 한다.

Rails 화면은 Web 요청과 Hotwire Native 요청에서 같은 디자인을 사용하지만 실행 controller는 분리한다. Web은 `web-push-subscription`, Native는 `native-push-subscription`과 `bridge--push-notification`을 사용한다. 서버의 현재 세션 `PushRegistration` 존재 여부가 구독 상태의 기준이며, 권한이 허용되어 있다는 이유만으로 새 구독을 자동 생성하지 않는다.

구독 해제는 Rails 등록 삭제를 먼저 완료한 뒤 클라이언트 FCM 등록을 해제한다. Rails 삭제가 완료된 시점부터 서버 발송 대상에서 제외되며, 이후 클라이언트 정리가 실패하면 화면에는 구독 해제 상태와 부분 실패 안내를 표시한다.

## 서버 동작 확인

마이그레이션과 테스트를 실행한다.

```bash
bin/rails db:migrate
bin/rails test
```

Firebase 설정 후 브라우저에서 다음을 확인한다.

1. 푸시 알림을 켰을 때 `push_registrations`에 `platform: web` 등록이 생성된다.
2. foreground와 background에서 알림이 표시된다.
3. 알림을 누르면 `data.url` 화면으로 이동한다.
4. 알림을 끄거나 로그아웃하면 서버 등록이 삭제된다.
5. FCM의 `UNREGISTERED` 응답을 받은 등록은 다음 발송 시 삭제된다.
