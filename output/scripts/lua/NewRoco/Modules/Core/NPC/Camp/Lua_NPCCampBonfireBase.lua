local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCCampBonfireBase = Base:Extend("Lua_NPCCampBonfireBase")

function Lua_NPCCampBonfireBase:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if self.sceneCharacter then
    self.IsActivate = SceneUtils.IsLogicStatusBonfireActivated(self.sceneCharacter)
  else
    self.IsActivate = false
  end
  if self.sceneCharacter then
    self.IsUnlockByJiDian = SceneUtils.IsLogicStatusUnlockJiDian(self.sceneCharacter)
  else
    self.IsUnlockByJiDian = true
  end
  if not self.sceneCharacter.serverData.base.lv then
    Log.Error("\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132\230\149\176\230\141\174\230\156\137\233\151\174\233\162\152,lv\230\149\176\230\141\174\228\184\141\229\173\152\229\156\168\239\188\140\232\175\183\229\144\142\229\143\176\230\159\165\230\159\165\231\156\139")
    self.CampLevel = 1
  else
    self.CampLevel = self.sceneCharacter.serverData.base.lv
  end
  if self.CampLevel >= 0 and self.CampLevel <= 3 then
  else
    Log.Error("\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132Camp\231\173\137\231\186\167\230\156\137\233\151\174\233\162\152\239\188\140\230\137\190\229\144\142\229\143\176\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129", self.CampLevel)
    self.CampLevel = 1
  end
end

function Lua_NPCCampBonfireBase:OnSetViewObj()
  Base.OnSetViewObj(self)
  local Camp = self.viewObj
  Camp.IsActivate = self.IsActivate
  Camp.CampLevel = self.CampLevel
  Camp.IsUnlockByJiDian = self.IsUnlockByJiDian
  self:OnLogicStatusChange()
end

function Lua_NPCCampBonfireBase:OnLogicStatusChange(ChangeInfo)
  Log.Debug("Lua_NPCCampBonfireBase:OnLogicStatusChange", self.IsActivate, SceneUtils.IsLogicStatusBonfireActivated(self.sceneCharacter))
  if self.IsActivate ~= SceneUtils.IsLogicStatusBonfireActivated(self.sceneCharacter) then
    self.IsActivate = not self.IsActivate
  end
  local Camp = self.viewObj
  if not Camp then
    return nil
  end
  if SceneUtils.IsLogicStatusUnlockJiDian(self.sceneCharacter) == true then
    if self.IsUnlockByJiDian ~= SceneUtils.IsLogicStatusUnlockJiDian(self.sceneCharacter) then
      self.IsUnlockByJiDian = not self.IsUnlockByJiDian
      Camp.IsUnlockByJiDian = self.IsUnlockByJiDian
      if self.IsUnlockByJiDian then
        Camp:PlayUnlockJiDianEffect()
      else
      end
    elseif nil == ChangeInfo or ChangeInfo and ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_BONFIRE_ACTIVE then
      if self.IsActivate then
        Camp:PlayActivateEffect(nil ~= ChangeInfo)
      else
        Camp:DeactivateBonfire()
      end
    end
  elseif self.IsUnlockByJiDian ~= SceneUtils.IsLogicStatusUnlockJiDian(self.sceneCharacter) then
    self.IsUnlockByJiDian = not self.IsUnlockByJiDian
    Camp.IsUnlockByJiDian = self.IsUnlockByJiDian
  end
end

function Lua_NPCCampBonfireBase:OnLevelChange(NewLevel)
  Base.OnLevelChange(self, NewLevel)
  Log.Debug("\233\156\178\232\144\165\229\141\135\231\186\167\239\188\140 \230\156\137\228\187\128\228\185\136\228\184\156\232\165\191\229\143\152\228\186\134", self.sceneCharacter.serverData.base.lv)
end

return Lua_NPCCampBonfireBase
