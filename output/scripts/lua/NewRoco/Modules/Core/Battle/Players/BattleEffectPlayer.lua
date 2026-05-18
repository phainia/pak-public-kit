local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local EventDispatcher = require("Common.EventDispatcher")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleEffectPlayer = BattlePlayerBase:Extend()

function BattleEffectPlayer:Ctor()
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.BattleManager = _G.BattleManager
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattleEffectPlayer:Reset()
  self.team = nil
  self.player = nil
  self.target = nil
  self.effectTrigger = nil
  self.performNode = nil
end

function BattleEffectPlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.performInfo = performInfo
  self.effectTrigger = performInfo.effect_trigger
end

function BattleEffectPlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  if BattleManager.isPureLogicMode then
    self:OnFinish()
    return
  end
  local effectTrigger = self.effectTrigger
  local effect_id = effectTrigger.effect_id
  local target_pet_id = effectTrigger.target_id
  effectTrigger.params = effectTrigger.params or {}
  local result_data1 = effectTrigger.params[1]
  local result_data2 = effectTrigger.params[2]
  local effect = _G.DataConfigManager:GetEffectConf(effect_id)
  if not effect then
    Log.Error("Effect\228\184\141\229\173\152\229\156\168\239\188\140\232\175\183\231\173\150\229\136\146\230\163\128\230\159\165\228\184\128\228\184\139\233\133\141\232\161\168:", effect_id)
    self:OnFinish()
    return
  end
  Log.Debug("target_pet_id:", target_pet_id)
  local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(target_pet_id)
  local card
  if not pet then
    card = _G.BattleManager.battlePawnManager:GetCardByGuid(target_pet_id)
  else
    card = pet.card
    if (effect.effect_order == Enum.EffectType.ET_CHANGE_ENERGY or effect.effect_order == Enum.EffectType.ET_STEAL_ENERGY) and 0 ~= result_data1 then
      if result_data1 and result_data1 > 0 then
        pet.buffAEffectPopupComponent:PopupEffect(effect, result_data1)
      end
    else
      pet.buffAEffectPopupComponent:PopupEffect(effect)
    end
  end
  if not pet and not card then
    Log.ErrorFormat("HandleEffect Error, target not found: %d", target_pet_id)
    self:OnFinish()
    return
  end
  local retType = effectTrigger.result
  if effect.effect_order == Enum.EffectType.ET_SKILL_CHANGE then
    if retType == ProtoEnum.BattleEffectResultType.BERT_COPY_FAIL_NO_SKILL then
      Log.Error("\228\189\160\229\143\175\232\131\189\228\189\191\231\148\168\228\186\134\228\184\128\228\184\170\229\186\159\229\188\131\230\142\165\229\143\163\239\188\140\232\175\183\232\129\148\231\179\187lance 147")
      local skillName
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(_G.LuaText.SKILL_COPY_FAIL_NO_SKILL, skillName))
    elseif retType == ProtoEnum.BattleEffectResultType.BERT_COPY_FAIL_HAS_SKILL then
      local skillName
      Log.Error("\228\189\160\229\143\175\232\131\189\228\189\191\231\148\168\228\186\134\228\184\128\228\184\170\229\186\159\229\188\131\230\142\165\229\143\163\239\188\140\232\175\183\232\129\148\231\179\187lance 153")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(_G.LuaText.SKILL_COPY_FAIL_HAS_SKILL, self.card.config.name, skillName))
    end
    self:OnFinish()
  elseif effectTrigger.result == ProtoEnum.BattleEffectResultType.BERT_MONSTER_ESCAPE then
    BattleExitHelper.SetEnemyEscape(self.Caster, nil)
    self:OnFinish()
  elseif effect.effect_order == Enum.EffectType.ET_REVIVE_BAG_PET then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(result_data1)
    if pet then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(_G.LuaText.pet_revive_tip, pet.card.name))
    end
    self:OnFinish()
  elseif effect.effect_order == Enum.EffectType.ET_ANIMATION then
    if effect.effect_param and effect.effect_param[1] and effect.effect_param[1].params then
      local animId = effect.effect_param[1].params[1] or 0
      if self.performNode.performPlayer.turnPlayer.Cmd then
        _G.BattleEventCenter:Dispatch(BattleEvent.PlayUIAnimation, animId, card, self.performNode.performPlayer.turnPlayer.Cmd.round)
      else
        Log.Error("BattleEffectPlayer:Play cmd is nil")
      end
      self:OnFinish()
    else
      self:OnFinish()
    end
  else
    self:OnFinish()
  end
end

function BattleEffectPlayer:ClosePopup(caster)
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, caster:GetPlayer())
end

function BattleEffectPlayer:OnFinish()
  if self.performNode then
    self.performNode:PerformComplete()
  end
  self:Reset()
end

return BattleEffectPlayer
