# Todo 플러그인

할 일 목록 관리 플러그인. 목록(List)과 항목(Item) 단위로 할 일을 관리하며, 마감일 리마인더 푸시 알림을 지원한다.

## 모델 구조

### Todo::List
| 필드 | 타입 | 설명 |
|------|------|------|
| `title` | string | 목록 제목 (필수, 최대 100자) |
| `user_id` | integer | 소유자 |
| `archived_at` | datetime | 아카이브 일시 |

### Todo::Item
| 필드 | 타입 | 설명 |
|------|------|------|
| `title` | string | 항목 제목 (필수, 최대 200자) |
| `url` | string | 관련 URL (선택) |
| `completed` | boolean | 완료 여부 |
| `due_date` | date | 마감일 |
| `reminder_sent` | boolean | 리마인더 발송 여부 |
| `recurrence` | string | 반복 주기 (daily/weekly/monthly/yearly) |
| `recurrence_ends_on` | date | 반복 종료일 |
| `recurrence_parent_id` | integer | 반복 부모 항목 |

## 푸시 알림

`due_date_reminder` 알림 항목이 `PluginRegistry`에 등록되어 있으며, 사용자가 마이페이지에서 활성/비활성 설정 가능.

### Recurring Job

`Todo::ReminderJob`이 매일 오전 9시에 실행되어 다음 알림을 발송한다:

- **오늘 마감**: 마감일이 오늘인 미완료 항목
- **기한 초과**: 마감일이 지난 미완료 항목 (아직 알림 미발송)

발송 후 `reminder_sent` 플래그가 `true`로 업데이트되어 중복 발송을 방지한다.

#### 설정

`config/recurring.yml`에 등록:

```yaml
production:
  todo_reminders:
    class: Todo::ReminderJob
    queue: default
    schedule: every day at 9am
```

## 데이터 클리너

`Todo::DataCleaner` - 플러그인 비활성화 30일 후 사용자의 모든 할 일 데이터를 삭제한다.
