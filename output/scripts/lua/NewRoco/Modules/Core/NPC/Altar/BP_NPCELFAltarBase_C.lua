require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCELFAltarBase = Base:Extend("BP_NPCELFAltarBase")

function BP_NPCELFAltarBase:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCELFAltarBase:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCELFAltarBase:OnInVisible()
  self.RocoSkill:StopCurrentSkill()
  Base.OnInVisible(self)
end

function BP_NPCELFAltarBase:PlayOptTimesOverEffect()
  self:PlayOptTimesOverLoopEffect()
end

function BP_NPCELFAltarBase:PlayOptTimesOverLoopEffect()
  Log.Debug("BP_NPCELFAltarBase:PlayOptTimesOverLoopEffect")
  local skillClass = UE4.UKismetSystemLibrary.LoadClassAsset_Blocking(self.litSkill)
  local skillObj = self.RocoSkill:FindOrAddSkillObj(skillClass)
  if skillObj then
    skillObj:SetCaster(self)
    self.RocoSkill:PlaySkill(skillObj)
  end
end

return BP_NPCELFAltarBase
