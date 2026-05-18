local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDiving")
local SkillPath_DIV_OffIdle = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_YuYue_WaterIdle.Pet_Hide_Water_YuYue_WaterIdle_C'"
local SkillPath_DIV_Jump = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_YuYue.Pet_Hide_Water_YuYue_C'"
local SkillPath_DIV_UponIdle = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_YuYue_Idle.Pet_Hide_Water_YuYue_Idle_C'"
local SkillPath_DIV_Down = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide_Water_YuYue_Down.Pet_Hide_Water_YuYue_Down_C'"
local FxPath_WAT_Run = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/hide/NR_Hide_Water_Run.NR_Hide_Water_Run'"
local HiddenPluginSkill = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginSkill")
local HiddenPluginFx = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginFx")
local HiddenActionDivingJump = Base:Extend("HiddenActionDivingJump")

function HiddenActionDivingJump:Release()
  if self.d_finalize then
    DelayManager:CancelDelayById(self.d_finalize)
    self.d_finalize = nil
  end
  Base.Release(self)
end

function HiddenActionDivingJump:OnPreparePlugin()
  self.OffIdleSkill = HiddenPluginSkill(SkillPath_DIV_OffIdle, true, true)
  self.JumpSkill = HiddenPluginSkill(SkillPath_DIV_Jump, true, true)
  self.UponIdleSkill = HiddenPluginSkill(SkillPath_DIV_UponIdle, true, true)
  self.DownSkill = HiddenPluginSkill(SkillPath_DIV_Down, true, true)
  self.RunFx = HiddenPluginFx(FxPath_WAT_Run, true, true)
end

function HiddenActionDivingJump:OnInitPlugin(owner)
  self.OffIdleSkill:Init(owner)
  self.JumpSkill:Init(owner)
  self.UponIdleSkill:Init(owner)
  self.DownSkill:Init(owner)
  self.RunFx:Init(owner)
end

function HiddenActionDivingJump:OnReleasePlugin()
  self.OffIdleSkill:Release()
  self.JumpSkill:Release()
  self.UponIdleSkill:Release()
  self.DownSkill:Release()
  self.RunFx:Release()
end

function HiddenActionDivingJump:OnInitialHide()
  self.OffIdleSkill:Show()
  self.RunFx:Show()
end

function HiddenActionDivingJump:OnUnhidden()
  local result = true
  local wait_time = 0
  if self.diving then
    wait_time = self:OnDivingUp()
    result = self:ResetDiveDepth()
    self:SetSwimFxEnable(true)
    self.diving = false
  end
  if 0 == wait_time then
    self.comp:FinalizeHidden(result and AIDefines.ActionResult.Success or AIDefines.ActionResult.Failed)
  else
    self.d_finalize = DelayManager:DelaySeconds(wait_time, function()
      self.comp:FinalizeHidden(result and AIDefines.ActionResult.Success or AIDefines.ActionResult.Failed)
      self.d_finalize = nil
    end)
  end
end

function HiddenActionDivingJump:OnDivingUp(imme)
  if imme then
    self.RunFx:UnShow()
    self:SetSwimFxEnable(false)
    self.UponIdleSkill:Show()
    self:SetSwimFxEnable(true)
    return 0
  end
  local time = self.owner:PlayAnim("DivingJump")
  self.RunFx:UnShow()
  self:SetSwimFxEnable(false)
  a.task(function()
    a.wait(a.wrap(self.JumpSkill.Show)(self.JumpSkill, self))
    self.UponIdleSkill:Show()
    self:SetSwimFxEnable(true)
  end)()
  return time
end

function HiddenActionDivingJump:OnDivingDown()
  self.owner:PlayAnim("DivingDown")
  a.task(function()
    self.DownSkill:Show()
    a.wait(au.DelaySeconds(0.2))
    self.OffIdleSkill:Show()
    self.RunFx:Show()
  end)()
end

return HiddenActionDivingJump
