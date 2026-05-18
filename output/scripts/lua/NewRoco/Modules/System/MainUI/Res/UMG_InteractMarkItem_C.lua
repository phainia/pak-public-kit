local MarkState = {
  Hide = 0,
  Show = 1,
  Highlight = 2
}
local Base = _G.NRCUmgClass
local UMG_InteractMarkItem_C = Base:Extend("UMG_InteractMarkItem_C")

function UMG_InteractMarkItem_C:OnConstruct()
  self.state = nil
end

function UMG_InteractMarkItem_C:OnDestruct()
  self.state = nil
end

function UMG_InteractMarkItem_C:SetNpc(npc)
  self.npc = npc
end

function UMG_InteractMarkItem_C:GetIsShown()
  if self.state == MarkState.Hide then
    return self:IsVisible()
  end
  return self.inRange
end

function UMG_InteractMarkItem_C:OnShow()
  if self.state == MarkState.Show or self.state == MarkState.Highlight then
    if not self:IsVisible() then
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:PlayAnimation(self.loop, 0, 0)
      Log.Debug("UMG_InteractMarkItem_C:OnShow if not visible", self.npc and self.npc:DebugNPCNameAndID())
    end
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
  self:PlayAnimation(self.loop, 0, 0)
end

function UMG_InteractMarkItem_C:OnHide()
  if self.state == MarkState.Hide then
    return
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
end

function UMG_InteractMarkItem_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
end

function UMG_InteractMarkItem_C:UpdateState(trackedNpcs)
  local newState = self:GetNewMarkState(trackedNpcs)
  self:SetNewState(newState)
end

function UMG_InteractMarkItem_C:SetNewState(newState)
  if newState == self.state then
    return
  end
  if newState == MarkState.Hide then
    self:OnHide()
  else
    if self.state == MarkState.Hide then
      self:OnShow()
    end
    if newState == MarkState.Show then
      self.Switcher:SetActiveWidgetIndex(0)
    elseif newState == MarkState.Highlight then
      self.Switcher:SetActiveWidgetIndex(1)
    end
  end
  self.state = newState
end

function UMG_InteractMarkItem_C:IsNpcVisible(npc)
  if not npc then
    return false
  end
  if self:IsNpcMimic(npc) then
    return true
  end
  if npc:IsHidden() then
    return false
  end
  if not npc.viewObj then
    return false
  end
  if not UE4.UNRCStatics.WasRecentlyRenderedOnScreen(npc.viewObj, 0.1) then
    return false
  end
  return true
end

function UMG_InteractMarkItem_C:IsNpcMimic(npc)
  if not npc then
    return false
  end
  local hiddenComp = npc.HiddenComponent
  if not hiddenComp then
    return false
  end
  if hiddenComp:IsHidden() and hiddenComp:IsMimicType() then
    local mimicObj = hiddenComp:GetMimicObject()
    if mimicObj and UE4.UObject.IsValid(mimicObj) and not mimicObj.bHidden then
      return true
    end
  end
  return false
end

function UMG_InteractMarkItem_C:GetNewMarkState(trackedNpcs)
  if not self.npc then
    return MarkState.Hide
  end
  if not self:IsNpcVisible(self.npc) then
    return MarkState.Hide
  end
  if not self.inRange then
    return MarkState.Hide
  end
  if trackedNpcs then
    for _, track in pairs(trackedNpcs) do
      if track then
        local searcher = track:GetSearcher()
        if searcher and searcher(track, self.npc) then
          return MarkState.Hide
        end
      end
    end
  end
  local interactionComp = self.npc.InteractionComponent
  if not interactionComp then
    return MarkState.Hide
  end
  local options = interactionComp:GetAllOptions()
  if 0 == table.len(options) then
    return MarkState.Hide
  end
  if not interactionComp:GetShouldShowMark() then
    return MarkState.Hide
  end
  for _, option in pairs(options) do
    if option.inActionArea and option.bSelected then
      return MarkState.Highlight
    end
  end
  return MarkState.Show
end

function UMG_InteractMarkItem_C:UpdatePosition(playerController, deltaTime)
  if not self:GetIsShown() then
    if self:IsVisible() then
      self.state = MarkState.Hide
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
      Log.Debug("UMG_InteractMarkItem_C:UpdatePosition IsVisible", self.npc and self.npc:DebugNPCNameAndID())
    end
    return
  end
  if not self.npc then
    return
  end
  local offsetConfig = 0
  if self.npc and self.npc.config then
    offsetConfig = self.npc.config.trace_icon_offset or 0
  end
  local actor = self.npc.viewObj
  if self:IsNpcMimic(self.npc) then
    local hiddenComp = self.npc.HiddenComponent
    if hiddenComp then
      local mimicObj = hiddenComp:GetMimicObject()
      if mimicObj then
        actor = mimicObj
      end
    end
  end
  self:UpdatePositionByActor(playerController, deltaTime, actor, offsetConfig)
end

local TempUpVector = UE4.FVector(0, 0, 1)
local TempTargetPosition = UE4.FVector(0, 0, 0)

function UMG_InteractMarkItem_C:UpdatePositionByActor(playerController, deltaTime, actor, offsetConfig)
  UE4.UNRCStatics.Abs_K2_GetActorLocationInplace(actor, TempTargetPosition)
  local offset = 0
  if actor then
    if actor.GetInteractMarkHeight then
      offset = actor:GetInteractMarkHeight()
    elseif actor.GetHalfHeight then
      offset = actor:GetHalfHeight()
    elseif actor.GetBottomAndTop then
      local originZ, extentZ = actor:GetBottomAndTop()
      local check = true
      if 0 == originZ and 0 == extentZ then
        check = false
      end
      if check then
        offset = originZ + extentZ - TempTargetPosition.Z
      end
    end
  end
  if nil == offset then
    offset = 0
  end
  offset = offset + offsetConfig or 0
  UE4.UNRCStatics.GetActorUpVectorInplace(actor, TempUpVector)
  TempTargetPosition:Set(TempTargetPosition.X + TempUpVector.X * offset, TempTargetPosition.Y + TempUpVector.Y * offset, TempTargetPosition.Z + TempUpVector.Z * offset)
  if not _G.RocoEnv.IS_SHIPPING and _G.GlobalConfig.bShouldShowDebugPetName then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(self, TempTargetPosition, 10, 10, UE4.FLinearColor(0.9, 0.1, 0, 0.9), deltaTime, 2)
  end
  if not playerController or not UE4.UObject.IsValid(playerController) then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local screenPos, result = playerController:Abs_ProjectWorldLocationToScreen(TempTargetPosition, nil, true)
  if not result then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local viewportPos = UE4.USlateBlueprintLibrary.ScreenToViewport(self, screenPos)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Slot:SetPosition(viewportPos)
end

return UMG_InteractMarkItem_C
