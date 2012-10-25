# Add a declarative step here for populating the DB with movies.
require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end


Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  end
  assert movies_table.hashes.count == Movie.count
  #flunk "Unimplemented"
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  click_button(button)
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"$/ do |e1, e2|
  titles = page.all("table#movies tbody tr td[1]").map {|t| t.text}
  assert titles.index(e1) < titles.index(e2)
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  #rating_list.split(%r{[^']\w+[^']}).each do |rating|
   rating_list.split(',').each do |rating|
     rating = rating.strip
 #    rating.sub!(%r{\W+},"")
     if uncheck=="un"
       step %Q{I uncheck "ratings_#{rating}"}
       step %Q{the "ratings_#{rating}" checkbox should not be checked}
     else
      step %Q{I check "ratings_#{rating}"}
      step %Q{the "ratings_#{rating}" checkbox should be checked}
     end
  end
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
end

When /^(?:|I )check "([^"]*)"$/ do |field|
  check(field)
end

When /^(?:|I )uncheck "([^"]*)"$/ do |field|
  uncheck(field)
end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should not see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end


Then /^(?:|I )should see all of the movies$/ do 
  assert page.all("table#movies tbody tr").count == Movie.all.count
end

Then /^(?:|I )should see no movies$/ do 
  assert page.all("table#movies tbody tr").count == 0
end

Then /^the "([^"]*)" checkbox(?: within (.*))? should be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
end


