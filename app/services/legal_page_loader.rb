# 법적 문서 마크다운 파일 로더
#
# 디렉토리 구조:
#   docs/legal/terms/2025-02-25.md
#   docs/legal/privacy/2025-02-25.md
#
# 파일명(YYYY-MM-DD)이 시행일이며, 가장 최신 버전을 자동으로 서빙한다.
class LegalPageLoader
  LEGAL_PATH = Rails.root.join("docs/legal")

  attr_reader :effective_date

  def self.load(page_name)
    new(page_name)
  end

  def initialize(page_name)
    @dir = LEGAL_PATH.join(page_name.to_s)
    @effective_date, @path = latest_version
  end

  def to_html
    content = File.read(@path)
    Kramdown::Document.new(content, input: "GFM").to_html.html_safe
  end

  private

  # 디렉토리 내 YYYY-MM-DD.md 파일 중 가장 최신 파일을 반환
  def latest_version
    files = Dir.glob(@dir.join("*.md")).sort
    path = files.last
    date = Date.parse(File.basename(path, ".md"))
    [ date, path ]
  end
end
