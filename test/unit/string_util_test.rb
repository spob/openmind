require File.dirname(__FILE__) + '/../test_helper'

class StringUtilTest < Test::Unit::TestCase  
  def test_strip_html
    assert_equal "this is a testTest and Test", 
      StringUtils.strip_html("<html><head>this is a test</head><body><p><b>Test and Test</b></p></body></html>")
  end 
  
  #  def test_strip_html_tags
  #    assert_equal "this <b>is</b> a test and that's the end",
  #      StringUtils.strip_html_tags("this <b>is</b> a test<script>alert('hello')</script> and that's the end")
  #    assert_equal "this is a test<image >blah</image>",
  #      StringUtils.strip_html_tags("this is a test<image :onmouseover='do something'>blah</image>")
  #  end
end