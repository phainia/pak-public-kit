local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenActionBase")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local HiddenPluginFx = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginFx")
local HiddenPluginSkill = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginSkill")
local SkillPath_WAT_Idle = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_Idle.Pet_Hide_Water_Idle_C'"
local SkillPath_WAT_Alpha = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_Alpha.Pet_Hide_Water_Alpha_C'"
local SkillPath_WAT_End = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_End.Pet_Hide_Water_End_C'"
local FxPath_WAT_Run = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/hide/NR_Hide_Water_Run.NR_Hide_Water_Run'"
local HiddenActionDiving = Base:Extend("HiddenActionDiving")

function HiddenActionDiving:Ctor()
  self:OnPreparePlugin()
end

function HiddenActionDiving:OnPreparePlugin()
  self.IdleSkill = HiddenPluginSkill(SkillPath_WAT_Idle, true, true)
  self.AlphaSkill = HiddenPluginSkill(SkillPath_WAT_Alpha, true, true)
  self.RunFx = HiddenPluginFx(FxPath_WAT_Run, true, true)
end

function HiddenActionDiving:Init(comp)
  Base.Init(self, comp)
  self.cachedSwimPosOffsetZ = nil
  self.diving = false
  self:OnInitPlugin(comp.owner)
end

function HiddenActionDiving:OnInitPlugin(owner)
  self.IdleSkill:Init(owner)
  self.AlphaSkill:Init(owner)
  self.RunFx:Init(owner)
end

function HiddenActionDiving:Release()
  self:OnReleasePlugin()
  Base.Release(self)
end

function HiddenActionDiving:OnReleasePlugin()
  self.IdleSkill:Release()
  self.AlphaSkill:Release()
  self.RunFx:Release()
end

function HiddenActionDiving:OnHidden()
  local result = true
  local char = self.owner.viewObj
  local moveComp = char.GetMovementComponent and char:GetMovementComponent() or nil
  if moveComp then
    local bSwimming = moveComp.MovementMode == UE.EMovementMode.MOVE_Swimming
    if bSwimming then
      result = false
    end
  end
  if result and not self.diving then
    self:OnDivingDown()
    a.task(function()
      a.wait(au.DelaySeconds(0.5))
      self:UpdateDiveDepth(-1 * self:GetCurrentWaterDepth())
    end)()
    self:SetSwimFxEnable(false)
    self.diving = true
  end
  self.comp:EnterHidden(result and AIDefines.ActionResult.Success or AIDefines.ActionResult.Failed)
end

function HiddenActionDiving:AssureHidden(imme)
  if not self.diving then
    self:UpdateDiveDepth(-1 * self:GetCurrentWaterDepth())
    self:SetSwimFxEnable(false)
    self.diving = true
  end
end

function HiddenActionDiving:OnUnhidden()
  local result = true
  if self.diving then
    self:OnDivingUp()
    result = self:ResetDiveDepth()
    self:SetSwimFxEnable(true)
    self.diving = false
  end
  self.comp:FinalizeHidden(result and AIDefines.ActionResult.Success or AIDefines.ActionResult.Failed)
end

function HiddenActionDiving:AssureUnhidden(imme)
  if self.diving then
    self:ResetDiveDepth()
    self:SetSwimFxEnable(true)
    self.diving = false
    if imme then
      self:OnDivingUp(true)
    end
  end
end

function HiddenActionDiving:EnablePinToGround()
  return false
end

function HiddenActionDiving:UpdateDiveDepth(newDepth)
  local model = self.owner and self.owner:GetViewObject()
  if not model then
    return false
  end
  local moveComp = model:GetMovementComponent()
  if not moveComp then
    return false
  end
  if not self.cachedSwimPosOffsetZ then
    self.cachedSwimPosOffsetZ = moveComp.AdditionalSwimPosOffsetZ
  end
  moveComp:SetAdditionalSwimPosOffsetZ(self.cachedSwimPosOffsetZ + (newDepth or 0))
  return true
end

function HiddenActionDiving:ResetDiveDepth()
  local model = self.owner:GetViewObject()
  if not model then
    return false
  end
  local moveComp = model:GetMovementComponent()
  if not moveComp then
    return false
  end
  moveComp:SetAdditionalSwimPosOffsetZ(self.cachedSwimPosOffsetZ)
  return true
end

function HiddenActionDiving:GetCurrentWaterDepth()
  return 80
end

function HiddenActionDiving:SetSwimFxEnable(flag)
  if not self.owner then
    return
  end
  local model = self.owner:GetViewObject()
  if not model then
    return
  end
  local moveFxComp = model.MoveFXComponent
  if not moveFxComp then
    return
  end
  moveFxComp.enableSwimFx = flag
end

function HiddenActionDiving:OnDivingDown()
  self.AlphaSkill:Show()
  a.task(function()
    a.wait(au.DelaySeconds(0.7))
    self.RunFx:Show()
  end)()
end

function HiddenActionDiving:OnDivingUp(imme)
  self.IdleSkill:Show()
  self.RunFx:UnShow()
end

return HiddenActionDiving
