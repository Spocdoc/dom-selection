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
    sel = sel?.sel or rangy.getSelection()

    if (sel = rangy.getSelection()) and sel.rangeCount
      range = sel.getRangeAt(0)
      if sel.isCollapsed
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
              range.setEnd(node, offset+1)
              return rect if (rect = range.getBoundingClientRect()).height isnt 0
              range.selectNode node
              rect = range.getBoundingClientRect()
            return { top: rect.top, left: rect.right } if rect.height
        else if containedNode = node.childNodes?[range.startOffset]
          range = rangy.createRange()
          range.selectNode containedNode
          return range.getBoundingClientRect()
        else if parentNode = node.parentNode
          range = rangy.createRange()
          range.selectNode parentNode
          rect = range.getBoundingClientRect()
          return {
            top: rect.top + rect.height
            left: rect.left
          }
      else
        return range.getBoundingClientRect()

    0


  $['fn']['extend']
    'selectNode': ->
      return unless sel = rangy.getSelection()
      sel.removeAllRanges()
      range = rangy.createRange()
      range.selectNode @[0]
      sel.addRange range
      this
