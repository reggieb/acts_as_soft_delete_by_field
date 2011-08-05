# Gem::Specification for ActsAsSoftDeleteByField

Gem::Specification.new do |s|
  s.name = "acts_as_soft_delete_by_field"
  s.version = '1.0.2'
  s.authors = ['Rob Nichols']
  s.date = %q{2011-08-5}
  s.summary = "Provides soft deletion for ActiveRecord models"
  s.description = "Acts as Soft Delete by Field: #{s.summary} using a field to flag the datetime of deletion"
  s.email = 'rob@nicholshayes.co.uk'
  s.files = [
    'README',
    'Rakefile',
    'lib/acts_as_soft_delete_by_field_assertions.rb',
    'lib/acts_as_soft_delete_by_field.rb',
    'lib/soft_delete_by_field.rb',
  ]
  s.homepage = %q{https://github.com/reggieb/acts_as_soft_delete_by_field}
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'activerecord', '>= 3.0.0'
end