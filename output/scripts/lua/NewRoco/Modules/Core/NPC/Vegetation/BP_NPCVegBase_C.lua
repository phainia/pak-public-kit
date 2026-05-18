require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCVegBase_C = Base:Extend("BP_NPCVegBase_C")

function BP_NPCVegBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCVegBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCVegBase_C:OnVisible()
  Base.OnVisible(self)
  self.Item_Gleam:SetActive(true)
  if self.sceneCharacter and self.sceneCharacter.serverData and self.sceneCharacter.serverData.npc_base and self.sceneCharacter.serverData.npc_base.home_plant_land_id and 0 ~= self.sceneCharacter.serverData.npc_base.home_plant_land_id and self.OpenCustomDepth then
    self:OpenCustomDepth()
  end
end

function BP_NPCVegBase_C:OnInVisible()
  Base.OnInVisible(self)
  self.Item_Gleam:SetActive(false)
end

function BP_NPCVegBase_C:GetHalfHeight()
  return 0
end

function BP_NPCVegBase_C:Show()
  Log.Debug("BP_NPCVegBase_C:Show", self:GetDebugInfo())
  Base.Show(self)
end

function BP_NPCVegBase_C:GetExplodeLocation()
  local vec = self:Abs_K2_GetActorLocation()
  return UE4.FVector(vec.X, vec.Y, vec.Z + 70)
end

return BP_NPCVegBase_C
