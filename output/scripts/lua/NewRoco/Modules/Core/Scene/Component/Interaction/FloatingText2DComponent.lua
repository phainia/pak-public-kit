local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local FloatingText2DComponent = Base:Extend("HomePetAttributeComponent")
local HeightOffset = _G.DataConfigManager:GetHomeGlobalConfig("plant_water_tips_height_born", true) and _G.DataConfigManager:GetHomeGlobalConfig("plant_water_tips_height_born", true).num or 275
local MaxDistanceSquared = _G.DataConfigManager:GetHomeGlobalConfig("plant_water_no_tips_dist", true) and _G.DataConfigManager:GetHomeGlobalConfig("plant_water_no_tips_dist", true).num ^ 2 or 1000000
local CanvasHalfHeight, CanvasHalfWeight, UMGClass, AnimDuration

function FloatingText2DComponent:Ctor()
  Base.Ctor(self)
  self.FloatingTexts = setmetatable({}, {__mode = "v"})
  self.Text = nil
  self.bAutoDestroy = false
end

function FloatingText2DComponent:Attach(owner)
  Base.Attach(self, owner)
end

function FloatingText2DComponent:AddFloatingText(TextInfo, AutoDestroy)
  self.Text = TextInfo
  self.bAutoDestroy = AutoDestroy
  if UMGClass and UE4.UObject.IsValid(UMGClass) then
    self:CreateAndShowWidget()
  else
    self:InitUMG()
  end
end

function FloatingText2DComponent:InitUMG()
  _G.NRCResourceManager:LoadResAsync(self, "WidgetBlueprint'/Game/NewRoco/Modules/System/MainUI/Res/UMG_Hud_ReduceCDTime.UMG_Hud_ReduceCDTime_C'", _G.PriorityEnum.Passive_World_NPC_Important_Res, 0, self.LoadUMGCallBack, self.FailedLoadCallBack)
end

function FloatingText2DComponent:LoadUMGCallBack(_, LoadedClass)
  UMGClass = LoadedClass
  self:CreateAndShowWidget()
end

function FloatingText2DComponent:CreateAndShowWidget()
  local NewWidget = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), UMGClass)
  if not NewWidget then
    Log.Error("\229\136\155\229\187\186UMG\229\164\177\232\180\165\239\188\140\232\183\175\229\190\132\228\184\186:", getmetatable(UMGClass).__name)
    return
  end
  if not CanvasHalfHeight or not CanvasHalfWeight then
    local SizeXY = NewWidget.CanvasPanel_1.Slot:GetSize()
    CanvasHalfHeight = SizeXY.Y / 2
    CanvasHalfWeight = SizeXY.X / 2
  end
  if not AnimDuration then
    AnimDuration = NewWidget.Floating:GetStartTime() - NewWidget.Floating:GetEndTime()
    AnimDuration = math.max(0.5, AnimDuration)
  end
  NewWidget:AddToViewport(_G.UILayerCtrlCenter.ENUM_LAYER.BG)
  self:UpdateFloatingText(NewWidget)
  NewWidget:PlayAnimation(NewWidget.Floating)
  _G.DelayManager:DelaySeconds(AnimDuration, self.FinishTask, self)
  if self.Text ~= nil then
    NewWidget.RemarkName:SetText(self.Text)
    self.Text = nil
  end
  table.insert(self.FloatingTexts, NewWidget)
  _G.UpdateManager:Register(self)
end

function FloatingText2DComponent:FailedLoadCallBack()
  Log.Error("\229\136\155\229\187\186UMG\229\164\177\232\180\165\239\188\140\232\183\175\229\190\132\228\184\186:", getmetatable(UMGClass).__name)
end

function FloatingText2DComponent:DeAttach()
end

function FloatingText2DComponent:FinishTask()
  if not self.FloatingTexts then
    return
  end
  local FinishedWidget = self.FloatingTexts[1]
  if FinishedWidget and UE4.UObject.IsValid(FinishedWidget) then
    FinishedWidget:RemoveFromViewport()
    table.remove(self.FloatingTexts, 1)
  end
  if 0 == #self.FloatingTexts then
    self:CleanAll()
  end
end

function FloatingText2DComponent:CleanAll()
  _G.UpdateManager:UnRegister(self)
  for _, FloatingTextWidget in ipairs(self.FloatingTexts) do
    FloatingTextWidget:RemoveFromViewport()
  end
  table.clear(self.FloatingTexts)
  if self.bAutoDestroy then
    self.FloatingTexts = nil
    self.owner:RemoveComponent(self)
  end
end

function FloatingText2DComponent:OnTick(_)
  for _, FloatingTextWidget in ipairs(self.FloatingTexts) do
    if not UE4.UObject.IsValid(FloatingTextWidget) then
      return
    end
    self:UpdateFloatingText(FloatingTextWidget)
  end
end

local ScreenPos = UE4.FVector2D()
local ViewportPos = UE4.FVector2D()

function FloatingText2DComponent:UpdateFloatingText(FloatingTextWidget)
  if not self.owner.viewObj then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local Position = self.owner.viewObj.sceneCharacter:GetActorLocation()
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local TargetPosition = LocalPlayer:GetActorLocation()
  local DistSquared = UE4.FVector.DistSquared(Position, TargetPosition)
  if DistSquared > MaxDistanceSquared then
    FloatingTextWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  Position.Z = Position.Z + HeightOffset
  local bInScreen = UE4.UNRCStatics.Abs_ProjectWorldToScreen(UE4.UGameplayStatics.GetPlayerController(World, 0), Position, ScreenPos)
  if bInScreen then
    ScreenPos.X = ScreenPos.X - CanvasHalfWeight
    ScreenPos.Y = ScreenPos.Y - CanvasHalfHeight
    UE4.USlateBlueprintLibrary.ScreenToViewport(World, ScreenPos, ViewportPos)
    FloatingTextWidget:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    FloatingTextWidget:SetPositionInViewport(ViewportPos, false)
  else
    FloatingTextWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function FloatingText2DComponent:FixScale(FloatingTextWidget)
  local Position = self.owner.viewObj.sceneCharacter:GetActorLocation()
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local TargetPosition = LocalPlayer:GetActorLocation()
  local DistSquared = UE4.FVector.DistSquared2D(Position, TargetPosition)
  FloatingTextWidget:SetRenderScale(self:GetFake3DScale(DistSquared))
end

function FloatingText2DComponent:GetFake3DScale(DistSquared)
  local Scale = math.clamp(1 - 0.5 * (DistSquared - 0) / (MaxDistanceSquared - 0), 0.5, 1)
  return UE4.FVector2D(Scale)
end

return FloatingText2DComponent
