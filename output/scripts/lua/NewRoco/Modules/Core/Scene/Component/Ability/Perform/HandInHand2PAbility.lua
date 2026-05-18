local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local LinkBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerLinkBuff")
local HandInHand2PAbility = Base:Extend("HandInHand2PAbility")

function HandInHand2PAbility:Init(AbilityConf)
  Base.Init(self, AbilityConf)
end

function HandInHand2PAbility:Start(onFinished, customParams)
  local player = self.caster
  Log.Debug("HandInHand2PAbility:Start")
  local hasStatus = player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
  if not hasStatus then
    self.caster:SendEvent(PlayerModuleEvent.ON_HANDINHAND, false)
    if player.isLocal then
      _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_HOLD_HANDS_GUEST)
    end
    self.caster.buffComponent:RemoveBuff(LinkBuff.BuffName)
  else
    self.caster:SendEvent(PlayerModuleEvent.ON_HANDINHAND, true)
    if player.isLocal then
      _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_HOLD_HANDS_GUEST)
    end
    self.caster.buffComponent:AddBuff(LinkBuff.BuffName, LinkBuff, self.caster, customParams, ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
  end
end

function HandInHand2PAbility:Recover(owner, customParams)
  Log.Debug("HandInHand2PAbility:Recover")
  if owner then
    if owner.isLocal then
      if owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P) then
        owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
      end
      owner.buffComponent:RemoveBuff(LinkBuff.BuffName)
      _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_HOLD_HANDS_GUEST)
      owner:SendEvent(PlayerModuleEvent.ON_HANDINHAND, false)
    else
      if customParams and customParams.player_interact_param then
        local otherPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GetPlayerByUin, customParams.player_interact_param.player_uin1)
        if otherPlayer and otherPlayer.isLocal and not otherPlayer.statusComponent:IsInTogetherTeleport() then
          Log.Debug("HandInHand2PAbility:Recover otherPlayer is local")
          return
        end
      end
      self:Start(nil, customParams)
    end
  end
end

return HandInHand2PAbility
