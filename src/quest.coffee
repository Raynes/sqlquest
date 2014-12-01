Sync = require 'sync'
fs = require 'fs'
path = require 'path'
pg = require 'pg'
colors = require 'colors'
Mustache = require 'mustache'

module.exports =
class Quest
  constructor: (host, db, user, pass, extraArgs) ->
    @questDir = path.dirname module.parent.filename
    connString = "postgres://#{user}:#{pass}@#{host}/#{db}"
    @args = extraArgs
    @client = new pg.Client(connString)
    @client.connect (err) =>
      if err
        console.error "Couldn't connect!".red.bold
        console.error err.message.red
      else
        Sync (=> @adventure()), (err, result) =>
          @client.end()
          if err
            console.error "An error occurred!".red.bold
            console.error err.message.red

  sql: (queries, view={}, cb) ->
    if typeof(queries) != 'string'
      sqlPath = path.join @questDir, 'sql', queries.file
      console.log ">>".blue.bold, "#{sqlPath}".blue.bold
      queries = fs.readFileSync(sqlPath, encoding: 'utf-8')
    queries = Mustache.render queries, view
      .split ';'
      .map (s) -> s.trim()
      .filter (s) -> s
    result = null
    for _, query of queries
      console.log()
      console.log "#{query};".green
      console.log()
      if cb?
        @client.query(query, cb)
      else
        result = @client.query.sync(@client, query)
    result
