local RocoSkillEventCenter = NRCClass()
local tRemove = table.remove
local tInsert = table.insert

function RocoSkillEventCenter:Ctor()
  self.eventMap = {}
  self.eventHashDict = {}
  WeakTable(self.eventHashDict)
  self.evenName = {
    CancelFBBossShield = "CancelFBBossShield",
    ActiveFBBossShield = "ActiveFBBossShield",
    HideFBBossShield = "HideFBBossShield",
    OnHit = "OnHit"
  }
end

function RocoSkillEventCenter:AddEvent(eventName, skillObj)
  if string.IsNilOrEmpty(eventName) then
    return
  end
  if not self:IsValid(skillObj) then
    Log.Error("RocoSkillEventCenter:AddEvent Invalid Obj")
    return
  end
  local eventSkillList = self.eventMap[eventName]
  if not eventSkillList then
    eventSkillList = {}
    self.eventMap[eventName] = eventSkillList
  end
  for i, v in ipairs(eventSkillList) do
    if UE4.UObject.IsValid(v) and skillObj == v then
      return
    end
  end
  self.eventHashDict[skillObj] = true
  tInsert(eventSkillList, skillObj)
end

function RocoSkillEventCenter:RemoveEvent(eventName, skillObj)
  if not self.eventHashDict[skillObj] then
    return
  end
  if string.IsNilOrEmpty(eventName) then
    return
  end
  if not self:IsValid(skillObj) then
    Log.Error("RocoSkillEventCenter:RemoveEvent Invalid Obj")
    return
  end
  local eventSkillList = self.eventMap[eventName]
  if eventSkillList then
    for i = #eventSkillList, 1, -1 do
      local eventSkillObj = eventSkillList[i]
      if UE4.UObject.IsValid(eventSkillObj) and skillObj == eventSkillObj then
        tRemove(eventSkillList, i)
        if 0 == #eventSkillList then
          self.eventMap[i] = nil
        end
        return
      end
    end
  end
end

function RocoSkillEventCenter:RemoveEventBySkillObj(skillObj)
  if not self.eventHashDict[skillObj] then
    return
  end
  if not self:IsValid(skillObj) then
    Log.Error("RocoSkillEventCenter:RemoveEventBySkillObj Invalid Obj")
    return
  end
  for eventName, eventSkillList in pairs(self.eventMap) do
    for i = #eventSkillList, 1, -1 do
      local eventSkillObj = eventSkillList[i]
      if UE4.UObject.IsValid(eventSkillObj) and skillObj == eventSkillObj then
        tRemove(eventSkillList, i)
      end
    end
    if 0 == #eventSkillList then
      self.eventMap[eventName] = nil
    end
  end
  self.eventHashDict[skillObj] = nil
end

function RocoSkillEventCenter:DispatchEvent(eventName, ...)
  if string.IsNilOrEmpty(eventName) then
    return
  end
  local eventSkillList = self.eventMap[eventName]
  if eventSkillList then
    for i = #eventSkillList, 1, -1 do
      local eventSkillObj = eventSkillList[i]
      if self:IsValid(eventSkillObj) then
        eventSkillObj:OnSkillEvent(eventName, ...)
      else
        tRemove(eventSkillList, i)
      end
    end
    if 0 == #eventSkillList then
      self.eventMap[eventName] = nil
    end
  else
    Log.Warning("wjf RocoSkillEventCenter:DispatchEvent No Add ", eventName, self)
  end
end

function RocoSkillEventCenter:IsValid(obj)
  if not obj then
    return false
  end
  return UE4.UObject.IsValid(obj) and obj.OnSkillEvent ~= nil
end

return RocoSkillEventCenter
