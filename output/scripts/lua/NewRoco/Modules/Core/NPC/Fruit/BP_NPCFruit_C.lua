require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local TreeShakeConfig = require("NewRoco.Modules.Core.NPC.Config.TreeShakeConfig")
local DebugUtils = require("NewRoco.Modules.Core.Scene.Common.DebugUtils")
local BP_NPCFruit_C = Base:Extend("BP_NPCFruit_C")

function BP_NPCFruit_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCFruit_C:Init()
  Base.Init(self)
  local Root = self:K2_GetRootComponent()
  if Root then
    Root:SetLinearDamping(0.01)
    Root:SetAngularDamping(1)
  end
  self.totalHeight = nil
  self.bMountFruit = nil
  self.bGPUDamping = false
  self.M_Fruit = nil
  self.HangOffset = UE4.FVector(0, 0, 0)
  self.bShakeTree = false
end

function BP_NPCFruit_C:LuaBeginPlay(DropParticle)
  Base.LuaBeginPlay(self)
  if not self.Icon_Drop then
    return
  end
  if nil == DropParticle then
    self.Icon_Drop:SetComponentActive(true)
  else
    self.Icon_Drop:SetComponentActive(false)
    self.bMountFruit = true
    self.bGPUDamping = true
  end
end

function BP_NPCFruit_C:OnLoadResource()
  Log.Debug("BP_NPCFruit_C:OnLoadResource")
  if self.bMountFruit then
    self:PrepareMaterial()
  end
  Base.OnLoadResource(self)
end

function BP_NPCFruit_C:PrepareMaterial()
  Log.Debug("BP_NPCFruit_C:PrepareMaterial")
  local sourceMaterial = self.StaticMesh:GetMaterial(0)
  local dyMaterial = self.StaticMesh:CreateDynamicMaterialInstance(0, sourceMaterial)
  self.M_Fruit = dyMaterial
  if self.bGPUDamping and self.M_Fruit then
    self.M_Fruit:SetScalarParameterValue("x0", TreeShakeConfig.FruitWind.x0)
    self.M_Fruit:SetScalarParameterValue("p", TreeShakeConfig.FruitWind.p)
    self.M_Fruit:SetScalarParameterValue("w", TreeShakeConfig.FruitWind.w)
    self.M_Fruit:SetScalarParameterValue("TimeSpeed", TreeShakeConfig.FruitWind.timeSpeed)
    self.M_Fruit:SetScalarParameterValue("phase", UE4.UKismetMathLibrary.RandomFloatInRange(0, 2 * math.pi))
    self.M_Fruit:SetScalarParameterValue("bFruitShake", 2)
    self:SetHangPoint()
  end
end

function BP_NPCFruit_C:DebugDetail()
  Log.Debug("BP_NPCFruit_C:DebugDetail")
  Log.Debug("HangOffset", self.HangOffset.X, self.HangOffset.Y, self.HangOffset.Z)
  if self.M_Fruit then
    local hangPosColor = self.M_Fruit:K2_GetVectorParameterValue("HangPoint")
    local hangPos = UE4.FVector(hangPosColor.R, hangPosColor.G, hangPosColor.B)
    DebugUtils.DebugPointByLine(hangPos)
  else
    Log.Error("\230\178\161\230\156\137M_Fruit?")
  end
end

function BP_NPCFruit_C:SetTreeAngle(angle)
  if self.bGPUDamping and self.M_Fruit then
    self.M_Fruit:SetScalarParameterValue("TreeAngle", angle)
  else
    self.TreeAngle = angle
  end
end

function BP_NPCFruit_C:Mount(pos)
  local hangPos = self.HangPoint:GetRelativeTransform().Translation
  self:Abs_K2_SetActorLocation_WithoutHit(pos - hangPos)
end

function BP_NPCFruit_C:MountByOffset(compLocation, offset)
  self:Abs_K2_SetActorLocation_WithoutHit(compLocation + offset)
end

function BP_NPCFruit_C:ReceiveTick(DeltaSeconds)
  Base.ReceiveTick(self, DeltaSeconds)
end

function BP_NPCFruit_C:DampedOscillation(x0, p, w, phase, time, timeSpeed)
  if self.ConfigDampedOscillation then
    return self.ConfigDampedOscillation(x0, p, w, phase, time, timeSpeed)
  end
  if self.Overridden.DampedOscillation then
    return self.Overridden.DampedOscillation(self, x0, p, w, phase, time, timeSpeed)
  end
end

function BP_NPCFruit_C:OnVisible()
  Base.OnVisible(self)
  self.Item_Gleam:SetActive(true)
end

function BP_NPCFruit_C:OnInVisible()
  Base.OnInVisible(self)
  self.bShakeTree = false
  self.Item_Gleam:SetActive(false)
end

function BP_NPCFruit_C:Grow()
  self:SetActorHiddenInGame(false)
  if self.FruitGrow then
    self:FruitGrow()
  end
  self.NRCNiagaraSystem:SetPath(UE4.UNRCStatics.GetSoftObjPath(self.GrowNiagaraRes))
end

function BP_NPCFruit_C:Recycle()
  self.bShakeTree = false
  Base.Recycle(self)
end

function BP_NPCFruit_C:GetTotalHeight()
  if not self.totalHeight then
    if self.StaticMesh.Height and self.StaticMesh.Height > 0 then
      self.totalHeight = self.StaticMesh.Height
    else
      self.totalHeight = 30
    end
  end
  return self.totalHeight
end

function BP_NPCFruit_C:GetHalfHeight()
  return self:GetTotalHeight() / 2
end

function BP_NPCFruit_C:GetFixHeight()
  return self:GetHalfHeight() * 2
end

return BP_NPCFruit_C
