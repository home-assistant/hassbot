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
#   /event <@user> <query> - Displays all events that match <query> to the <@user>.
#
# Author:
#   Justin Weberg - @justweb1
#   Dale Higgs - @dale3h

fuzzy = require 'fuzzy'

module.exports = (robot) ->

  events = [
    {
      name: 'homeassistant_start'
      output: """
        Event `homeassistant_start` is fired when all components from the configuration have been initialized. This is the event that will start the timer firing off `time_changed` events.
      """
    }
    {
      name: 'homeassistant_stop'
      output: """
        Event `homeassistant_stop` is fired when Home Assistant is shutting down. It should be used to close any open connection or release any resources.
      """
    }
    {
      name: 'state_changed'
      output: """
        Event `state_changed` is fired when a state changes. Both `old_state` and `new_state` are state objects. [Documentation about state objects](/topics/state_object/).
        > `entity_id` Entity ID of the changed entity. Example: `light.kitchen`
          `old_state` The previous state of the entity before it changed. This field is omitted if the entity is new.
          `new_state` The new state of the entity. This field is omitted if the entity is removed from the state machine.
      """
    }
    {
      name: 'time_changed'
      output: """
        Event `time_changed` is fired every second by the timer and contains the current time.
        > `now` A [datetime object](https://docs.python.org/3.4/library/datetime.html#datetime.datetime) containing the current time in UTC.
      """
    }
    {
      name: 'service_registered'
      output: """
        Event `service_registered` is fired when a new service has been registered within Home Assistant.
        > `domain` Domain of the service. Example: `light`
          `service` The service to call. Example: `turn_on`
      """
    }
    {
      name: 'call_service'
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
      output: """
        Event `service_executed` is fired by the service handler to indicate the service is done.
        > `service_call_id` String with the unique call id of the service call that was executed. Example: `23123-4`
      """
    }
    {
      name: 'platform_discovered'
      output: """
        Event `platform_discovered` is fired when a new platform has been discovered by the discovery component.
        > `service` The service that is discovered. Example: `zwave`
          `discovered` Information that is discovered. Can be a dict, tuple etc. Example: `(192.168.1.10, 8889)`
      """
    }
    {
      name: 'component_loaded'
      output: """
        Event `component_loaded` is fired when a new component has been loaded and initialized.
        > `component` Domain of the component that has just been initialized. Example: `light`
      """
    }
  ]

  robot.hear /^\/events?(?:\s+(@[a-z0-9_-]+))?(?:\s+(.*))?$/i, (res) ->
    master = "@#{res.message.user.login}"
    user  = res.match[1] ? master
    query = res.match[2]

    unless query
      res.reply "#{master} Please use this format: `/event <@user> <query>`"
      return

    results = (e for e in events when e.name is query.toLowerCase())

    unless results.length
      filterOptions =
        extract: (r) -> [r.name, r.output].join '\n'

      results = fuzzy.filter query, events, filterOptions

    unless results.length
      res.reply "#{master} I couldn't find any events matching \"#{query}.\""
      return

    match = results[0]
    output = match.original?.output ? match.output

    res.send "#{user} #{output}"
