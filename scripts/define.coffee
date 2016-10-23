# Description:
#   Home Assistant Chat Assistant - Definitions
#
# Dependencies:
#   fuzzy
#
# Configuration:
#   None
#
# Commands:
#   /define || /def || /definition [@user] <query> - Displays all definitions that match <query> to the <@user>.
#
# Authors:
#   Justin Weberg - @justweb1
#   Dale Higgs - @dale3h

fuzzy = require 'fuzzy'

module.exports = (robot) ->

  dictionary = [
    {
      name: 'homeassistant_start'
      keywords: ''
      strict: []
      output: """
        Event `homeassistant_start` is fired when all components from the configuration have been initialized. This is the event that will start the timer firing off `time_changed` events.
      """
    }
    {
      name: 'homeassistant_stop'
      keywords: ''
      strict: []
      output: """
        Event `homeassistant_stop` is fired when Home Assistant is shutting down. It should be used to close any open connection or release any resources.
      """
    }
    {
      name: 'state_changed'
      keywords: ''
      strict: []
      output: """
        Event `state_changed` is fired when a state changes. Both `old_state` and `new_state` are state objects. [Documentation about state objects](/topics/state_object/).
        > `entity_id` Entity ID of the changed entity. Example: `light.kitchen`
          `old_state` The previous state of the entity before it changed. This field is omitted if the entity is new.
          `new_state` The new state of the entity. This field is omitted if the entity is removed from the state machine.
      """
    }
    {
      name: 'time_changed'
      keywords: ''
      strict: []
      output: """
        Event `time_changed` is fired every second by the timer and contains the current time.
        > `now` A [datetime object](https://docs.python.org/3.4/library/datetime.html#datetime.datetime) containing the current time in UTC.
      """
    }
    {
      name: 'service_registered'
      keywords: ''
      strict: []
      output: """
        Event `service_registered` is fired when a new service has been registered within Home Assistant.
        > `domain` Domain of the service. Example: `light`
          `service` The service to call. Example: `turn_on`
      """
    }
    {
      name: 'call_service'
      keywords: ''
      strict: []
      output: """
        Event `call_service` is fired to call a service.
        > `domain` Domain of the service. Example: `light`
          `service` The service to call. Example: `turn_on`
          `service_data` Dictionary with the service call parameters. Example: `{ 'brightness': 120 }`
          `service_call_id` String with a unique call id. Example: `23123-4`
      """
    }
    {
      name: 'service_executed'
      keywords: ''
      strict: []
      output: """
        Event `service_executed` is fired by the service handler to indicate the service is done.
        > `service_call_id` String with the unique call id of the service call that was executed. Example: `23123-4`
      """
    }
    {
      name: 'platform_discovered'
      keywords: ''
      strict: []
      output: """
        Event `platform_discovered` is fired when a new platform has been discovered by the discovery component.
        > `service` The service that is discovered. Example: `zwave`
          `discovered` Information that is discovered. Can be a dict, tuple etc. Example: `(192.168.1.10, 8889)`
      """
    }
    {
      name: 'component_loaded'
      keywords: ''
      strict: []
      output: """
        Event `component_loaded` is fired when a new component has been loaded and initialized.
        > `component` Domain of the component that has just been initialized. Example: `light`
      """
    }
  ]

  robot.hear /^\/(def|define|definition)(?:\s+(@[a-z0-9_-]+))?(?:\s+(.*))?$/i, (res) ->
    master  = "@#{res.message.user.login}"
    command = res.match[1]
    user    = res.match[2] ? master
    query   = res.match[3]

    unless query
      res.reply "#{master} Please use this format: `/#{command} <@user> <query>`"
      return

    results = (d for d in dictionary when d.name is query.toLowerCase())

    unless results.length
      results = (d for d in dictionary when (d.strict.some (word) -> ~query.toLowerCase().indexOf word.toLowerCase()))
      console.log 'strict match:', results

    unless results.length
      filterOptions =
        extract: (r) -> [r.name, r.strict, r.keywords, r.output].join '\n'
      results = fuzzy.filter query, dictionary, filterOptions

    unless results.length
      res.reply "#{master} I couldn't find any definitions matching \"#{query}.\""
      return

    match = results[0]
    output = match.original?.output ? match.output

    res.send "#{user} #{output}"
