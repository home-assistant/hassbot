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
#   /component || /comp [@user] <query> - Displays all components that match <query> to the <@user>.
#
# Authors:
#   Justin Weberg - @justweb1
#   Dale Higgs - @dale3h

fuzzy   = require 'fuzzy'
request = require 'request'

module.exports = (robot) ->

  String::format = (args...) ->
    @replace /{(\d+)}/g, (match, number) ->
      if number < args.length then args[number] else match

  options =
    uri: 'https://api.github.com/repos/home-assistant/home-assistant.github.io/contents/source/_components?ref=current'
    headers:
      'user-agent': 'hassbot'
    json: true

  # Component class
  class Component
    constructor: (@json) ->
      @filename = @json.name
      @slug = @filename.replace /\.markdown$/, ''
      @url = "https://home-assistant.io/components/#{@slug}/"
      @domain = @slug.split '.', 1
      @platform = (@slug.split '.')[1..].join '.'
      @download_url = @json.download_url
      @settings = {}
      @name = ''
      @content = ''

      request.get {uri: @download_url, headers: options.headers, json: true}, (err, r, content) =>
        if err
          robot.logger.error err.toString()
          return

        if matches = content.match /^---((.|[\r\n])*?)^---/m
          matches[1] = matches[1].trim().replace /[\r\n]+([^"\n]*")$/gm, '$1'
          pairs = ((line.replace /:\s*/, ':').split(':') for line in (matches[1].replace /\r/g, '').split '\n')

          @settings[value[0]] = value[1].replace /^"(.*)"$/, '$1' for value in pairs
          @name = @settings.title
          @content = (content.replace matches[0], '').trim()

      @keywords = () =>
        @name + '\n' + @slug.replace /[^a-z]/g, ' '

  # Load components asyncronously
  components = []
  request.get options, (err, r, body) -> components.push new Component(c) for c in body

  robot.hear /^\/comp(?:onents?)?(?:\s+(@[a-z0-9_-]+))?(?:\s+(.*))?$/i, (res) ->
    master = "@#{res.message.user.login}"
    user   = res.match[1] ? master
    query  = res.match[2]

    unless query
      res.reply "#{master} Please use this format: `/component <@user> <query>`"
      return

    filterOptions =
      extract: (c) -> c.keywords()

    results = fuzzy.filter query, components, filterOptions
    unless results.length
      res.reply "#{master} I couldn't find any components matching \"#{query}.\""
      return

    matches = (['* ' if results.length > 1] + "[#{c.original.name}](#{c.original.url})" for c in results[..9])

    if matches.length is 1
      res.send "#{user} Check out the #{matches.join '\n'} component."
    else
      res.send "#{user} Check out these components:\n\n#{matches.join '\n'}"
