# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create! movie
  end

  # verify that movies where saved in database
  actual = true
  expected = true

  movies_table.hashes.each do |movie|
    if (Movie.find_by_title( movie[:title] ) == nil)
      actual = false
      break
    end
  end

  message = "The following movies '#{movies_table}' exist"
  assert( actual == expected, message )
end


# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  #page.body =~ /(#{e1}|#{e2})/
  debugger
  #assert( $1 == e1 and $2 == e2, "I should see #{e1} before #{e2}" )
end


# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: "(.*)"/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb

  rating_list.split(', ').each do |r|
    if uncheck
        step %{I uncheck "#{r}"}
    else
        step %{I check "#{r}"}
    end
  end
end


# Scenario 1

When /I check the '(.*)' and '(.*)' checkboxes/ do |r1, r2|
  @r1 = r1
  @r2 = r2
  r1 = "ratings_" + r1
  r2 = "ratings_" + r2
  rating_list = r1 + ", " + r2
  step %{I check the following ratings: "#{rating_list}"}
end

And /I uncheck all other checkboxes/ do
  uncheckeds = Movie.all_ratings - [@r1, @r2]
  uncheckeds = uncheckeds.map { |r| r = "ratings_" + r }
  uncheckeds = uncheckeds.join(', ')
  step %{I uncheck the following ratings: "#{uncheckeds}"}
end

And /I submit the search form on the homepage/ do
  step %{I press "Refresh"}
end

Then /ensure that PG and R movies are visible/ do
  movie_list = Movie.where("rating = '#{@r1}' or rating = '#{@r2}'")
  movie_list.each { |m|  step %{I should see "#{m.title}"} }
end

And /ensure that other movies are not visible/ do
  movie_list = Movie.where("rating <> '#{@r1}' and rating <> '#{@r2}'")
  movie_list.each { |m|  step %{I should not see "#{m.title}"} }
end


# Scenario 2

When /no ratings selected/ do
  uncheckeds = Movie.all_ratings # get all possible movie ratings and uncheck them
  uncheckeds = uncheckeds.map { |r| r = "ratings_" + r }
  uncheckeds = uncheckeds.join(', ')
  step %{I uncheck the following ratings: "#{uncheckeds}"}
  step %{I submit the search form on the homepage}
end

Then /I should not see movies/ do
  query = Movie.all_ratings
  query = query.map { |r| r = "rating <> '#{r}'" }
  query = query.join(' and ')
  movie_list = Movie.where( query )
  assert( movie_list.length == 0 )
  movie_list.each { |m|  step %{I should not see "#{m.title}"} }
end

# Scenario 3

When /all ratings selected/ do
  checkeds = Movie.all_ratings
  checkeds = checkeds.map { |r| r = "ratings_" + r }
  checkeds = checkeds.join(', ')
  step %{I check the following ratings: "#{checkeds}"}
  step %{I submit the search form on the homepage}
end

Then /I should see all of the movies/ do
  query = Movie.all_ratings
  query = query.map { |r| r = "rating = '#{r}'" }
  query = query.join(' or ')
  movie_list = Movie.where( query )
  assert( movie_list.length == Movie.where(1).length )
  movie_list.each { |m|  step %{I should see "#{m.title}"} }
end
