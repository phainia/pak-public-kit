require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCELFKingAltar_C = Base:Extend("BP_NPCELFKingAltar")

function BP_NPCELFKingAltar_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCELFKingAltar_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCELFKingAltar_C:OnInVisible()
  Base.OnInVisible(self)
end

function BP_NPCELFKingAltar_C:LoadLockEffect()
end

function BP_NPCELFKingAltar_C:PlayUnlockEffect()
end

function BP_NPCELFKingAltar_C:PlayUnlockSkillFinish()
  self:PlayUnlockLoopEffect()
end

function BP_NPCELFKingAltar_C:UnexpectedStop()
end

function BP_NPCELFKingAltar_C:PlayLockLoopEffect()
end

function BP_NPCELFKingAltar_C:PlayUnlockLoopEffect()
end

function BP_NPCELFKingAltar_C:StopAllSkill()
end

function BP_NPCELFKingAltar_C:PlaySkill(skillComp, skillObj, callback, bPassive)
end

return BP_NPCELFKingAltar_C
