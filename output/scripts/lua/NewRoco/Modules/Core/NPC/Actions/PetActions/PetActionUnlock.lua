local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local PetTypeInteractActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetTypeInteractActionBase")
local Base = PetTypeInteractActionBase
local PetActionUnlock = Base:Extend("PetActionUnlock")

function PetActionUnlock:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionUnlock:IsEnabled()
  if not self.Owner then
    return true
  end
  return not SceneUtils.IsLogicStatusUnlock(self.Owner.owner) and not self.Owner:IsDisableByOnlineModePetAction()
end

function PetActionUnlock:OnExecute()
  local Box = self:GetOwnerNPCView()
  if not Box then
    self:Finish(false)
    return
  end
  self.interact_type = _G.Enum.SkillDamType.SDT_NONE
  if self.Config.interact_cond_group == nil then
    self:Submit()
    self:Finish(false)
    Log.Error("\231\179\187\229\136\171\229\174\157\231\174\177\230\155\180\230\150\176\230\155\191\230\141\162\228\184\173\239\188\140\231\173\137\231\157\191\229\147\165\230\155\191\230\141\162\229\174\140\230\136\144\233\133\141\231\189\174\229\176\177\229\165\189\228\186\134")
    return
  end
  for _, config in pairs(self.Config.interact_cond_group) do
    if config.interact_cond == _G.Enum.PetInteract_cond.COND_SKILLDAM then
      for _, Type in ipairs(config.interact_cond_param) do
        self.interact_type = Enum.SkillDamType[Type]
      end
    else
      local serverData = self.Runner and self.Runner.serverData
      local pet_info = serverData and serverData.pet_info
      local pet_base_id = pet_info and pet_info.pet_base_conf_id or 3000101
      local pet_base_conf = _G.DataConfigManager:GetPetbaseConf(pet_base_id)
      self.interact_type = pet_base_conf.unit_type[1] or _G.Enum.SkillDamType.SDT_COMMON
    end
  end
  _G.NRCEventCenter:RegisterEvent("PetActionUnlock", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  Box.is_unlocking = true
  self:DoPetTypeInteraction(self, self.PreSubmit)
end

function PetActionUnlock:PreFailed(BubbleSuccess)
  self:Finish(false)
end

function PetActionUnlock:PreSubmit(Success)
  local Box = self:GetOwnerNPCView()
  if not Box then
    self:Finish(false)
    return
  end
  if not Success then
    return
  end
  self:Submit()
end

function PetActionUnlock:OnUnlock()
  local Box = self:GetOwnerNPCView()
  if not Box then
    return
  end
  if Box.UnlockBox then
    Box:UnlockBox()
  end
  Box.is_unlocking = false
end

function PetActionUnlock:OnSubmit(rsp)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  Base.OnSubmit(self, rsp)
end

function PetActionUnlock:OnReConnect()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  local Box = self:GetOwnerNPCView()
  if not Box then
    return
  end
  Box.is_unlocking = false
end

return PetActionUnlock
