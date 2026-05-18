local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetCatchInfo = Base:Extend("LuaActionGetCatchInfo")

function LuaActionGetCatchInfo:OnStart(owner)
  local TargetNpc = self.TargetNpc:GetValue(owner)
  if not TargetNpc or TargetNpc.config == nil or TargetNpc.AIComponent then
    return self:Finish(false)
  end
  local SelectType = self.SelectType:GetValue(owner)
  local NumType = self.NumType:GetValue(owner)
  local OutNum = 0
  local AIComp = TargetNpc.AIComponent
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return self:Finish(false)
  end
  local recComp = player.CatchRecordComponent
  if not recComp then
    return self:Finish(false)
  end
  if 0 == SelectType then
    local habCatchData = recComp.habitatRecord[AIComp.cfg_habitat or 0]
    if habCatchData then
      if 0 == NumType then
        OutNum = habCatchData.acc_try_catch_time
      elseif 1 == NumType then
        OutNum = habCatchData.acc_catch_succ_time
      elseif 2 == NumType then
        OutNum = habCatchData.acc_catch_fail_time
      elseif 3 == NumType then
        OutNum = habCatchData.exist_npc_num
      elseif 4 == NumType then
        OutNum = habCatchData.can_refresh_npc_num
      end
    end
  elseif 1 == SelectType then
    local evoCatchData = recComp.evoChainRecord[AIComp.cfg_evochain or 0]
    if evoCatchData then
      if 0 == NumType then
        OutNum = evoCatchData.acc_try_catch_time
      elseif 1 == NumType then
        OutNum = evoCatchData.acc_catch_succ_time
      elseif 2 == NumType then
        OutNum = evoCatchData.acc_catch_fail_time
      elseif 3 == NumType then
        return self:Finish(false)
      elseif 4 == NumType then
        return self:Finish(false)
      end
    end
  end
  self.OutNum:SetValue(owner, OutNum)
  self:Finish(true)
end

return LuaActionGetCatchInfo
