local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Stat = require("NewRoco.Modules.Core.Scene.Component.Stat.Stat")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local StatComponent = Base:Extend("StatComponent")

function StatComponent:Ctor()
  self._statDic = {}
  self._statObjDic = {}
end

function StatComponent:Attach(owner)
  Base.Attach(self, owner)
  self:ClearStat()
end

function StatComponent:GetStat(name, uObj)
  if uObj then
    local statObjDic = self._statObjDic[uObj] or {}
    self._statObjDic[uObj] = statObjDic
    return statObjDic[name]
  end
  return self._statDic[name]
end

function StatComponent:GetValue(name, uObj)
  local stat = self:GetStat(name, uObj)
  if stat then
    return stat.value
  end
  return nil
end

function StatComponent:RemoveStat(name, id, uObj)
  local stat = self:GetStat(name, uObj)
  if stat then
    stat:Remove(id)
    local currentValue = stat:GetValue()
    self:ApplyStatToBindProperty(name, currentValue, uObj)
    if stat:Num() <= 1 and uObj then
      table.removeKey(self._statObjDic[uObj], name)
      if 0 == table.len(self._statObjDic[uObj]) then
        table.removeKey(self._statObjDic, uObj)
      end
    end
  end
end

function StatComponent:ApplyStat(name, value, applyType, uObj, defaultValue)
  local stat = self:GetStat(name, uObj)
  if not stat then
    stat = self:CreateDefaultStat(name, uObj, defaultValue)
    if not stat then
      return Log.Error("No stat and can't create default stat named ", name)
    end
  end
  if stat then
    local statID = stat:Apply(value, applyType)
    local currentValue = stat:GetValue()
    self:ApplyStatToBindProperty(name, currentValue, uObj)
    return statID
  end
end

function StatComponent:ApplyStatByTable(name, valueTable, uObj)
  local stat = self:GetStat(name, uObj)
  if not stat then
    stat = self:CreateDefaultStat(name, uObj)
    if not stat then
      return Log.Error("No stat and can't create default stat named ", name)
    end
  end
  if stat then
    local statID = stat:ApplyByTable(valueTable)
    local currentValue = stat:GetValue()
    self:ApplyStatToBindProperty(name, currentValue, uObj)
    return statID
  end
  return -1
end

function StatComponent:CreateDefaultStat(name, uObj, defaultValue)
  if uObj then
    return self:CreateStat(name, nil, uObj)
  end
  return self:CreateStat(name, defaultValue)
end

function StatComponent:ApplyStatToBindProperty(name, value, uObj)
  if UE4.UObject.IsValid(uObj) then
    local bSuccess = false
    if type(value) == "number" then
      local valueStr = tostring(value)
      bSuccess = UE.UNRCStatics.SetPropertyValue(uObj, name, valueStr)
    else
      bSuccess = UE.UNRCStatics.SetPropertyValue(uObj, name, value)
    end
    if not bSuccess then
      Log.ErrorFormat("StatComponent:ApplyStatToBindProperty %s Failed", name)
    end
    return
  end
end

function StatComponent:CreateStat(name, value, uObj)
  if uObj then
    local uObjStatDic = self._statObjDic[uObj] or {}
    self._statObjDic[uObj] = uObjStatDic
    local stat = uObjStatDic[name]
    if stat then
      return stat
    end
    local objValue, bSuccess = UE.UNRCStatics.GetPropertyValue(uObj, name)
    if not bSuccess then
      Log.ErrorFormat("StatComponent:CreateStat %s Failed", name)
      return nil
    end
    local numObjValue = tonumber(objValue)
    if tonumber(numObjValue) then
      stat = Stat(name, numObjValue)
      uObjStatDic[name] = stat
      return stat
    end
    stat = Stat(name, objValue)
    uObjStatDic[name] = stat
    return stat
  end
  local stat = self._statDic[name]
  if not stat then
    stat = Stat(name, value)
    self._statDic[name] = stat
  end
  return stat
end

function StatComponent:ClearStat()
  for k, v in pairs(self._statDic) do
    v:OnClear()
  end
  self._statDic = {}
  for k, v in pairs(self._statObjDic) do
    for k1, v1 in pairs(v) do
      v1:OnClear()
    end
  end
  self._statObjDic = {}
end

function StatComponent:Destroy()
  self:ClearStat()
  self._statDic = {}
  self._statObjDic = {}
end

return StatComponent
