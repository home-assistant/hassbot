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
#   /rule(s) [@user] <query> - Displays all rules that match <query> to the <@user>.
#
# Authors:
#   Justin Weberg - @justweb1
#   Dale Higgs - @dale3h

fuzzy = require 'fuzzy'

module.exports = (robot) ->

  rules = [
    {
      keywords: 'request features enhance new idea contribute'
      output: 'All feature requests and enhancements need to be submitted in the [Community Forum](https://home-assistant.io/help).'
    }
    {
      keywords: 'devchat chatroom dev chat room'
      output: 'This chat room is for developers only, please ask your question in the main [Home Assistant chat](https://gitter.im/home-assistant/home-assistant).'
    }
    {
      keywords: 'hastebin haste bin'
      output: 'Please use [hastebin](http://hastebin.com/) when posting large chunks of code or log output.'
    }
  ]

  robot.hear /^\/rules?(?:\s+(@[a-z0-9_-]+))?(?:\s+(.*))?$/i, (res) ->
    master = "@#{res.message.user.login}"
    user  = res.match[1]
    query = res.match[2]

    # Debug - Remove before release
    user ?= master if master in ['@dale3h', '@justweb1']

    unless user and query
      res.reply "#{master} Please use this format: `/rules <@user> <query>`"
      return

    filterOptions =
      extract: (r) -> if r.keywords? then [r.keywords, r.output].join '\n' else r.output ? r

    results = fuzzy.filter query, rules, filterOptions
    unless results.length
      res.reply "#{master} I couldn't find any rules matching \"#{query}.\""
      return

    matches = (['* ' if results.length > 1] + (r.original.output ? r.original) for r in results)
    res.send "#{user} #{matches.join '\n'}"
