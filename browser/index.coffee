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
      unless sel.isCollapsed
        return range.getBoundingClientRect()
      range = range.cloneRange()
    else if sel['container'] # then it's a single point
      range = rangy.createRange()
      range.setStart sel['container'], sel['offset']
    else # it's a range
      range = sel.cloneRange()
      
    if (node = range.startContainer).nodeType is TEXT_NODE
      startOffset = range.startOffset
      loop
        return rect if (rect = range.getBoundingClientRect()).height
        break if --startOffset < 0
        range.setStart node, startOffset
    else if containedNode = node.childNodes?[range.startOffset]
      range.selectNode containedNode
      return rect if (rect = range.getBoundingClientRect()).height

    loop
      range.selectNode node
      return rect if (rect = range.getBoundingClientRect()).height

      while alt = node.nextSibling
        range.selectNode alt
        return rect if (rect = range.getBoundingClientRect()).height

      while alt = node.previousSibling
        range.selectNode alt
        return rect if (rect = range.getBoundingClientRect()).height

      break unless node = node.parentNode

    0

    # else if parentNode = node.parentNode
    #   range = rangy.createRange()
    #   range.selectNode parentNode
    #   rect = range.getBoundingClientRect()
    #   return {
    #     top: rect.top + rect.height
    #     left: rect.left
    #   }
    # 0


  $['fn']['extend']
    'selectNode': ->
      return unless sel = rangy.getSelection()
      sel.removeAllRanges()
      range = rangy.createRange()
      range.selectNode @[0]
      sel.addRange range
      this

