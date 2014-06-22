require 'egnyte'
require 'webmock/rspec'

RSpec.configure do |c|
  c.filter_run_excluding :skip => true
  # Use color in STDOUT
  c.color = true

  # Use color not only in STDOUT but also in pagers and files
  c.tty = true

  # Use the specified formatter
  #c.formatter = :progress # :documentation, :html, :textmate
end
