local InteractionComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.InteractionComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local Base = require("NewRoco.Modules.Core.Scene.Actor.SceneNpc")
local HomeSceneNPC = Base:Extend("HomeSceneNPC")

function HomeSceneNPC:Ctor(Module, FurnitureID)
  Base.Ctor(self, Module)
  if not FurnitureID then
    Log.Error("HomeSceneNPC:Ctor, FurnitureID is nil!!!")
  end
  self.FurnitureID = FurnitureID
  self.HomeStatus = HomeEnum.FURNITURE_NPC_STATE.Free
  self.SenseExtent = {}
  self.SenseDisable = {}
  self.ValidExitPoint = nil
  self:OnAddEventListener()
end

function HomeSceneNPC:OnAddEventListener()
end

function HomeSceneNPC:CreateView()
  if self.viewObj then
    Log.Error("HomeSceneNPC:CreateView, \229\175\185\229\183\178\231\187\143\229\173\152\229\156\168view\231\154\132npc\229\143\141\229\164\141\229\136\155\229\187\186view")
    return
  end
  if self.FurnitureID then
    self.module.FurnitureNPC[self.FurnitureID] = self
    local View = self.module.FurnitureView[self.FurnitureID]
    if View then
      self:SetViewObj(View)
      if self.luaObj then
        self.luaObj:SetViewObj(View)
      end
      View:BindSceneVirtualNPC(self)
      self:SetVisibleInternal(0 == self.hiddenFlag)
      self:SetCollisionInternal(0 == self.collisionDisableFlag)
      self:CalSquaredDis2Local()
      self:InitInteractGrid()
    end
  end
end

function HomeSceneNPC:UpdateByDistance(DeltaTime)
  self:CalSquaredDis2Local()
  self:InvokeEnabledComponents("UpdateByDistance", DeltaTime)
end

function HomeSceneNPC:ScheduleNextTick(Interval)
  return
end

function HomeSceneNPC:InitInteractGrid()
  self.SenseExtent = {}
  self.SenseDisable = {}
  self.ValidExitPoint = nil
  if not self.viewObj then
    return
  end
  local InteractData = self.viewObj.InteractData
  if not InteractData then
    return
  end
  local WorldTransform = self.viewObj.PropsData:Abs_GetTransform()
  local SenseData = InteractData.SenseData
  if SenseData then
    Log.Debug("====HomeSceneNPC======InitInteractGrid======", self.config.name, self.viewObj.PropsData.Id, self.viewObj.PropsData.Location)
    for _, Data in tpairs(SenseData) do
      local Pos = WorldTransform:TransformPositionNoScale(Data.Location)
      local Scale = Data.Scale
      local Box = {}
      for x = -1, 1, 2 do
        for y = -1, 1, 2 do
          for z = -1, 1, 2 do
            table.insert(Box, WorldTransform:TransformPositionNoScale(Pos + UE4.FVector(Scale.X * x, Scale.Y * y, Scale.Z * z)))
          end
        end
      end
      local MinPoint = UE4.FVector(Box[1].X, Box[1].Y, Box[1].Z)
      local MaxPoint = UE4.FVector(Box[1].X, Box[1].Y, Box[1].Z)
      for i = 2, #Box do
        MinPoint = UE4.FVector(math.min(MinPoint.X, Box[i].X), math.min(MinPoint.Y, Box[i].Y), math.min(MinPoint.Z, Box[i].Z))
        MaxPoint = UE4.FVector(math.max(MaxPoint.X, Box[i].X), math.max(MaxPoint.Y, Box[i].Y), math.max(MaxPoint.Z, Box[i].Z))
      end
      self.SenseExtent[Pos] = UE4.FVector((MaxPoint.X - MinPoint.X) / 2, (MaxPoint.Y - MinPoint.Y) / 2, (MaxPoint.Z - MinPoint.Z) / 2)
    end
  end
end

return HomeSceneNPC
