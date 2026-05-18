local UILayerEvent = {}
local E = UILayerEvent

function UILayerEvent.MakeAutoIndex()
  local index = 0
  return function()
    index = index + 1
    return index
  end
end

local autoIndex = UILayerEvent.MakeAutoIndex()
E.BG_LAYER_OPENWINDOW = autoIndex()
E.BG_LAYER_CLOSEWINDOW = autoIndex()
E.DEBUG_LAYER_OPENWINDOW = autoIndex()
E.DEBUG_LAYER_CLOSEWINDOW = autoIndex()
E.FULLSCREEN_LAYER_OPENWINDOW = autoIndex()
E.FULLSCREEN_LAYER_CLOSEWINDOW = autoIndex()
E.TOP_LAYER_OPENWINDOW = autoIndex()
E.TOP_LAYER_CLOSEWINDOW = autoIndex()
E.MAIN_LAYER_OPENWINDOW = autoIndex()
E.MAIN_LAYER_CLOSEWINDOW = autoIndex()
E.POPUP_LAYER_OPENWINDOW = autoIndex()
E.POPUP_LAYER_CLOSEWINDOW = autoIndex()
E.BREAKRIDESKILL_LAYER_OPENWINDOW = autoIndex()
return UILayerEvent
