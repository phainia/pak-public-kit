require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCWoodBoxBase_C = Base:Extend("BP_NPCWoodBoxBase_C")

function BP_NPCWoodBoxBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.HoldItem = false
end

function BP_NPCWoodBoxBase_C:Init()
  Base.Init(self)
  self.NeedDisappear = false
end

function BP_NPCWoodBoxBase_C:Recycle()
  self.NeedDisappear = false
  Base.Recycle(self)
end

function BP_NPCWoodBoxBase_C:OnVisible()
  Base.OnVisible(self)
end

function BP_NPCWoodBoxBase_C:OnInVisible()
  Base.OnInVisible(self)
end

function BP_NPCWoodBoxBase_C:Show()
  if self.HoldItem then
    for k, v in ipairs(self.sceneCharacter.luaObj.createdNPC) do
      v.sceneCharacter.InteractionComponent:TryDisableInteraction()
    end
  else
    for k, v in ipairs(self.sceneCharacter.luaObj.createdNPC) do
      v.sceneCharacter.InteractionComponent:TryEnableInteraction()
    end
    self.sceneCharacter.shouldDestroy = false
    Base.Show(self)
  end
end

function BP_NPCWoodBoxBase_C:GetExplodeLocation()
  local vec = self:Abs_K2_GetActorLocation()
  return UE4.FVector(vec.X, vec.Y, vec.Z + 70)
end

function BP_NPCWoodBoxBase_C:PlayDisappearPerform()
  self.NeedDisappear = true
end

function BP_NPCWoodBoxBase_C:CanEnterThrowInter(Comp)
  return Comp and Comp == self.StaticMesh
end

function BP_NPCWoodBoxBase_C:BeforeDestroyAnim()
  if self.Beam then
    self.Beam:SetVisibility(false)
  end
end

return BP_NPCWoodBoxBase_C
