local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleRoundSelectMarkerManager = require("NewRoco.Modules.Core.Battle.BattleRoundSelectMarkerManager")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local ProtoEnum = require("Data.PB.ProtoEnum")
local BattleEvolutionSelectAction = BattleActionBase:Extend("BattleEvolutionSelectAction")
FsmUtils.MergeMembers(BattleActionBase, BattleEvolutionSelectAction, {})

function BattleEvolutionSelectAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.battleManager = _G.BattleManager
  self.evolutionData = nil
  self.BattlePet = nil
  self.skillObj = nil
  self.IsEvolution = false
  self.IsPauseEvolution = false
  self:SetActionType(BattleActionBase.ActionType.ClientPlayerSelectAction)
end

function BattleEvolutionSelectAction:OnEnter()
  self.fsm:Pause()
  self.needStop = false
  NRCModuleManager:DoCmd(BattleUIModuleCmd.HideMain)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.Open_Battle_Evolution_Select)
  self:AddListeners()
  self.evolutionData = self.battleManager.battleRuntimeData.evolutionData
  self:PlayEmotionAnimation()
  self:Glow(true)
end

function BattleEvolutionSelectAction:SendEvolutionReq()
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = ProtoEnum.BATTLE_REQ_TYPE.CMD_EVOLUTION
  _G.BattleNetManager:SendBattleCmdPushbackReq(req, self, self.OnEvolutionSent)
  self:Finish()
end

function BattleEvolutionSelectAction:OnEvolutionSent()
end

function BattleEvolutionSelectAction:Glow(Play)
  if self.evolutionData then
    for i, data in ipairs(self.evolutionData) do
      if data then
        local pet = self.battleManager.battlePawnManager:GetPetByGuid(data.pet_id)
        if pet and pet.model then
          pet.battlePetComponents:IsShowPetEvolutionBubbleUI(true)
          self:PlayEvoWaitSkill(pet)
        end
      end
    end
  end
end

function BattleEvolutionSelectAction:PlayEvoWaitSkill(battlePet)
  self.BattlePet = battlePet
  local skillClass = _G.BattleResourceManager:LoadUClass(BattleConst.Evolution.PetEvolutionWait)
  local model = battlePet.model
  if skillClass and model then
    self.skillObj = model.RocoSkill:FindOrAddSkillObj(skillClass)
    if self.skillObj then
      self.skillObj:SetCaster(model)
      self.skillObj:SetPassive(true)
      model.RocoSkill:PlaySkill(self.skillObj)
    end
  end
end

function BattleEvolutionSelectAction:AddListeners()
  _G.BattleEventCenter:Bind(self, BattleEvent.EVOLUTION_CONFIRM, BattleEvent.EVOLUTION_PAUSE)
end

function BattleEvolutionSelectAction:RemoveListeners()
  _G.BattleEventCenter:UnBind(self)
end

function BattleEvolutionSelectAction:CancelEvolutionSkill()
  if self.BattlePet then
    local model = self.BattlePet.model
    if model and self.skillObj then
      model.RocoSkill:CancelSkill(self.skillObj, UE4.ESkillActionResult.SkillActionResultSuccessful)
    end
  end
end

function BattleEvolutionSelectAction:OnFinish()
  if self.IsEvolution or self.IsPauseEvolution then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.Close_Battle_Evolution_Select)
    self.IsEvolution = false
    self.IsPauseEvolution = false
  end
  if self.BattlePet and self.BattlePet.battlePetComponents then
    self.BattlePet.battlePetComponents:IsShowPetEvolutionBubbleUI(false)
  end
  self:CancelEvolutionSkill()
  self.needStop = true
  self.fsm:Resume()
  self.BattlePet = nil
  self.skillObj = nil
  self:RemoveListeners()
  self.evolutionData = nil
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function BattleEvolutionSelectAction:PlayEmotionAnimation()
  if self.needStop == false and self.evolutionData then
    local EmoteDuration = 2
    for i, data in ipairs(self.evolutionData) do
      if data then
        local pet = self.battleManager.battlePawnManager:GetPetByGuid(data.pet_id)
        if pet and pet.model and pet.model.RocoAnim then
          local Anim = pet.model.RocoAnim:GetAnimSequenceByName("Alert")
          if Anim then
            EmoteDuration = Anim:GetPlayLength()
          end
          pet:PlayAnimByName("Alert")
        end
      end
    end
    local RandTime = math.random(2, 5)
    self.DelayId = _G.DelayManager:DelaySeconds(EmoteDuration * RandTime, self.PlayEmotionAnimation, self)
  end
end

function BattleEvolutionSelectAction:OnExit()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.Close_Battle_Evolution_Select)
  self.evolutionData = nil
end

function BattleEvolutionSelectAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.EVOLUTION_CONFIRM then
    self.IsEvolution = true
    self:SendEvolutionReq()
    return true
  elseif eventName == BattleEvent.EVOLUTION_PAUSE then
    self.IsPauseEvolution = true
    self:SendPauseEvolutionReq()
    return true
  end
end

function BattleEvolutionSelectAction:SendPauseEvolutionReq()
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = ProtoEnum.BATTLE_REQ_TYPE.CMD_EVOLUTION
  local battleRoundFlowReq = {}
  battleRoundFlowReq.req_type = ProtoEnum.BATTLE_REQ_TYPE.CMD_EVOLUTION
  battleRoundFlowReq.evolution = {pause_evolute = true}
  table.insert(req.req, battleRoundFlowReq)
  _G.BattleNetManager:SendBattleCmdPushbackReq(req, self, self.OnPauseEvolutionSent)
  self:Finish()
end

function BattleEvolutionSelectAction:OnPauseEvolutionSent()
end

return BattleEvolutionSelectAction
