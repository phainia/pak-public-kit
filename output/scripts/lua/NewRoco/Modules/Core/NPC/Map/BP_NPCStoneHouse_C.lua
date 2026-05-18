require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCStoneHouse = Base:Extend("BP_NPCStoneHouse")

function BP_NPCStoneHouse:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCStoneHouse:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCStoneHouse:OnInVisible()
  self.RocoSkill:StopCurrentSkill()
  Base.OnInVisible(self)
end

function BP_NPCStoneHouse:LoadLockEffect()
end

function BP_NPCStoneHouse:PlayUnlockEffect()
  Log.Debug("BP_NPCStoneHouse:PlayUnlockSkill")
  self:PlaySkill(self.Unlock, self.PlayUnlockLoopEffect)
  _G.NRCAudioManager:PlaySound2DAuto(1101, "BP_NPCStoneHouse:PlayUnlockEffect")
  local tipTxt = _G.DataConfigManager:GetLocalizationConf("Unlock_Teleport_Npc_Tips")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipTxt.msg)
end

function BP_NPCStoneHouse:PlayUnlockLoopEffect()
  Log.Debug("BP_NPCStoneHouse:PlayUnlockLoopSkill")
  self:PlaySkill(self.Loop)
end

function BP_NPCStoneHouse:PlaySkill(skillObj, callback)
  local skillClass = UE4.UKismetSystemLibrary.LoadClassAsset_Blocking(skillObj)
  local skillObj = self.RocoSkill:FindOrAddSkillObj(skillClass)
  if skillObj then
    skillObj:SetCaster(self)
    if callback then
      skillObj:RegisterEventCallback("End", self, callback)
    end
    self.RocoSkill:PlaySkill(skillObj)
  end
end

return BP_NPCStoneHouse
