local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenActionBase")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local HiddenActionTrail = Base:Extend("HiddenActionTrail")
local SkillPath_Trail_End = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_TrailEnd"

function HiddenActionTrail:Ctor()
  self.laterUpdateVis = nil
end

function HiddenActionTrail:Init(comp)
  Base.Init(self, comp)
  self.owner.bDisappearPerform = false
  self.owner.DisappearSkillPath = SkillPath_Trail_End
  self.owner:SetHidden(true)
end

function HiddenActionTrail:OnInitialHide()
  self:TeleToPlayer()
  self:SetVisibility(false)
  self.laterUpdateVis = true
end

function HiddenActionTrail:OnHidden()
  self:TeleToPlayer()
  self:SetVisibility(true)
  a.task(function()
    self.owner.AIComponent:ForceLock(true)
    a.wait(au.DelaySeconds(self.owner:PlayAnim("TrailingAppear")))
    if not self.comp then
      return
    end
    self.owner.AIComponent:ForceLock(false)
    self.comp:EnterHidden(AIDefines.ActionResult.Success)
  end)()
end

function HiddenActionTrail:AssureHidden(imme)
  if imme then
    self:TeleToPlayer()
    if self.laterUpdateVis ~= nil then
      self:SetVisibility(self.laterUpdateVis)
      self.laterUpdateVis = nil
    end
    a.task(function()
      self.owner.AIComponent:ForceLock(true)
      a.wait(au.DelaySeconds(self.owner:PlayAnim("TrailingAppear")))
      if not self.comp then
        return
      end
      self.owner.AIComponent:ForceLock(false)
    end)()
  end
end

function HiddenActionTrail:OnUnhidden()
  a.task(function()
    self.owner.AIComponent:ForceLock(true)
    a.wait(au.DelaySeconds(self.owner:PlayAnim("TrailingDisappear")))
    if not self.comp then
      return
    end
    self.owner.AIComponent:ForceLock(false)
    self.comp:FinalizeHidden(AIDefines.ActionResult.Success)
    self:OnVisibilityChange(false)
  end)()
end

function HiddenActionTrail:AssureUnhidden(imme)
  if imme then
    self:OnVisibilityChange(false)
  end
end

function HiddenActionTrail:EnablePinToGround()
  return false
end

function HiddenActionTrail:OnVisibilityChange(visible)
  if not self.comp then
    return
  end
  local trailing = self.comp.State ~= self.comp.State.Idle
  if visible and trailing then
    self:SetVisibility(true)
  else
    self:SetVisibility(false)
  end
end

function HiddenActionTrail:SetVisibility(visible)
  self.owner:SetHidden(not visible)
  self.owner:SetCollisionDisable(not visible, 4)
end

function HiddenActionTrail:TeleToPlayer()
  local targetTrans = self:GetPlayerBackTrans()
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), targetTrans.Translation, 20, 5, UE4.FLinearColor(1.0, 1.0, 0.2, 1), 10, 5)
  end
  local navPoint, result = UE.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(self.owner.viewObj, targetTrans.Translation)
  if result then
    targetTrans.Translation = navPoint + UE.FVector(0, 0, self.owner:GetScaledHalfHeight())
  end
  if self.owner.viewObj then
    self.owner.viewObj:Abs_K2_SetActorTransform_WithoutHit(targetTrans, false, false)
  else
    self.owner.serverPos = targetTrans.Translation
  end
end

local OffsetTransform = UE.FTransform()
OffsetTransform.Translation.X = -300

function HiddenActionTrail:GetPlayerBackTrans()
  local player = self.comp:GetPlayerContext()
  local playerTrans
  if nil == player then
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    playerTrans = localPlayer:GetActorTransformFrameCache()
  else
    playerTrans = player:GetActorTransform()
  end
  return OffsetTransform * playerTrans
end

return HiddenActionTrail
