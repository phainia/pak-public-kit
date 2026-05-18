local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local LinkBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerLinkBuff")
local HandInHandAbility = Base:Extend("HandInHandAbility")

function HandInHandAbility:Init(AbilityConf)
  Base.Init(self, AbilityConf)
end

function HandInHandAbility:Start(onFinished, customParams)
  local player = self.caster
  if player and player.IsMagicReplayActor and player:IsMagicReplayActor() then
    return
  end
  local hasStatus = player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
  if hasStatus then
    player.buffComponent:AddBuff(LinkBuff.BuffName, LinkBuff, player, customParams, ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
    if player.isLocal then
      _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_HOLD_HANDS_LEADER)
    end
    self.caster:SendEvent(PlayerModuleEvent.ON_HANDINHAND, true)
  else
    player.buffComponent:RemoveBuff(LinkBuff.BuffName)
    if player.isLocal then
      _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_HOLD_HANDS_LEADER)
    end
    self.caster:SendEvent(PlayerModuleEvent.ON_HANDINHAND, false)
  end
end

function HandInHandAbility:Recover(owner, customParams)
  Log.Debug("HandInHandAbility:Recover")
  if owner then
    if owner.IsMagicReplayActor and owner:IsMagicReplayActor() then
      return
    end
    if owner.isLocal then
      if owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND) then
        owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
      end
      owner.buffComponent:RemoveBuff(LinkBuff.BuffName)
      _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_HOLD_HANDS_LEADER)
      owner:SendEvent(PlayerModuleEvent.ON_HANDINHAND, false)
    else
      if customParams and customParams.player_interact_param then
        local otherPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GetPlayerByUin, customParams.player_interact_param.player_uin2)
        if otherPlayer and otherPlayer.isLocal and not otherPlayer.statusComponent:IsInTogetherTeleport() then
          Log.Debug("HandInHandAbility:Recover otherPlayer is local")
          return
        end
      end
      self:Start(nil, customParams)
    end
  end
end

return HandInHandAbility
