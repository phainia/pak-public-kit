local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local RoleHpData = require("NewRoco.Modules.System.BattleUI.Res.RoleHP.RoleHPMinItem_Data")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_Battle_RoleHp_DefeatedTipPanel_C = _G.NRCPanelBase:Extend("UMG_Battle_RoleHp_DefeatedTipPanel_C")

function UMG_Battle_RoleHp_DefeatedTipPanel_C:Construct()
  self.battleManager = _G.BattleManager
  self.uiData = {}
  self:AddListener()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:Destruct()
  self:RemoveListener()
  self.uiData = nil
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:OnActive(_param, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  self.uiData.param = _param
  if self:IsPCMode() then
    self:PCModeScreenSetting()
  end
  self:Show()
  _G.BattleEventCenter:Dispatch(BattleEvent.HIDE_HP_RED)
  NRCModeManager:DoCmd(BattleUIModuleCmd.BattleMainSetOpacity, 0)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:OnDeactive()
  _G.BattleEventCenter:Dispatch(BattleEvent.SHOW_HP_RED)
  NRCModeManager:DoCmd(BattleUIModuleCmd.BattleMainSetOpacity, 1)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.REFRESH_ROLE_HP_DEFEAT_TIP_END, BattleEvent.BattleOver)
  NRCEventCenter:RegisterEvent("UMG_Battle_RoleHp_DefeatedTipPanel_C", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
  NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:OnReconnect()
  self:DoClose()
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.REFRESH_ROLE_HP_DEFEAT_TIP_END or eventName == BattleEvent.BattleOver then
    self:Hide()
  end
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:RefreshInfo(param)
  local player = param.player
  if not player then
    return
  end
  local isLast = param.isLast
  if nil == isLast then
    return
  end
  local diePet = param.diePet
  local isShowLetter = param.isShowLetter
  local tipsKey = param.tips_key
  self:UpdateGridViewInfo(player, param)
  self:UpdateDes(player, diePet, isLast, isShowLetter, tipsKey)
  self:UpdatePVP(param)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:UpdateGridViewInfo(player, param)
  local hp_result = param.hp_result
  local hp_change = param.hp_change
  local black_hp_change = 0
  if param.black_hp_change < 0 then
    black_hp_change = -param.black_hp_change
  end
  local black_hp_result = math.abs(param.black_hp_result)
  local changeNum = 0
  if hp_change < 0 then
    changeNum = -hp_change
  end
  local fullNum = hp_result + changeNum
  local LimitHp = player.roleInfo.base.battle_hp_max or player.roleInfo.base.raw_hp
  local dataList = {}
  if nil == fullNum or fullNum < 0 then
    Log.Error("UMG_Battle_PVERoleHpShow_C: no fullNum found")
    return
  end
  local blackBase = black_hp_result + black_hp_change
  for i = 1, LimitHp do
    local info = RoleHpData(player.teamEnm, true, false, false, false)
    if i <= black_hp_result then
      info.isLock = true
    elseif i > black_hp_result and i <= blackBase then
      info.isUnlock = true
    elseif i > blackBase and i <= black_hp_result + hp_result then
    elseif i > black_hp_result + hp_result and i <= hp_result + black_hp_result + changeNum then
      info.isBroken = true
    else
      info.isFull = false
    end
    table.insert(dataList, info)
  end
  if player.teamEnm == BattleEnum.Team.ENUM_TEAM or player.teamEnm == BattleEnum.Team.ENUM_ENEMY then
    self.NRCGridView_Hp:Clear()
    self.NRCGridView_Hp:InitGridView(dataList)
  else
    return
  end
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:UpdateDes(player, diePet, isLast, isShowLetter, tipsKey)
  local cfgText = ""
  if false == isShowLetter or nil == isShowLetter then
    self.Des:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DescBackPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if player.teamEnm == BattleEnum.Team.ENUM_TEAM then
    if diePet then
      local baseID = diePet:GetPetID()
      local baseConf = _G.DataConfigManager:GetPetbaseConf(baseID)
      if 0 == baseConf.consume_role_hp then
        cfgText = _G.DataConfigManager:GetLocalizationConf("consume_hp_zero_tip_player").msg
      elseif isLast then
        if player:IsAssistNpc() and player:HasNpcId() then
          cfgText = _G.DataConfigManager:GetGlobalConfigByKeyType("battle_end_assist_hp_deduct_text", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str
        else
          cfgText = _G.DataConfigManager:GetGlobalConfigByKeyType("battle_end_role_hp_deduct_text", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str
        end
      elseif player:IsAssistNpc() and player:HasNpcId() then
        cfgText = _G.DataConfigManager:GetGlobalConfigByKeyType("battle_process_assist_hp_deduct_text", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str
      else
        cfgText = _G.DataConfigManager:GetGlobalConfigByKeyType("battle_process_role_hp_deduct_text", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str
      end
    elseif tipsKey then
      cfgText = _G.DataConfigManager:GetLocalizationConf(tipsKey).msg
    else
      cfgText = _G.DataConfigManager:GetLocalizationConf("consume_hp_zero_tip_player").msg
    end
    self.Des:SetText(string.format(cfgText, diePet and diePet.card.name or ""))
  elseif player.teamEnm == BattleEnum.Team.ENUM_ENEMY then
    if diePet then
      local baseID = diePet:GetPetID()
      local baseConf = _G.DataConfigManager:GetPetbaseConf(baseID)
      if 0 == baseConf.consume_role_hp then
        cfgText = _G.DataConfigManager:GetLocalizationConf("consume_hp_zero_tip_enemy").msg
      elseif isLast then
        cfgText = _G.DataConfigManager:GetGlobalConfigByKeyType("battle_end_opposite_hp_deduct_text", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str
      else
        cfgText = _G.DataConfigManager:GetGlobalConfigByKeyType("battle_process_opposite_hp_deduct_text", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG).str
      end
    elseif tipsKey then
      cfgText = _G.DataConfigManager:GetLocalizationConf(tipsKey).msg
    else
      cfgText = _G.DataConfigManager:GetLocalizationConf("consume_hp_zero_tip_player").msg
    end
    self.Des:SetText(string.format(cfgText, diePet and diePet.card.name or ""))
  else
    self.Des:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:PCModeScreenSetting()
  local Padding = UE4.FMargin()
  Padding.Left = -164
  Padding.Top = -74
  Padding.Right = -164
  Padding.Bottom = -74
  self.NRCSafeZone_36:SetRenderScale(UE4.FVector2D(0.88, 0.88))
  self.NRCSafeZone_36.Slot:SetOffsets(Padding)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:UpdatePVP(param)
  local changePlayer = param.pvpPlayer
  if not changePlayer then
    self.HpScreenFx:HidePVP()
    return
  end
  local player = param.player
  if player.teamEnm == changePlayer.teamEnm then
    Log.Error("pvp\230\149\176\230\141\174\229\135\186\233\148\153  \230\136\152\232\180\165\232\128\133\231\154\132\229\136\134\230\149\176\229\143\145\231\148\159\230\148\185\229\143\152")
    self.HpScreenFx:HidePVP()
    return
  end
  local leftName, leftScore, rightName, rightScore
  if changePlayer.teamEnm == BattleEnum.Team.ENUM_TEAM then
    leftScore = tostring(param.pvp_result + param.pvp_change)
    leftName = changePlayer.roleInfo.base.name or "Name is nil"
    rightScore = tostring(player.roleInfo.base.pvp_score)
    rightName = player.roleInfo.base.name or "Name is nil"
    self:DelaySeconds(0.5, function()
      self.HpScreenFx:UpdateScore(param.pvp_result, true)
    end)
  else
    rightScore = tostring(param.pvp_result + param.pvp_change)
    rightName = changePlayer.roleInfo.base.name or "Name is nil"
    leftScore = tostring(player.roleInfo.base.pvp_score)
    leftName = player.roleInfo.base.name or "Name is nil"
    self:DelaySeconds(0.5, function()
      self.HpScreenFx:UpdateScore(param.pvp_result, false)
    end)
  end
  self.HpScreenFx:ShowPVP(leftName, leftScore, rightName, rightScore)
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:OnAnimationFinished(Animation)
  if Animation == self.open then
    self:StopAllAnimations()
    self:PlayAnimation(self.loop, 0, 0)
    return
  elseif Animation == self.close then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    if self.module then
      self:DoClose()
    end
  elseif Animation == self.loop then
  end
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:Show()
  self:RefreshInfo(self.uiData.param)
  self:StopAllAnimations()
  self:PlayAnimation(self.open)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.HpScreenFx:Show()
end

function UMG_Battle_RoleHp_DefeatedTipPanel_C:Hide()
  self:StopAllAnimations()
  self:PlayAnimation(self.close)
  _G.BattleManager.battleRuntimeData.isWaitingRoleHP = false
  _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_PROCESS_ROLE_HP_END)
end

return UMG_Battle_RoleHp_DefeatedTipPanel_C
