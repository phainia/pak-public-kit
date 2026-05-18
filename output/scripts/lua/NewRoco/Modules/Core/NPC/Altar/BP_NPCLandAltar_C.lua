require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCLandAltar = Base:Extend("BP_NPCLandAltar")

function BP_NPCLandAltar:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCLandAltar:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.addMesh = false
end

function BP_NPCLandAltar:PlayOptTimesOverEffect()
  Log.Debug("BP_NPCLandAltar:PlayOptTimesOverEffect")
  local res = UE4.UKismetSystemLibrary.LoadAsset_Blocking(self.ParticleRes)
  self.Niagara:SetAsset(res)
  self.Niagara:SetActive(true, true)
  self.Niagara:SetVisibility(true)
  _G.DelayManager:DelaySeconds(0.3, self.PlayOptTimesOverLoopEffect, self)
end

function BP_NPCLandAltar:PlayOptTimesOverLoopEffect()
  Log.Debug("BP_NPCLandAltar:PlayOptTimesOverLoopEffect")
  if not self.addMesh then
    self:AddStaticMeshRes(self.FruitMeshRes, self.FruitStaticMesh)
    local res = UE4.UKismetSystemLibrary.LoadAsset_Blocking(self.FruitMeshRes)
    self.FruitStaticMesh:SetStaticMesh(res)
    self.FruitStaticMesh:SetActive(true)
    self.FruitStaticMesh:SetVisibility(true)
    self.addMesh = true
  end
end

return BP_NPCLandAltar
