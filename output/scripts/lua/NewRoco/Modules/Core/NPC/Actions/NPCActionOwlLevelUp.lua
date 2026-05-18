local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionOwlLevelUp = Base:Extend("NPCActionOwlLevelUp")

function NPCActionOwlLevelUp:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
end

function NPCActionOwlLevelUp:Execute(playerId, needSendReq)
  local OwnerView = self:GetOwnerNPCView()
  if OwnerView then
    OwnerView:SetSkillPlaying(true)
  end
  Base.Execute(self, playerId, needSendReq)
  if UE4.UObject.IsValid(OwnerView) then
    local levelUpSkillPath = UE4.UNRCStatics.GetSoftObjPath(OwnerView.LevelUpSkill)
    levelUpSkillPath = levelUpSkillPath .. "_C"
    _G.NRCResourceManager:LoadResAsync(self, levelUpSkillPath, 1, 0, self.LoadSkillSuccess, self.LoadSkillFailed, self.Noop)
  end
end

function NPCActionOwlLevelUp:LoadSkillSuccess(req, skillClass)
  local OwnerView = self:GetOwnerNPCView()
  local SkillComp = OwnerView and OwnerView.RocoSkill
  if not SkillComp then
    self:Finish(false)
    return
  end
  if not skillClass then
    self:Finish(false)
    return
  end
  OwnerView:SetSkillPlaying(true)
  local Skill = SkillComp:FindOrAddSkillObj(skillClass)
  Skill:SetCaster(OwnerView)
  Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("Nourish", self, self.PlayNourish)
  Skill:RegisterEventCallback("Interrupt", self, self.OnSkillInterrupt)
  SkillComp:LoadAndPlaySkill(Skill)
end

function NPCActionOwlLevelUp:PlayNourish(Name, Skill)
  local CasterView = Skill:GetCaster()
  if CasterView and CasterView.Nourish_Big then
    CasterView:Nourish_Big()
  end
end

function NPCActionOwlLevelUp:OnSkillEnd(Name, Skill)
  local OwnerView = self:GetOwnerNPCView()
  if OwnerView then
    OwnerView:SetSkillPlaying(false)
  end
  self:Finish(true)
end

function NPCActionOwlLevelUp:LoadSkillFailed(req, message)
  Log.Error("\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165\228\186\134")
  self:Finish(false)
end

function NPCActionOwlLevelUp:Noop()
end

function NPCActionOwlLevelUp:Finish(success, data, param)
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdOpenOwlLevelUpTips)
  Base.Finish(self, success, data, param)
end

function NPCActionOwlLevelUp:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
end

function NPCActionOwlLevelUp:OnSkillInterrupt()
  local OwnerView = self:GetOwnerNPCView()
  if OwnerView then
    OwnerView:SetSkillPlaying(false)
    OwnerView:OnLevelChanged()
  end
  self:Finish(false)
end

function NPCActionOwlLevelUp:PostOnCommit(rsp)
  if 0 == rsp.ret_info.ret_code then
    local OwnerView = self:GetOwnerNPCView()
    if OwnerView then
      OwnerView:UpdateBigMapData()
    end
  end
end

return NPCActionOwlLevelUp
