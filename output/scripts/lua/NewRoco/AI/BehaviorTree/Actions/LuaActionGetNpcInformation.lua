local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetNpcInformation = Base:Extend("LuaActionGetNpcInformation")

function LuaActionGetNpcInformation:OnStart(owner)
  local Target = self.Target:GetValue(owner)
  if nil == Target then
    self:Finish(false)
    return
  end
  if not Target.config then
    self:Finish(false)
    return
  end
  local NpcBaseInfo = Target.serverData.npc_base
  if not NpcBaseInfo then
    self:Finish(false)
    return
  end
  local NpcId = NpcBaseInfo.npc_cfg_id
  local RefreshId = NpcBaseInfo.npc_content_cfg_id
  if self.OutNpcId and self.OutNpcId.useBlackboardKey then
    self.OutNpcId:SetValue(owner, NpcId)
  end
  if self.OutRefreshContentId and self.OutRefreshContentId.useBlackboardKey then
    self.OutRefreshContentId:SetValue(owner, RefreshId)
  end
  if self.OutPetFirstType and self.OutPetFirstType.useBlackboardKey then
    local PetFirstType = 0
    local PetBaseConf = Target:GetConfPetData()
    if PetBaseConf and #PetBaseConf.unit_type > 0 then
      PetFirstType = PetBaseConf.unit_type[1]
    end
    self.OutPetFirstType:SetValue(owner, PetFirstType)
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return self:Finish(false)
  end
  local localPlayerId = localPlayer:GetServerId()
  local session = Target.ThrowSession
  local homeModule = _G.NRCModuleManager:GetModule("HomeModule")
  local homeMasterId = homeModule and _G.HomeIndoorSandbox and _G.HomeIndoorSandbox.Server.MasterId or 0
  if session then
    if self.OutThrowOwner and self.OutThrowOwner.useBlackboardKey then
      if session.owner_id == localPlayerId then
        self.OutThrowOwner:SetValue(owner, 1)
      else
        self.OutThrowOwner:SetValue(owner, 2)
      end
    end
    if self.OutThrowHomeOwner and self.OutThrowHomeOwner.useBlackboardKey then
      if session.owner_id == homeMasterId then
        self.OutThrowHomeOwner:SetValue(owner, 1)
      else
        self.OutThrowHomeOwner:SetValue(owner, 2)
      end
    end
  else
    if self.OutThrowOwner and self.OutThrowOwner.useBlackboardKey then
      self.OutThrowOwner:SetValue(owner, 0)
    end
    if self.OutThrowHomeOwner and self.OutThrowHomeOwner.useBlackboardKey then
      self.OutThrowHomeOwner:SetValue(owner, 0)
    end
  end
  self:Finish(true)
end

return LuaActionGetNpcInformation
