local EventDispatcher = require("Common.EventDispatcher")
local BattleEventCenter = NRCClass:Extend("BattleEventCenter")
local EmptyTable = {}

function BattleEventCenter:Ctor()
  self.eventDispatcher = NRCClass()
  EventDispatcher():Attach(self.eventDispatcher)
  self.targetHashDict = {}
  self.eventHashDict = {}
end

function BattleEventCenter:Bind(target, ...)
  local nodeLst = self.targetHashDict[target]
  if nodeLst then
    return
  else
    local eventLst = {
      ...
    }
    self.targetHashDict[target] = {}
    nodeLst = self.targetHashDict[target]
    for i = 1, #eventLst do
      local eventName = eventLst[i]
      local targetLst = self.eventHashDict[eventName]
      if not targetLst then
        self.eventHashDict[eventName] = {}
        targetLst = self.eventHashDict[eventName]
      end
      table.insert(targetLst, target)
      local node = {
        eventName,
        #targetLst
      }
      table.insert(nodeLst, node)
    end
  end
end

function BattleEventCenter:UnBind(target)
  local nodeLst = self.targetHashDict[target]
  if nodeLst then
    for i = 1, #nodeLst do
      local eventName = nodeLst[i][1]
      local targetIdx = nodeLst[i][2]
      self.eventHashDict[eventName][targetIdx] = EmptyTable
    end
    self.targetHashDict[target] = nil
  end
end

function BattleEventCenter:UnBindByList(target, ...)
  local removeLst = {
    ...
  }
  if 0 == #removeLst then
    return
  end
  local nodeLst = self.targetHashDict[target]
  if nodeLst then
    for nodeIdx = #nodeLst, 1, -1 do
      local eventName = nodeLst[nodeIdx][1]
      for removeIdx = 1, #removeLst do
        if eventName == removeLst[removeIdx] then
          local targetIdx = nodeLst[nodeIdx][2]
          self.eventHashDict[eventName][targetIdx] = EmptyTable
          table.remove(nodeLst, nodeIdx)
        end
      end
    end
    if 0 == #nodeLst then
      self.targetHashDict[target] = nil
    end
  end
end

function BattleEventCenter:UnbindAll()
  self.targetHashDict = {}
  self.eventHashDict = {}
end

function BattleEventCenter:Dispatch(eventName, ...)
  self:OnBattleEvent(eventName, ...)
end

function BattleEventCenter:OnBattleEvent(eventName, ...)
  local targetLst = self.eventHashDict[eventName]
  if targetLst then
    for _, handlerTarget in pairs(targetLst) do
      if handlerTarget and handlerTarget.OnBattleEvent then
        handlerTarget:OnBattleEvent(eventName, ...)
      end
    end
  end
end

return BattleEventCenter
