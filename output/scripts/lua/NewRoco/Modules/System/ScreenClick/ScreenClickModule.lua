local ScreenClickModule = NRCModuleBase:Extend("ScreenClickModule")
local ViewportPos = UE4.FVector2D()

function ScreenClickModule:OnConstruct()
  Log.Debug("ScreenClickModule:OnConstruct")
  _G.ScreenClickModuleCmd = reload("NewRoco.Modules.System.ScreenClick.ScreenClickModuleCmd")
  self.normalInstance = 3
  self.VFXs = {}
  self.VFXs_Ref = {}
  self.ExpandVFXs = {}
  self.bLoadVFXFinished = false
  self.FxLoader = nil
end

function ScreenClickModule:OpenMainPanel()
end

function ScreenClickModule:OnActive()
  _G.NRCEventCenter:RegisterEvent("ScreenClickModule", self, _G.NRCGlobalEvent.OnScreenClick, self.HandleScreenClick)
  self:Init()
end

function ScreenClickModule:OnRelogin()
end

function ScreenClickModule:OnDeactive()
  self:DestructClickVFX()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnScreenClick, self.HandleScreenClick)
end

function ScreenClickModule:OnDestruct()
end

function ScreenClickModule:Init()
  Log.Debug("InitClickVFX")
  self.FxLoader = _G.NRCResourceManager:LoadResAsync(self, UEPath.SCENE_CLICK_VFX, 0, 999999999, function(Caller, Request, Res)
    for i = 1, self.normalInstance do
      self.VfxClass = Res
      self.VfxClassRef = Res and UnLua.Ref(Res)
      local VFX = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), Res)
      VFX:SetVisibility(UE4.ESlateVisibility.Collapsed)
      table.insert(self.VFXs, VFX)
      table.insert(self.VFXs_Ref, UnLua.Ref(VFX))
    end
    self.bLoadVFXFinished = true
  end, self.OnLoadFailed)
end

function ScreenClickModule:HandleScreenClick(location)
  if self.bLoadVFXFinished == false then
    return
  elseif self.bLoadVFXFinished == true then
    for _, VFX in ipairs(self.VFXs) do
      if UE4.UObject.IsValid(VFX) then
        VFX:AddToViewport(_G.UILayerCtrlCenter.ENUM_LAYER.SCREEN_CLICK_VFX, false)
      end
    end
    self.bLoadVFXFinished = nil
  end
  self:JudgeNeedExpand()
  for _, VFX in ipairs(self.VFXs) do
    if VFX and UE4.UObject.IsValid(VFX) and not VFX:IsPlaying() then
      UE4.USlateBlueprintLibrary.AbsoluteToViewport(_G.UE4Helper.GetCurrentWorld(), location, nil, ViewportPos)
      local scale = UE4.UWidgetLayoutLibrary.GetViewportScale(_G.UE4Helper.GetCurrentWorld())
      ViewportPos.X = (ViewportPos.X - 10) * scale
      ViewportPos.Y = (ViewportPos.Y - 10) * scale
      VFX:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      VFX:SetPositionInViewport(ViewportPos)
      VFX:PlayClickAnimation()
      break
    end
  end
end

function ScreenClickModule:JudgeNeedExpand()
  for i, VFX in ipairs(self.VFXs) do
    if VFX and UE4.UObject.IsValid(VFX) then
      if not VFX:IsPlaying() then
        return VFX
      end
      if i == #self.VFXs then
        local VFX = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), self.VfxClass)
        VFX:SetVisibility(UE4.ESlateVisibility.Collapsed)
        table.insert(self.VFXs, VFX)
        table.insert(self.VFXs_Ref, UnLua.Ref(VFX))
        return VFX
      end
    end
  end
end

function ScreenClickModule:DestructClickVFX()
  for _, VFX in ipairs(self.VFXs) do
    if VFX then
      VFX:RemoveFromParent()
    end
  end
  table.clear(self.VFXs)
  table.clear(self.VFXs_Ref)
end

function ScreenClickModule:OnLoadFailed(Request, Message)
  Log.Warning("amonsu:ScreenClickModule \233\162\132\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165", Message)
  _G.NRCResourceManager:UnLoadRes(Request)
end

return ScreenClickModule
