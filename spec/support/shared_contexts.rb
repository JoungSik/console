# 테스트에서 공통으로 사용하는 컨텍스트 정의
RSpec.shared_context 'with user and todo list' do
  let(:user) { User.create!(name: '테스트', email_address: 'test@example.com', password: 'password123') }
  let(:todo_list) { Todo::List.create!(title: '테스트 리스트', user_id: user.id) }
end
