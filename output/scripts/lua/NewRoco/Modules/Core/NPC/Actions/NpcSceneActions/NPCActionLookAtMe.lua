local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionLookAtMe = Base:Extend("NPCActionLookAtMe")

function NPCActionLookAtMe:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = false
  self.isRegistered = false
  self.isLookAtMe = false
end

function NPCActionLookAtMe:Execute()
end

function NPCActionLookAtMe:Finish(success, data, param)
end

function NPCActionLookAtMe:OnNpcAction()
  if self.isRegistered then
    return true
  end
  if not NRCModuleManager:IsModuleActive("NpcNeedLookModule") then
    NRCModuleManager:ActiveModule("NpcNeedLookModule")
  end
  local playerTurnScale = tonumber(self.Config.action_param1) or 1
  _G.NRCModuleManager:DoCmd(_G.NpcNeedLookModuleCmd.RegisterNpc, self:GetOwnerNPC(), playerTurnScale)
  self.isRegistered = true
  return true
end

function NPCActionLookAtMe:OnPlayerLeaveActionArea()
  if _G.NRCModuleManager:IsModuleActive("NpcNeedLookModule") then
    _G.NRCModuleManager:DoCmd(_G.NpcNeedLookModuleCmd.UnRegisterNpc, self:GetOwnerNPC())
    self.isRegistered = false
  end
  Base.OnPlayerLeaveActionArea(self)
end

function NPCActionLookAtMe:Destroy()
  _G.NRCModuleManager:DoCmd(_G.NpcNeedLookModuleCmd.UnRegisterNpc, self:GetOwnerNPC())
  Base.Destroy()
end

function NPCActionLookAtMe:IfActionNeedStatusNotify()
  return false
end

return NPCActionLookAtMe
