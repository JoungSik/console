module Todo
  module ItemsHelper
    # 마감일 상태에 따른 CSS 클래스 반환
    def due_date_css_class(item)
      if item.overdue?
        "text-red-600 dark:text-red-400 font-medium"
      elsif item.due_today?
        "text-yellow-600 dark:text-yellow-400 font-medium"
      else
        "text-gray-500 dark:text-gray-400"
      end
    end
  end
end
