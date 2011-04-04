require 'test_helper'

class WhatTest < ActiveSupport::TestCase
  test "cleaning removes all non-alphanum characters at the beginning and end of the what" do
    assert_equal 'word', What.for('&^word.*').name
    assert_equal 'jekyll & hyde', What.for('***jekyll & hyde***').name
  end
end