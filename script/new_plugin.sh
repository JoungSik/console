#!/bin/bash
# 새 Console 플러그인(Rails Engine) 생성 스크립트
# 사용법: script/new_plugin.sh <plugin_name> <label> <icon> <position>
# 예시: script/new_plugin.sh note "메모" "notebook" 30

set -e

PLUGIN_NAME=$1
LABEL=$2
ICON=${3:-"box"}
POSITION=${4:-100}

if [ -z "$PLUGIN_NAME" ] || [ -z "$LABEL" ]; then
  echo "사용법: $0 <plugin_name> <label> [icon] [position]"
  echo "  plugin_name: 플러그인 이름 (예: note)"
  echo "  label: 네비게이션 표시 이름 (예: 메모)"
  echo "  icon: Lucide 아이콘 이름 (기본: box)"
  echo "  position: 메뉴 정렬 순서 (기본: 100)"
  echo ""
  echo "예시: $0 note \"메모\" \"notebook\" 30"
  exit 1
fi

# CamelCase 모듈명 생성
MODULE_NAME=$(echo "$PLUGIN_NAME" | sed 's/_\([a-z]\)/\U\1/g; s/^\([a-z]\)/\U\1/')
# 복수형 mount path
MOUNT_PATH="${PLUGIN_NAME}s"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE_DIR="$PROJECT_ROOT/engines/$PLUGIN_NAME"

echo "=== 새 플러그인 생성: $PLUGIN_NAME ==="
echo "  모듈명: $MODULE_NAME"
echo "  마운트 경로: /$MOUNT_PATH"
echo "  라벨: $LABEL"
echo "  아이콘: $ICON"
echo "  정렬 순서: $POSITION"
echo ""

# 1. 디렉토리 구조 생성
echo "--- 디렉토리 구조 생성 ---"
mkdir -p "$ENGINE_DIR"/{app/{controllers/$PLUGIN_NAME,models/$PLUGIN_NAME,views/$PLUGIN_NAME},config,db/migrate,lib/$PLUGIN_NAME}

# 2. gemspec
cat > "$ENGINE_DIR/$PLUGIN_NAME.gemspec" << RUBY
require_relative "lib/$PLUGIN_NAME/version"

Gem::Specification.new do |spec|
  spec.name        = "$PLUGIN_NAME"
  spec.version     = ${MODULE_NAME}::VERSION
  spec.authors     = ["Console"]
  spec.summary     = "$LABEL 플러그인"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
RUBY

# 3. lib 파일
cat > "$ENGINE_DIR/lib/$PLUGIN_NAME.rb" << RUBY
require "${PLUGIN_NAME}/version"
require "${PLUGIN_NAME}/engine"

module $MODULE_NAME
end
RUBY

cat > "$ENGINE_DIR/lib/$PLUGIN_NAME/version.rb" << RUBY
module $MODULE_NAME
  VERSION = "0.1.0"
end
RUBY

cat > "$ENGINE_DIR/lib/$PLUGIN_NAME/engine.rb" << RUBY
module $MODULE_NAME
  class Engine < ::Rails::Engine
    isolate_namespace $MODULE_NAME

    initializer "${PLUGIN_NAME}.register_plugin", after: :load_config_initializers do
      ::PluginRegistry.register(
        name: :${MOUNT_PATH},
        label: "$LABEL",
        icon: "$ICON",
        path: "/$MOUNT_PATH",
        position: $POSITION
      )
    end

    initializer "${PLUGIN_NAME}.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
RUBY

# 4. ApplicationController
cat > "$ENGINE_DIR/app/controllers/$PLUGIN_NAME/application_controller.rb" << RUBY
module $MODULE_NAME
  class ApplicationController < ::ApplicationController
    include Console::PluginInterface
  end
end
RUBY

# 5. ApplicationRecord
cat > "$ENGINE_DIR/app/models/$PLUGIN_NAME/application_record.rb" << RUBY
module $MODULE_NAME
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
RUBY

# 6. routes.rb
cat > "$ENGINE_DIR/config/routes.rb" << RUBY
${MODULE_NAME}::Engine.routes.draw do
  # 여기에 라우트를 추가하세요
  # resources :items
  # root "items#index"
end
RUBY

echo ""
echo "=== 플러그인 생성 완료! ==="
echo ""
echo "다음 단계:"
echo "  1. Gemfile에 추가: gem \"$PLUGIN_NAME\", path: \"engines/$PLUGIN_NAME\""
echo "  2. config/routes.rb에 추가: mount ${MODULE_NAME}::Engine, at: \"/$MOUNT_PATH\""
echo "  3. Dockerfile에 gemspec COPY 추가"
echo "  4. bundle install 실행"
echo "  5. 모델, 컨트롤러, 뷰, 마이그레이션 작성"
