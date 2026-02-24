# 법적 문서 마크다운 파일 로더
#
# 디렉토리 구조:
#   docs/legal/terms/2025-02-25.md
#   docs/legal/privacy/2025-02-25.md
#
# 파일명(YYYY-MM-DD)이 시행일이며, 가장 최신 버전을 자동으로 서빙한다.
class LegalPageLoader
  LEGAL_PATH = Rails.root.join("docs/legal")
  ALLOWED_PAGES = %i[terms privacy].freeze

  attr_reader :effective_date

  def self.load(page_name)
    new(page_name)
  end

  def initialize(page_name)
    unless ALLOWED_PAGES.include?(page_name.to_sym)
      raise ArgumentError, "허용되지 않는 페이지: #{page_name}"
    end

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

    raise "법적 문서를 찾을 수 없습니다: #{@dir}" if path.nil?

    date = Date.parse(File.basename(path, ".md"))
    [ date, path ]
  end
end
