local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local LocalPlayerHUDComponent = Base:Extend("LocalPlayerHUDComponent")

function LocalPlayerHUDComponent:PreCtor()
  Base.PreCtor(self)
  self._playerHeadHud = nil
  self._headWidgetTrans = nil
end

function LocalPlayerHUDComponent:Attach(owner)
  Base.Attach(self, owner)
end

function LocalPlayerHUDComponent:OnSetViewObj()
  Base.OnSetViewObj(self)
  local viewObj = self.owner.viewObj
  if viewObj then
    local headWidget = viewObj.LocalHeadWidget
    if headWidget then
      self._playerHeadHud = headWidget:GetUserWidgetObject()
      self._headWidgetTrans = headWidget:GetRelativeTransform()
    end
  end
end

local DefaultOffset = UE.FVector(0, 0, 60)
local HeadTransformCache = UE4.FTransform()

function LocalPlayerHUDComponent:AdjustHudAfterDoubleRiding(addOffset)
  UE.UNRCCharacterUtils.AdjustHeadWidgetOffset(self.owner.viewObj, addOffset or DefaultOffset, HeadTransformCache, "Bip001-Head")
  self._debugHeadPos = HeadTransformCache.Translation
end

function LocalPlayerHUDComponent:RestoreHudAfterDoubleRiding()
  self._debugHeadPos = nil
  if not self._headWidgetTrans then
    return
  end
  local viewObj = self.owner.viewObj
  if not viewObj or not UE.UObject.IsValid(viewObj) then
    return
  end
  local playerHeadWidget = viewObj.LocalHeadWidget
  if not playerHeadWidget or not UE.UObject.IsValid(playerHeadWidget) then
    return
  end
  playerHeadWidget:AdjustTransform(self._headWidgetTrans, UE.EAdjustTransformType.Relative_Transform)
end

function LocalPlayerHUDComponent:DeAttach()
  Base.DeAttach(self)
end

function LocalPlayerHUDComponent:Destroy()
  Base.Destroy(self)
end

return LocalPlayerHUDComponent
