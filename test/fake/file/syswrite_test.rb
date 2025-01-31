# frozen_string_literal: true

require_relative '../../test_helper'

# File SysWrite test class
class FileSysWriteTest < Minitest::Test
  def setup
    FakeFS.activate!
    FakeFS::FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  def test_returns_one_byte_when_written
    f = File.open 'foo', 'w'
    result = f.syswrite 'a'
    assert_equal 1, result
  end

  def test_returns_two_bytes_when_two_written
    f = File.open 'foo', 'w'
    result = f.syswrite 'ab'
    assert_equal 2, result
  end

  def test_syswrite_writes_file
    f = File.open 'foo', 'w'
    f.syswrite 'abcdef'
    f.close

    assert_equal 'abcdef', File.read('foo')
  end

  def test_writes_to_the_actual_position_when_called_after_buffered_io_read
    File.open('foo', 'w') do |file|
      file.syswrite('012345678901234567890123456789')
    end

    file = File.open('foo', 'r+')
    file.read(5)
    file.syswrite('abcde')

    File.open('foo') do |f|
      assert_equal '01234abcde', f.sysread(10)
    end
  end

  def test_writes_all_of_the_strings_bytes_but_does_not_buffer_them
    File.open('foo', 'w') do |file|
      file.syswrite('012345678901234567890123456789')
    end

    file = File.open('foo', 'r+')
    file.syswrite('abcde')

    File.open('foo') do |f|
      assert_equal 'abcde56789', f.sysread(10)
      f.seek(0)
      f.fsync
      assert_equal 'abcde56789', f.sysread(10)
    end
  end
end
