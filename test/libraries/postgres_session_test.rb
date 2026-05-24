require_relative '../test_helper'
require 'shellwords'

# Stub the InSpec resource base so the resource file loads without the full
# InSpec runtime; these are unit tests of the resource's pure logic.
module Inspec
  def self.resource(_version)
    Class.new do
      def self.name(*); end
      def self.supports(*); end
      def self.desc(*); end
      def self.example(*); end
    end
  end
end

require_relative '../../libraries/postgres_session'

class LinesTest < Minitest::Test
  def test_splits_and_strips_each_line
    lines = Lines.new(" one \ntwo\n  three  ", 'desc')
    assert_equal %w[one two three], lines.lines
  end

  def test_output_is_raw_input
    raw = " one \ntwo\n"
    assert_equal raw, Lines.new(raw, 'desc').output
  end

  def test_to_s_returns_description
    assert_equal 'PostgreSQL query: x', Lines.new('out', 'PostgreSQL query: x').to_s
  end
end

# Stubs the resource's `inspec` accessor so command construction can be
# exercised without a live InSpec runner or database.
class FakeInspec
  def initialize(windows:)
    @windows = windows
  end

  def platform
    self
  end

  def in_family?(_family)
    @windows
  end
end

class PostgresSessionCmdTest < Minitest::Test
  def session(windows:, user: 'admin', pass: 'p@ss w0rd!', host: 'db.example', port: 5432)
    sess = PostgresSession.new(user, pass, host, port)
    sess.define_singleton_method(:inspec) { @fake_inspec }
    sess.instance_variable_set(:@fake_inspec, FakeInspec.new(windows: windows))
    sess
  end

  def test_unix_command_escapes_password_and_query
    cmd = session(windows: false).send(:create_psql_cmd, 'SELECT 1;', ['stig'])
    escaped_pass = Shellwords.escape('p@ss w0rd!')
    assert_includes cmd, "postgresql://admin:#{escaped_pass}@db.example:5432/stig"
    assert_includes cmd, "-A -t -w -c #{Shellwords.escape('SELECT 1;')}"
  end

  def test_windows_command_interpolates_raw_and_quotes_query
    cmd = session(windows: true).send(:create_psql_cmd, 'SELECT 1;', ['stig'])
    assert_includes cmd, 'postgresql://admin:p@ss w0rd!@db.example:5432/stig'
    assert_includes cmd, '-c "SELECT 1;"'
  end

  def test_defaults_applied_when_args_nil
    sess = PostgresSession.new(nil, 'pw', nil, nil)
    assert_equal 'postgres', sess.instance_variable_get(:@user)
    assert_equal 'localhost', sess.instance_variable_get(:@host)
    assert_equal '5432', sess.instance_variable_get(:@port)
  end
end
