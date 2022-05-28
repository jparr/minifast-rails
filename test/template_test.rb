require "minitest/autorun"

class TemplateTest < Minitest::Test
  def setup
    system("[ -d test_app ] && rm -rf test_app")
  end

  def teardown
    setup
  end

  def test_generator_succeeds
    output, error = capture_subprocess_io do
      system("rails new test_app -m template.rb")
    end
    assert_includes output, "App successfully created!"
    # puts error
  end
end
