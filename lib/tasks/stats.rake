task stats: :statsetup

task :statsetup do
  require 'rails/code_statistics'
  ::STATS_DIRECTORIES << ["Callbacks", "app/callbacks"]
  ::STATS_DIRECTORIES << ["Queries", "app/queries"]
  ::STATS_DIRECTORIES << ["Scripts", "app/scripts"]
  ::STATS_DIRECTORIES << ["Services", "app/services"]
  ::STATS_DIRECTORIES << ["Validators", "app/validators"]

  # For test folders not defined in CodeStatistics::TEST_TYPES (ie: spec/)
  #::STATS_DIRECTORIES << ["Services specs", "specs/services"]
  #CodeStatistics::TEST_TYPES << "Services specs"
end
