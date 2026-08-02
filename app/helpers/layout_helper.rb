module LayoutHelper
  NATIVE_MAIN_CLASSES = "px-4 pb-4 sm:px-6 sm:pb-6".freeze
  WEB_MAIN_CLASSES = "p-8".freeze

  def layout_main_classes(additional_classes = nil)
    spacing_classes = hotwire_native_app? ? NATIVE_MAIN_CLASSES : WEB_MAIN_CLASSES
    class_names(spacing_classes, additional_classes)
  end
end
