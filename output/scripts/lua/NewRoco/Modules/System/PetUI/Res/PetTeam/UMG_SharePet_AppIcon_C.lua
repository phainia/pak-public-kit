local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SharePet_AppIcon_C = Base:Extend("UMG_SharePet_AppIcon_C")

function UMG_SharePet_AppIcon_C:OnConstruct()
end

function UMG_SharePet_AppIcon_C:OnDestruct()
end

function UMG_SharePet_AppIcon_C:OnItemUpdate(_data, datalist, index)
  if _data.path then
    self.Icon:SetPath(_data.path)
  end
  self.index = index
  self.caller = _data.caller
  self.callback = _data.callback
  self.way = _data.way
end

function UMG_SharePet_AppIcon_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_SharePet_AppIcon_C:OnItemSelected")
    local caller = self.caller
    local callback = self.callback
    if not callback then
      return
    end
    if caller then
      if self.way then
        callback(caller, self.way)
      else
        callback(caller)
      end
    end
  end
end

function UMG_SharePet_AppIcon_C:OnTouchStarted(MyGeometry, InTouchEvent)
  _G.NRCEventCenter:RegisterEvent("UMG_PetImage3D_C", self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
  self:PlayAnimation(self.Press)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_SharePet_AppIcon_C:OnDeactive()
end

function UMG_SharePet_AppIcon_C:OnConstruct()
end

function UMG_SharePet_AppIcon_C:OnDestruct()
end

function UMG_SharePet_AppIcon_C:OnRocoTouchEndHandler(MyGeometry, InTouchEvent)
  self:PlayAnimation(self.Up)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
end

return UMG_SharePet_AppIcon_C
