require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/johnny_cache'

class FakeController < ActionController::Base; end

class JohnnyCacheTest < Test::Unit::TestCase
  include ActionView::Helpers::CacheHelper

  def setup
    @controller = FakeController.new 
  end
  
  def test_timestamp_added_to_fragment
    _erbout = ''
    output = cache("test_timestamp_added_to_fragment", :time_to_live => 5.minutes) do
      _erbout.concat "some stuff"
    end
    assert_match( /<!-- EXPIRE CACHE: \d* -->\nsome stuff/, output )
  end
  
  def test_timestamp_remains_same
    _erbout = ''
    output = cache("test_timestamp_remains_same", :time_to_live => 5.minutes) do
      _erbout.concat "some stuff"
    end
    timestamp = output.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )[2]
    # one second is all it takes to ensure a different timestamp
    sleep(1)
    _erbout = ''
    output = cache("test_timestamp_remains_same", :time_to_live => 5.minutes) do
      _erbout.concat "some stuff"
    end
    second_timestamp = output.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )[2]
    assert_equal timestamp, second_timestamp
  end
  
  def test_timestamp_within_1_second
    expire_time = 5.minutes.from_now.to_i
    _erbout = ''
    output = cache("test_timestamp_within_1_second", :time_to_live => 5.minutes) do
      _erbout.concat "some stuff"
    end
    m = output.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )
    assert expire_time <= m[2].to_i
    assert expire_time+1 >= m[2].to_i
  end
  
  def test_timestamp_has_expired
    _erbout = ''
    output = cache("test_timestamp_has_expired", :time_to_live => 1.second) do
      _erbout.concat "some stuff"
    end
    timestamp = output.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )[2]
    # one second is all it takes to ensure a different timestamp
    sleep(1)
    _erbout = ''
    output = cache("test_timestamp_remains_same", :time_to_live => 1.second) do
      _erbout.concat "some stuff"
    end
    second_timestamp = output.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )[2]
    assert_not_equal timestamp, second_timestamp
  end
  
  def test_can_still_cache_without_ttl
    _erbout = ''
    output = cache("test_can_still_cache_without_ttl") do
      _erbout.concat "some stuff"
    end
    assert_equal "some stuff", output
  end
end
