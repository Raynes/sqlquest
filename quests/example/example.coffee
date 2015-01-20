# And here's a more detailed example.
Quest = require '../../src/quest'

module.exports =
class ExampleQuest extends Quest
  makePeople: (peoples) ->
    peoples = peoples
      .map ({name, age}) -> "('#{name}', #{age})"
      .join ',\n'

    # Render a complex sql template with mustache. This essentially generates
    # a bulk insert out of the people passed in.
    @sql file: 'people.sql', {people: peoples}

  getPeopleOlderThan: (minAge) ->
    try
      result = @sql """SELECT * FROM people
                       WHERE age > {{age}}""",
                    age: minAge

    catch e
      console.error "Failed to get people older than #{minAge}!"
      console.error e.message
      return []

    # Return an array of all the name columns in the resulting rows.
    result.rows.map ({name}) -> name

  adventure: ->
    @makePeople [{name: 'Anthony', age: 20},
                 {name: 'Daniel', age: 21},
                 {name: 'Avram', age: 29}]

    # We have node-colors so you can use its String.prototype monkeypatches.
    console.log "People older than 20:".underline
    for i, person of @getPeopleOlderThan 20
      console.log "* #{person}".underline
    console.log()

    # Retry with silent failure. Prints error and returns non-zero exit code
    # at the end of the quest.
    @retry times: 2, wait: 0, silent: true, =>
      @sql "nope;"

    # Retry a transaction until it succeeds or fails 3 times. Anything after
    # this will not execute because this error will stop things (because
    # the silent option isn't being used).
    @retry times: 3, wait: 5000, =>
      @transaction =>
        @sql "create temp table foo (x int);"
        @sql "insert into table foo VALUES ('on no');"

        # this will never happen
        @sql "create temp table bar as (select * from foo)"

    @sql "never happens;"
