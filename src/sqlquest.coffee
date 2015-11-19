require 'coffee-script/register'
path = require 'path'
fs = require 'fs'
colors = require 'colors'
read = require 'read'
nomnom = require 'nomnom'
_ = require 'lodash'

{findSql, findQuest} = require './hunter'
readConfig = require './config'

# Private: Split a list the first instance of an element
#
# * `target` Element of the list you want to split at.
# * `items` {Array} to split.
#
# Returns the original {Array} otherwise returns an {Array} of two {Array}s
# where the first contains everything prior to the `target` element and the
# second contains everything after. The `target` element isn't includes
splitAt = (target, items) ->
  index = items.indexOf target
  if index > -1
    beginning = items.slice(0, index)
    end = items.slice(index + 1)
    [beginning, end]
  else
    [items, []]

# Separate all args after `--` so we can pass those on to the quest.
[args, questOpts] = splitAt '--', process.argv.slice(2)

options =
  user:
    abbr: 'u'
    help: "JDBC username"
  pass:
    abbr: 'P'
    help: "JDBC password"
    default: process.env.PGPASSWORD
  url:
    abbr: 'U'
    help: "JDBC URL to connect to (jdbc:postgresql://host/db)"
  quests:
    abbr: 'q'
    default: 'quests'
    help: "Where to find quests"
  splitter:
    abbr: 's'
    help: "Splitter API URL to use [http://sqlformat.org/api/v1/split]"
  time:
    abbr: 't'
    flag: true
    default: true
    help: "Print the runtime of each query."
  quest:
    position: 0
    help: "Which quest to embark on!"
  output:
    abbr: 'o'
    help: "Options are: table or json"
    default: "table"
  '':
    help: "Everything after this is passed to the quest."

config = readConfig()
opts = nomnom()
  .script 'sqlquest'
  .options options
  .parse(args)
config = _.merge opts, config

printHeader = (text) ->
  console.log '########################################################'.gray
  console.log text.gray.bold
  console.log '########################################################'.gray

quests = path.resolve(config.quests)

[questPath, Quest] = findQuest(quests, config.quest)

printHeader "Beginning the #{config.quest} quest!"

# Instantiate quest, which runs `adventure`.
new Quest(config, path.dirname(questPath), questOpts)
