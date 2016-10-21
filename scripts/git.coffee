# Description:
#   Home Assistant Chat Assistant
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   /git <@user-optional> <query> - Displays all topics that match <query> to the <@user>.
#
# Authors:
#   Justin Weberg - @justweb1
#   Dale Higgs - @dale3h

fuzzy = require 'fuzzy'

module.exports = (robot) ->

  topics = [
    {
      name: 'oh shit'
      output: """
        [OhShitGit.com](http://ohshitgit.com)
      """
    }
    {
      name: 'xkcd 1597 git'
      output: """
        [xkcd #1597 - GIT](https://xkcd.com/1597/)
      """
    }
    {
      name: 'xkcd 1296 git commit'
      output: """
        [xkcd #1296 - GIT Commit](https://xkcd.com/1296/)
      """
    }
  ]

  robot.hear /^\/git?(?:\s+(@[a-z0-9_-]+))?(?:\s+(.*))?$/i, (res) ->
    master = "@#{res.message.user.login}"
    user  = res.match[1] ? master
    query = res.match[2]

    unless query
      res.reply "#{master} Please use this format: `/git <user> <query>`"
      return

    results = (t for t in topics when t.name is query.toLowerCase())

    unless results.length
      filterOptions =
        extract: (r) -> [r.name, r.output].join '\n'

      results = fuzzy.filter query, topics, filterOptions

    unless results.length
      res.reply "#{master} I couldn't find any Git topics matching \"#{query}.\""
      return

    match = results[0]
    output = match.original?.output ? match.output

    res.send "#{user} #{output}"
