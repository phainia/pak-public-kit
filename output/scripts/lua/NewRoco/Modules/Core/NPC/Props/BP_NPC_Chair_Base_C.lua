local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPC_Chair_Base_C = Base:Extend("BP_NPC_Chair_Base_C")

function BP_NPC_Chair_Base_C:ReceiveBeginPlay()
  if UE4Helper.GetCurrentWorld() and self.SwitchMesh then
    self:SwitchMesh(true)
  end
  Base.ReceiveBeginPlay(self)
end

function BP_NPC_Chair_Base_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if self.sceneCharacter then
    local StaticMesh = self:GetComponentByClass(UE4.UStaticMeshComponent)
    if StaticMesh then
      StaticMesh:SetWorldScale3D(_G.FVectorOne * self.sceneCharacter:GetConfigScale())
    end
  end
end

local Min = UE.FVector()
local Max = UE.FVector()

function BP_NPC_Chair_Base_C:GetInteractMarkHeight()
  local StaticMesh = self:GetComponentByClass(UE4.UStaticMeshComponent)
  if StaticMesh then
    StaticMesh:GetLocalBounds(Min, Max)
    local extend = Max.Z - Min.Z
    Min:Set(0, 0, 0)
    Max:Set(0, 0, 0)
    return extend
  end
  return 0
end

return BP_NPC_Chair_Base_C
