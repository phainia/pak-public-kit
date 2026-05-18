local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUIModuleData = _G.NRCData:Extend("BattleUIModuleData")

function BattleUIModuleData:Ctor()
  NRCData.Ctor(self)
  self.PreProcessCmd = {}
  self.BattleNotify = {}
  local loadingBlackScreenState = {}
  local openReasonMap = {}
  local ShowBlackScreenReason = BattleEnum.ShowBlackScreenReason or {}
  for reasonName, reasonValue in pairs(ShowBlackScreenReason) do
    openReasonMap[reasonValue] = false
  end
  loadingBlackScreenState.openReasonMap = openReasonMap
  self.loadingBlackScreenState = loadingBlackScreenState
end

function BattleUIModuleData:InitializeFsmData()
  table.clear(self.PreProcessCmd)
  table.clear(self.BattleNotify)
end

function BattleUIModuleData:GetPreProcessCmd()
  return self.PreProcessCmd
end

function BattleUIModuleData:AddPreProcessCmd(cmd)
  table.insert(self.PreProcessCmd, cmd)
end

function BattleUIModuleData:ClearProcessCmd()
  table.clear(self.PreProcessCmd)
end

function BattleUIModuleData:GetBattleNotify()
  return self.BattleNotify
end

function BattleUIModuleData:AddBattleNotify(notifyCmdId)
  local svr_time = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  svr_time = os.date("%H:%M:%S", svr_time)
  local MessageName = ProtoCMD:GetMessageName(notifyCmdId)
  table.insert(self.BattleNotify, {svr_time, MessageName})
end

function BattleUIModuleData:GetObserverBriefInfoList()
  local observerDataList = {}
  if not self:HasObserverBriefInfo() then
    return observerDataList
  end
  local observingInfo = _G.BattleManager.battleRuntimeData.observingInfo
  for i, info in ipairs(observingInfo.ObserverBriefInfoList) do
    local data = {}
    table.copy(info, data)
    table.insert(observerDataList, data)
  end
  return observerDataList
end

function BattleUIModuleData:HasObserverBriefInfo()
  local observingInfo = _G.BattleManager.battleRuntimeData.observingInfo
  if not observingInfo or not observingInfo.ObserverBriefInfoList then
    return false
  end
  return true
end

function BattleUIModuleData:FindObserverBriefInfoIndexByUin(uin)
  if not self:HasObserverBriefInfo() then
    return 0
  end
  local observingInfo = _G.BattleManager.battleRuntimeData.observingInfo
  for i, info in ipairs(observingInfo.ObserverBriefInfoList) do
    if info.uin == uin then
      return i
    end
  end
  return 0
end

function BattleUIModuleData:FindObserverBriefInfoByUin(uin)
  if not self:HasObserverBriefInfo() then
    return nil
  end
  local observingInfo = _G.BattleManager.battleRuntimeData.observingInfo
  for i, info in ipairs(observingInfo.ObserverBriefInfoList) do
    if info.uin == uin then
      return info
    end
  end
  return nil
end

function BattleUIModuleData:AddObserverBriefInfo(briefInfo)
  if not self:HasObserverBriefInfo() then
    return
  end
  local observingInfo = _G.BattleManager.battleRuntimeData.observingInfo
  if self:FindObserverBriefInfoIndexByUin(briefInfo.uin) > 0 then
    Log.Warning("BattleUIModuleData:AddObserverBriefInfo briefInfo with the same uin should not be add more than once.")
    return
  end
  table.insert(observingInfo.ObserverBriefInfoList, briefInfo)
end

function BattleUIModuleData:RemoveObserverBriefInfo(briefInfo)
  if not self:HasObserverBriefInfo() then
    return
  end
  local observingInfo = _G.BattleManager.battleRuntimeData.observingInfo
  local index = self:FindObserverBriefInfoIndexByUin(briefInfo.uin)
  table.remove(observingInfo.ObserverBriefInfoList, index)
end

return BattleUIModuleData
