Cms::Lib::Modules::ModuleSet.draw :biz_calendar, '業務カレンダー', 70 do |mod|
  ## contents
  mod.content :places, '業務カレンダー', publishable: true
  
  ## directory
  mod.directory :places, "拠点一覧"
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :calendars, "休業日カレンダー"
  mod.piece :bussiness_holidays, "休業日一覧"
  mod.piece :bussiness_times, "業務時間"

  ## public models
  mod.public_model :places
  mod.public_model :bussiness_holidays
  mod.public_model :bussiness_hours
  mod.public_model :exception_holidays
  mod.public_model :holiday_types
end
