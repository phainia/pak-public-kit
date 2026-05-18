require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local MathExtend = require("Utils.MathExtend")
local BP_NPCSaplingBase_C = Base:Extend("BP_NPCSaplingBase_C")

function BP_NPCSaplingBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.GrowUpSpeed = 0.5
  self.CachedFruits = {}
  self.RandomLocations = {}
  self.UsedLocation = {}
end

function BP_NPCSaplingBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self:AddGeometryCache(self.SaplingCacheRes, self.GeometryCache)
  if self.bIsSeeding then
    self.RandomLocations = MathExtend.GetRandomSequence_TArray(self.FruitsLocations, self.FruitsLocations:Length())
  end
end

function BP_NPCSaplingBase_C:SetSaplingStatus()
  if self.bIsSeeding then
    self.GeometryCache:SetStartTimeOffset(0.3)
  else
    self.GeometryCache:SetStartTimeOffset(2.0)
  end
end

function BP_NPCSaplingBase_C:GrowUp()
  local PlayTime = self.GeometryCache:GetDuration()
  self.GeometryCache:SetPlaybackSpeed(self.GrowUpSpeed)
  self.GeometryCache:Play()
  _G.DelayManager:DelaySeconds(PlayTime / self.GrowUpSpeed, self.OnFinishGrow, self)
end

function BP_NPCSaplingBase_C:OnFinishGrow()
  self.bIsSeeding = false
  self:LoadAllFruits()
end

function BP_NPCSaplingBase_C:CacheCreatedNPC(fruit)
  local Index = self:GetNextFruitTransform()
  local RelativeLocation = self.RandomLocations[Index]
  local WorldLocation = UE4.UKismetMathLibrary.TransformLocation(self:Abs_GetTransform(), RelativeLocation)
  fruit:ReportPosition()
  self.CachedFruits[WorldLocation] = fruit
end

function BP_NPCSaplingBase_C:SetCreatedNPC(fruit, location)
  self.sceneCharacter:SetNotDestroyFlag(false)
  if not fruit.viewObj then
    fruit:CreateView(false)
  end
  local fruitObj = fruit.viewObj
  if location then
    fruitObj:Mount(location)
    fruit:ReportPosition()
  end
  fruitObj.needTick = false
  fruitObj:OnFrameLoad(fruit:GetDistanceRatio())
end

function BP_NPCSaplingBase_C:LoadAllFruits()
  for location, fruit in pairs(self.CachedFruits) do
    self:SetCreatedNPC(fruit, location)
  end
end

function BP_NPCSaplingBase_C:GetNextFruitTransform()
  local Index = 1
  while self.UsedLocation[Index] do
    Index = Index + 1
  end
  self.UsedLocation[Index] = true
  return Index
end

return BP_NPCSaplingBase_C
