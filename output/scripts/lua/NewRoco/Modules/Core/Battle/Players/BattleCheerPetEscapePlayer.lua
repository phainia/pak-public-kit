local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleCheerPetEscapePlayer = BattlePlayerBase:Extend()

function BattleCheerPetEscapePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattleCheerPetEscapePlayer:Play(performNode)
  self.isPlaying = true
  self.performNode = performNode
  self.performInfo = performNode:GetInfo()
  self.escapeInfo = self.performInfo.pet_escape
  self.escapePet = self.PawnManager:GetPetByGuid(self.escapeInfo.pet_id)
  self:PlayEscape()
end

function BattleCheerPetEscapePlayer:ShowPopup()
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
    BattleEnum.InfoPopupType.CheerPetEscape,
    self.escapePet
  }, self)
end

function BattleCheerPetEscapePlayer:PlayEscape()
  local skillClass = BattleSkillManager:GetLoadedClass(_G.DataConfigManager:GetBattleGlobalConfig("1vn_escape_res").str)
  if skillClass and self.escapePet then
    local Skill = self.escapePet.model.RocoSkill:AddSkillObjFromClassAndReturn(skillClass)
    Skill:SetCaster(self.escapePet.model):SetTargets({
      self.escapePet.model
    }):RegisterEventCallback("End", self, self.SkillComplete):RegisterEventCallback("PreEnd", self, self.SkillComplete):RegisterEventCallback("Interrupt", self, self.SkillComplete)
    local activeSkill = self.escapePet.model.RocoSkill:GetActiveSkill()
    if activeSkill then
      self.escapePet.model.RocoSkill:CancelSkill(activeSkill, UE4.ESkillActionResult.SkillActionResultInterrupted)
    end
    self.escapePet.model.RocoSkill:LoadAndPlaySkill(Skill)
    self:ShowPopup()
  else
    self:SkillComplete()
  end
end

function BattleCheerPetEscapePlayer:Reset()
  self.escapePet = nil
  self.escapeInfo = nil
  self.performNode = nil
  self.performInfo = nil
  self.isPlaying = false
end

function BattleCheerPetEscapePlayer:HidePopup()
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, nil, self)
end

function BattleCheerPetEscapePlayer:SkillComplete()
  local pet = self.escapePet
  self.escapePet = nil
  if pet then
    pet.card:SetInBattleField(false)
    _G.BattleEventCenter:Dispatch(BattleEvent.CHEER_ESCAPE, pet)
    pet:Destroy()
  end
  if self.isPlaying then
    self:HidePopup()
    self.performNode:PerformComplete()
    self:Reset()
  end
end

return BattleCheerPetEscapePlayer
