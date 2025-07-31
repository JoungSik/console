module ApplicationHelper
  def enum_kr(model_class, enum_name, enum_value)
    return "" if enum_value.blank?

    I18n.t("activerecord.enums.#{model_class.model_name.i18n_key}.#{enum_name}.#{enum_value}",
           default: enum_value.humanize)
  end

  def enum_options_for_select(model_class, enum_name, include_blank: false)
    options = model_class.send("#{enum_name}s").keys.map do |key|
      [ enum_kr(model_class, enum_name, key), key ]
    end

    if include_blank
      options.unshift([ "선택하세요", "" ])
    end

    options
  end
end
