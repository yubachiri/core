require 'test_helper'

class CompassTest < Minitest::Test
  def test_create_project
    command = 'rm -rf tmp/new-compass-projects; bundle exec compass create tmp/new-compass-projects -r bootstrap-sass --using bootstrap --trace --force'
    success = silence_stdout_if(!ENV['VERBOSE']) { system(command) }
    assert success, 'Compass projects creation failed!'
  end
end
