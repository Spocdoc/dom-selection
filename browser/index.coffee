$ = require 'dom-fork'
rangy = require './rangy'

TEXT_NODE = 3

if typeof rangy.getSelection is 'function'

  # or can pass two points or a single range
  $['selection'] = (start, end) ->
    return unless sel = rangy.getSelection()

    unless start?
      if range = sel and sel.rangeCount and sel.getRangeAt(0)
        return {
          'start':
            'container': range.startContainer
            'offset': range.startOffset
          'end':
            'container': range.endContainer
            'offset': range.endOffset
          sel: sel
        }
    else
      if start['start']
        end = start['end']
        start = start['start']

      try
        end ||= start
        range = rangy.createRange()
        range.setStart start['container'], start['offset']
        range.setEnd end['container'], end['offset']
        sel.removeAllRanges()
        sel.addRange range
      catch _error
      return range

  $['selection']['equal'] = (lhs, rhs) ->
    lhs['start']['container'] is rhs['start']['container'] and
      lhs['start']['offset'] is rhs['start']['offset'] and
      lhs['end']['container'] is rhs['end']['container'] and
      lhs['end']['offset'] is rhs['end']['offset']

  $['selection']['clear'] = ->
    try
      rangy.getSelection()?.removeAllRanges()
    catch _error
    return

  $['selection']['delete'] = ->
    rangy.getSelection()?.getRangeAt(0)?.deleteContents()
    return

  $['selection']['isCollapsed'] = ->
    rangy.getSelection()?.isCollapsed

  # position relative to the viewport
  # returns object with top and left properties
  $['selection']['coords'] = (sel) ->
    if !sel? or sel.sel
      sel = (sel && sel.sel) || rangy.getSelection()
      range = sel.getRangeAt(0)
      return range.getBoundingClientRect() unless sel.isCollapsed
    else if sel['container'] # then it's a single point
      range = rangy.createRange()
      range.setStart sel['container'], sel['offset']
    else # it's a range
      range = sel
      
    if (node = range.startContainer).nodeType is TEXT_NODE
      if (offset = range.startOffset) is 0
        range = rangy.createRange()
        range.selectNode node
        return range.getBoundingClientRect()
      else
        range = range.cloneRange()
        range.setStart(node, offset-1)
        rect = range.getBoundingClientRect()
        if rect.height is 0
          range.setStart(node, offset)
          try
            range.setEnd(node, offset+1)
          catch _error
            try
              range.setEnd(node, offset)
              range.setStart(node, offset-1)
            catch _error
              range.selectNode node
              return range.getBoundingClientRect()
          return rect if (rect = range.getBoundingClientRect()).height isnt 0
          range.selectNode node
          rect = range.getBoundingClientRect()
        return { top: rect.top, left: rect.right } if rect.height
    else if containedNode = node.childNodes?[range.startOffset]
      range = rangy.createRange()
      range.selectNode containedNode
      rect = range.getBoundingClientRect()
      if rect.height is 0 # then this child has 0 width...
        range.selectNode node
        rect = range.getBoundingClientRect()
        return rect if rect.height
    else
      range = rangy.createRange()
      range.selectNode node
      return range.getBoundingClientRect()
    # else if parentNode = node.parentNode
    #   range = rangy.createRange()
    #   range.selectNode parentNode
    #   rect = range.getBoundingClientRect()
    #   return {
    #     top: rect.top + rect.height
    #     left: rect.left
    #   }

    0


  $['fn']['extend']
    'selectNode': ->
      return unless sel = rangy.getSelection()
      sel.removeAllRanges()
      range = rangy.createRange()
      range.selectNode @[0]
      sel.addRange range
      this

