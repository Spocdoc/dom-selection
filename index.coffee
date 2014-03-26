$ = require 'dom-fork'

$.selection = (start, end) ->

$.selection.clear = ->
$.selection.isCollapsed = ->
$.selection.delete = ->
$.selection.offsetTop = -> 0
$.selection.equal = (lhs, rhs) ->
    lhs['start']['container'] is rhs['start']['container'] and
      lhs['start']['offset'] is rhs['start']['offset'] and
      lhs['end']['container'] is rhs['end']['container'] and
      lhs['end']['offset'] is rhs['end']['offset']
