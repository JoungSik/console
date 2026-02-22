require 'rails_helper'

RSpec.describe Todo::Item, type: :model do
  include_context 'with user and todo list'

  subject(:item) { todo_list.items.build(title: '테스트 할일') }

  describe 'validations' do
    it '유효한 항목이 저장된다' do
      expect(item).to be_valid
    end

    context 'url 검증' do
      it 'URL이 비어있으면 유효하다' do
        item.url = ''
        expect(item).to be_valid
      end

      it 'URL이 nil이면 유효하다' do
        item.url = nil
        expect(item).to be_valid
      end

      it 'http:// URL은 유효하다' do
        item.url = 'http://example.com'
        expect(item).to be_valid
      end

      it 'https:// URL은 유효하다' do
        item.url = 'https://example.com/path?q=1'
        expect(item).to be_valid
      end

      it 'ftp:// URL은 유효하지 않다' do
        item.url = 'ftp://example.com'
        expect(item).not_to be_valid
        expect(item.errors[:url]).to include(I18n.t('activerecord.errors.models.todo/item.attributes.url.invalid_url_format'))
      end

      it '프로토콜 없는 URL은 유효하지 않다' do
        item.url = 'example.com'
        expect(item).not_to be_valid
      end

      it '임의 문자열은 유효하지 않다' do
        item.url = 'not-a-url'
        expect(item).not_to be_valid
      end
    end
  end

  describe '#url?' do
    it 'URL이 있으면 true를 반환한다' do
      item.url = 'https://example.com'
      expect(item.url?).to be true
    end

    it 'URL이 nil이면 false를 반환한다' do
      item.url = nil
      expect(item.url?).to be false
    end

    it 'URL이 빈 문자열이면 false를 반환한다' do
      item.url = ''
      expect(item.url?).to be false
    end
  end
end
