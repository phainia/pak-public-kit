local WorldCombatModuleEvent = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleEvent")
local MiniGameModuleEvent = require("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local WorldCombatModuleEnum = require("NewRoco.Modules.System.WorldCombat.WorldCombatModuleEnum")
local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local WORLD_COMBAT_CONF = _G.DataConfigManager:GetAllByName("WORLD_COMBAT_CONF")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local UMG_WorldCombat_Lifebar_C = _G.NRCPanelBase:Extend("UMG_WorldCombat_Lifebar_C")
local max_lifeBar_length = 570
local shield_max_value = _G.DataConfigManager:GetNpcGlobalConfig("worldcombat_shield_max_value").num
local Length_per_shield_value = max_lifeBar_length / shield_max_value
local LifeBarState = {
  Add = 1,
  Reduce = 2,
  Broken = 3,
  Idle = 4
}
local lifeBar_grid_path = {}
lifeBar_grid_path[4] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_031.T_UI_LXY_031'"
lifeBar_grid_path[5] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_032.T_UI_LXY_032'"
lifeBar_grid_path[6] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_033.T_UI_LXY_033'"
lifeBar_grid_path[7] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_034.T_UI_LXY_034'"
lifeBar_grid_path[8] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_035.T_UI_LXY_035'"
lifeBar_grid_path[9] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_036.T_UI_LXY_036'"
lifeBar_grid_path[10] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_037.T_UI_LXY_037'"
lifeBar_grid_path[11] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_038.T_UI_LXY_038'"
lifeBar_grid_path[12] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/T_UI_LXY_039.T_UI_LXY_039'"
local lifeBar_grid_image_path = {}
lifeBar_grid_image_path[4] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_800_1.img_800_1'"
lifeBar_grid_image_path[5] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1000_1.img_1000_1'"
lifeBar_grid_image_path[6] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1200_1.img_1200_1'"
lifeBar_grid_image_path[7] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1400_1.img_1400_1'"
lifeBar_grid_image_path[8] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1600_1.img_1600_1'"
lifeBar_grid_image_path[9] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1800_1.img_1800_1'"
lifeBar_grid_image_path[10] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2000_1.img_2000_1'"
lifeBar_grid_image_path[11] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2200_1.img_2200_1'"
lifeBar_grid_image_path[12] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2400_1.img_2400_1'"
local lifeBar_grid_increase_image_path = {}
lifeBar_grid_increase_image_path[4] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_800_3.img_800_3'"
lifeBar_grid_increase_image_path[5] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1000_3.img_1000_3'"
lifeBar_grid_increase_image_path[6] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1200_3.img_1200_3'"
lifeBar_grid_increase_image_path[7] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1400_3.img_1400_3'"
lifeBar_grid_increase_image_path[8] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1600_3.img_1600_3'"
lifeBar_grid_increase_image_path[9] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1800_3.img_1800_3'"
lifeBar_grid_increase_image_path[10] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2000_3.img_2000_3'"
lifeBar_grid_increase_image_path[11] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2200_3.img_2200_3'"
lifeBar_grid_increase_image_path[12] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2400_3.img_2400_3'"
local lifeBar_grid_background_path = {}
lifeBar_grid_background_path[4] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_800_2.img_800_2'"
lifeBar_grid_background_path[5] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1000_2.img_1000_2'"
lifeBar_grid_background_path[6] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1200_2.img_1200_2'"
lifeBar_grid_background_path[7] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1400_2.img_1400_2'"
lifeBar_grid_background_path[8] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1600_2.img_1600_2'"
lifeBar_grid_background_path[9] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1800_2.img_1800_2'"
lifeBar_grid_background_path[10] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2000_2.img_2000_2'"
lifeBar_grid_background_path[11] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2200_2.img_2200_2'"
lifeBar_grid_background_path[12] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_2400_2.img_2400_2'"
local lifeBar_grid_shield_lock_path = {}
lifeBar_grid_shield_lock_path[4] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_800_4.img_800_4'"
lifeBar_grid_shield_lock_path[5] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1000_4.img_1000_4'"
lifeBar_grid_shield_lock_path[6] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1200_4.img_1200_4'"
lifeBar_grid_shield_lock_path[7] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1400_4.img_1400_4'"
lifeBar_grid_shield_lock_path[8] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/WorldCombat/img_1600_4.img_1600_4'"

function UMG_WorldCombat_Lifebar_C:OnActive()
end

function UMG_WorldCombat_Lifebar_C:OnConstruct()
  self:OnAddEventListener()
  self:UpdateVisibility(UE4.ESlateVisibility.Collapsed)
  self.LifeBarState = LifeBarState.Idle
  _G.UpdateManager:UnRegister(self)
  self.HpBarShieldBack:SetPercent(0)
  self.HpBarNightmareBack:SetPercent(0)
  self.HpBarShield:SetPercent(0)
  self.HpBarNightmare:SetPercent(0)
  self.HpBarShieldLocking:SetPercent(0)
  self.HpBarShieldLocking:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.bNightmare = false
  self.HpBarLength = self.HpBarShield.Slot:GetSize().X
  self.FxBrokenInitOffset = self.HpBarShield.Slot.LayoutData.Offsets.Left
  _G.NRCEventCenter:RegisterEvent(self.name, self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
end

function UMG_WorldCombat_Lifebar_C:OnLoadingClosed()
  _G.NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  self:InitUI()
end

function UMG_WorldCombat_Lifebar_C:InitUI()
  local shield_state, max_value, shield_value = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetShieldData)
  Log.Debug("UMG_WorldCombat_Lifebar_C:InitUI", shield_state, max_value, shield_value)
  local bossId = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetBossID)
  local is_target = bossId and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsWorldCombatTarget, bossId)
  if not is_target then
    return
  end
  if shield_state == WorldCombatModuleEnum.ShieldState.Hidden then
    self:OnBarrierHidden()
  elseif shield_state == WorldCombatModuleEnum.ShieldState.Broken then
    self:OnBarrierBroken(max_value)
    if self.bNightmare then
      self:PlayAnimation(self.Red_Out)
    else
      self:PlayAnimation(self.Blue_out)
    end
  elseif shield_state == WorldCombatModuleEnum.ShieldState.Normal then
    self:OnBarrierShow(max_value, shield_value)
  end
  local boss = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, bossId)
  if boss then
    self:OnUpdateBossInfo(boss)
  end
end

function UMG_WorldCombat_Lifebar_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierChange, self.OnBarrierChange)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierBroken, self.OnBarrierBroken)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierHidden, self.OnBarrierHidden)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierShow, self.OnBarrierShow)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnUpdateBossInfo, self.OnUpdateBossInfo)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierImmune, self.OnBarrierImmune)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierExitImmune, self.OnBarrierExitImmune)
  _G.NRCEventCenter:UnRegisterEvent(self, WorldCombatModuleEvent.Enter, self.WorldCombatEnter)
  _G.NRCEventCenter:UnRegisterEvent(self, WorldCombatModuleEvent.Exit, self.WorldCombatExit)
  _G.UpdateManager:UnRegister(self)
  if self.nightmareBackProgressTimerId then
    _G.DelayManager:CancelDelayById(self.nightmareBackProgressTimerId)
    self.nightmareBackProgressTimerId = nil
  end
  if self.backProgressTimerId then
    _G.DelayManager:CancelDelayById(self.backProgressTimerId)
    self.backProgressTimerId = nil
  end
end

function UMG_WorldCombat_Lifebar_C:UpdateVisibility(visibility)
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainChildVisibilityChange, self, visibility)
end

function UMG_WorldCombat_Lifebar_C:OnBarrierChange(old_value, new_value, isCrit)
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  if not bInWorldCombat then
    return
  end
  self.current_value = old_value
  self.real_value = new_value
  self.current_percent = old_value / self.max_value
  self.real_percent = new_value / self.max_value
  local midPercent = ((old_value + new_value) / (self.max_value * 2.0) - 0.5) * self.HpBarLength + self.FxBrokenInitOffset
  if old_value < new_value then
    self.LifeBarState = LifeBarState.Add
  else
    self.LifeBarState = LifeBarState.Idle
    if self.bNightmare then
      self.HpBarNightmare:SetPercent(self.real_percent)
      self.HpBarNightmareBack:SetPercent(self.current_percent)
      if isCrit then
        self:PlayCritAnimation(midPercent)
      end
      if self.nightmareBackProgressTimerId then
        _G.DelayManager:CancelDelayById(self.nightmareBackProgressTimerId)
      end
      self.nightmareBackProgressTimerId = _G.DelayManager:DelaySeconds(0.15, self.OnWidgetPlayCritAnimation, self, self.HpBarNightmareBack, isCrit, midPercent)
    else
      self.HpBarShield:SetPercent(self.real_percent)
      self.HpBarShieldBack:SetPercent(self.current_percent)
      if isCrit then
        self:PlayCritAnimation(midPercent)
      end
      if self.backProgressTimerId then
        _G.DelayManager:CancelDelayById(self.backProgressTimerId)
      end
      self.backProgressTimerId = _G.DelayManager:DelaySeconds(0.15, self.OnWidgetPlayCritAnimation, self, self.HpBarShieldBack, isCrit, midPercent)
    end
    self:StopAnimation(self.Xublood_in)
    self:StopAnimation(self.Xublood_out)
    self:PlayAnimation(self.Xublood_in)
  end
  Log.Debug("OnBarrierChange", old_value, new_value)
  self:UpdateVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_WorldCombat_Lifebar_C:OnWidgetPlayCritAnimation(widget, isCrit, midPercent)
  widget:SetPercent(self.real_percent)
  if widget == self.HpBarShieldBack then
    self.backProgressTimerId = nil
  elseif widget == self.HpBarNightmareBack then
    self.nightmareBackProgressTimerId = nil
  end
end

function UMG_WorldCombat_Lifebar_C:PlayCritAnimation(midPercent)
  self.Fx_broken:SetRenderTranslation(UE4.FVector2D(midPercent, 0))
  local layout = self.Fx_broken.Slot.LayoutData
  layout.Offsets.Left = midPercent
  self.Fx_broken.Slot:SetLayout(layout)
  self:StopAnimation(self.Blue_Shake)
  self:PlayAnimation(self.Blue_Shake)
  self:StopAnimation(self.Blue_broken)
  self:PlayAnimation(self.Blue_broken)
end

function UMG_WorldCombat_Lifebar_C:OnBarrierBroken(max_value)
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  if not bInWorldCombat then
    return
  end
  Log.Warning("UMG_WorldCombat_Lifebar_C:OnBarrierBroken", max_value)
  self.max_value = max_value
  self.current_value = 0
  self.real_value = 0
  self.real_percent = 0
  self.current_percent = 0
  self.LifeBarState = LifeBarState.Reduce
  local bossId = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetBossID)
  local is_target = bossId and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsWorldCombatTarget, bossId)
  if not is_target then
    return
  end
  self:UpdateVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_WorldCombat_Lifebar_C:OnBarrierHidden()
  Log.Debug("UMG_WorldCombat_Lifebar_C:OnBarrierHidden")
  _G.UpdateManager:UnRegister(self)
end

function UMG_WorldCombat_Lifebar_C:OnUpdateBossInfo(npc)
  if not npc then
    return
  end
  local actor_id = npc and npc.serverData and npc.serverData.base.actor_id
  local hp = 100
  local hp_max = 100
  if npc.serverData.attrs then
    hp = npc.serverData.attrs.hp
    hp_max = npc.serverData.attrs.hp_max
  else
  end
  if hp > hp_max or hp_max <= 0 then
    hp = 100
    hp_max = 100
  end
  local buffList = {}
  if npc.serverData.buff_info then
    buffList = npc.serverData.buff_info.battle_buff_infos
  end
  if buffList and #buffList > 0 then
    self.BuffList:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BuffList:InitGridView(buffList)
  else
    self.BuffList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.BossName:SetText(npc.serverData.base.name)
  if npc.serverData.npc_base and npc.serverData.npc_base.npc_content_cfg_id and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsNightmare) then
    local WorldCombatConf
    for k, v in pairs(WORLD_COMBAT_CONF) do
      if v.refresh_content_id == npc.serverData.npc_base.npc_content_cfg_id then
        WorldCombatConf = v
        break
      end
    end
    if WorldCombatConf then
      local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(WorldCombatConf.world_boss_refer)
      local commonAttrData = {}
      local unitType = PetBaseConf.unit_type
      for i = 1, #unitType do
        local typedic = _G.DataConfigManager:GetTypeDictionary(unitType[i])
        table.insert(commonAttrData, i, {
          path = typedic.type_icon,
          ShowOutLine = true
        })
      end
      self.DepartmentIcon:InitGridView(commonAttrData)
      local levelText, IsReCom = MagicManualUtils.GetBossLevel(npc.serverData.npc_base.npc_content_cfg_id)
      if IsReCom then
        self.Level:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#F4EEE1FF"))
      else
        self.Level:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
      end
      self.Level:SetText((string.format(LuaText.umg_petskilltemple2_1, levelText)))
    end
    self.Level:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.DepartmentIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Level:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.DepartmentIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.HpBarGreen:SetPercent(hp / hp_max)
end

function UMG_WorldCombat_Lifebar_C:OnBarrierImmune()
  if self.LifeBarState == LifeBarState.Broken or 0 == self.real_value then
    return
  end
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  Log.Warning("UMG_WorldCombat_Lifebar_C:OnBarrierImmune", bInWorldCombat, self.LifeBarState, self.real_value)
  if not bInWorldCombat then
    return
  end
  self.HpBarShield:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HpBarShieldBack:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HpBarNightmare:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HpBarNightmareBack:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HpBarShieldLocking:SetPercent(self.real_percent)
  self.HpBarShieldLocking:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  self.Switcher:SetActiveWidgetIndex(2)
  self.bImmune = true
end

function UMG_WorldCombat_Lifebar_C:OnBarrierExitImmune()
  self.HpBarShieldLocking:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.bImmune = false
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsSelfInWorldCombat)
  Log.Debug("UMG_WorldCombat_Lifebar_C:OnBarrierExitImmune", bInWorldCombat)
  if not bInWorldCombat then
    return
  end
  self:SetNightmare(self.bNightmare)
end

function UMG_WorldCombat_Lifebar_C:OnBarrierShow(max_value, new_value)
  local bossId = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetBossID)
  local is_target = bossId and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsWorldCombatTarget, bossId)
  if not is_target then
    Log.Error("UMG_WorldCombat_Lifebar_C:OnBarrierShow failed", self.bNightmare, max_value, new_value, self.current_percent, self.real_percent, self.bImmune, bossId, is_target)
    return
  end
  Log.Warning("UMG_WorldCombat_Lifebar_C:OnBarrierShow", self.bNightmare, max_value, new_value, self.current_percent, self.real_percent, self.bImmune, bossId)
  local boss = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, bossId)
  if boss then
    Log.Debug("UMG_WorldCombat_Lifebar_C:OnBarrierShowName", boss)
    self:OnUpdateBossInfo(boss)
    local AIComponent = boss.AIComponent
    self.bImmune = AIComponent:HasControlFlags(_G.Enum.SceneAiControlFlags.SACF_PETBOSS_INVICIBLE)
  end
  _G.UpdateManager:Register(self)
  if self.bNightmare then
    self:StopAnimation(self.Red_Out)
    self:PlayAnimation(self.Red_In)
  else
    self:StopAnimation(self.Blue_out)
    self:PlayAnimation(self.Blue_in)
  end
  self:UpdateVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.max_value = max_value
  self:UpdateLifeBar()
  self.current_value = 0
  self.real_value = new_value
  self.current_percent = 0
  if 0 == max_value then
    self.real_percent = 0
    self.LifeBarState = LifeBarState.Reduce
    if self.bNightmare then
      self:StopAnimation(self.Red_In)
    else
      self:StopAnimation(self.Blue_in)
    end
    return
  end
  self.real_percent = new_value / max_value
  self.LifeBarState = LifeBarState.Add
end

function UMG_WorldCombat_Lifebar_C:UpdateLifeBar()
  local lifeBar_grid_num = math.round(self.max_value / 400.0)
  lifeBar_grid_num = math.min(lifeBar_grid_num, 8)
  lifeBar_grid_num = math.max(lifeBar_grid_num, 4)
  local path = lifeBar_grid_path[lifeBar_grid_num]
  if self.bNightmare then
    self.HpBarNightmare:SetFillImage(UE4.EChangeImageType.Fill, lifeBar_grid_image_path[lifeBar_grid_num])
    self.HpBarNightmare:SetFillImage(UE4.EChangeImageType.Increase, lifeBar_grid_increase_image_path[lifeBar_grid_num])
    self.HpBarNightmareBack:SetFillImage(UE4.EChangeImageType.Fill, lifeBar_grid_image_path[lifeBar_grid_num])
    self.HpBarNightmareBack:SetFillImage(UE4.EChangeImageType.Increase, lifeBar_grid_increase_image_path[lifeBar_grid_num])
  else
    self.HpBarShield:SetFillImage(UE4.EChangeImageType.Fill, lifeBar_grid_image_path[lifeBar_grid_num])
    self.HpBarShield:SetFillImage(UE4.EChangeImageType.Increase, lifeBar_grid_increase_image_path[lifeBar_grid_num])
    self.HpBarShieldBack:SetFillImage(UE4.EChangeImageType.Fill, lifeBar_grid_image_path[lifeBar_grid_num])
    self.HpBarShieldBack:SetFillImage(UE4.EChangeImageType.Increase, lifeBar_grid_increase_image_path[lifeBar_grid_num])
  end
  self.ShieldBar_BG:SetPath(lifeBar_grid_background_path[lifeBar_grid_num])
  local lockImage = lifeBar_grid_shield_lock_path[lifeBar_grid_num]
  if lockImage then
    self.HpBarShieldLocking:SetFillImage(UE4.EChangeImageType.Fill, lockImage)
    self.HpBarShieldLocking:SetFillImage(UE4.EChangeImageType.Increase, lockImage)
  end
  self.request = _G.NRCResourceManager:LoadResAsync(self, path, -1, -1, function(caller, resRequest, asset)
    self:SetTexture(asset)
  end, nil, nil)
end

function UMG_WorldCombat_Lifebar_C:SetTexture(Texture)
  self.HpBarShield_light:GetFillImageDynamicMaterial():SetTextureParameterValue("Mask_Texture", Texture)
end

function UMG_WorldCombat_Lifebar_C:OnDeactive()
end

function UMG_WorldCombat_Lifebar_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnBarrierChange, self.OnBarrierChange)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnBarrierBroken, self.OnBarrierBroken)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnBarrierHidden, self.OnBarrierHidden)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnBarrierShow, self.OnBarrierShow)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnUpdateBossInfo, self.OnUpdateBossInfo)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnBarrierImmune, self.OnBarrierImmune)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MainUIModuleEvent.OnBarrierExitImmune, self.OnBarrierExitImmune)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, WorldCombatModuleEvent.Enter, self.WorldCombatEnter)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, WorldCombatModuleEvent.Exit, self.WorldCombatExit)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MiniGameModuleEvent.Start, self.MiniGameStart)
  _G.NRCEventCenter:RegisterEvent("UMG_WorldCombat_Lifebar_C", self, MiniGameModuleEvent.End, self.MiniGameEnd)
  self:AddButtonListener(self.Btn_GiveUp, self.OnBtnGiveUp)
end

function UMG_WorldCombat_Lifebar_C:WorldCombatEnter()
  Log.Debug("UMG_WorldCombat_Lifebar_C:WorldCombatBegin")
  self:SetNightmare(_G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsNightmare))
  local bossId = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetBossID)
  local boss = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, bossId)
  self:OnUpdateBossInfo(boss)
  if not self:IsAnimationPlaying(self.Green_In) then
    self:StopAnimation(self.Green_out)
    self:PlayAnimation(self.Green_In)
  end
end

function UMG_WorldCombat_Lifebar_C:WorldCombatExit()
  Log.Debug("UMG_WorldCombat_Lifebar_C:WorldCombatEnd")
  self:StopAnimation(self.Green_In)
  self:PlayAnimation(self.Green_out)
  if self.bNightmare then
    self:StopAnimation(self.Red_In)
    self:PlayAnimation(self.Red_Out)
  else
    self:StopAnimation(self.Blue_in)
    self:PlayAnimation(self.Blue_out)
  end
  self.HpBarShieldLocking:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.bImmune = false
  self.bNightmare = false
end

function UMG_WorldCombat_Lifebar_C:MiniGameStart(bNightmare)
  Log.Debug("UMG_WorldCombat_Lifebar_C:MiniGameStart", bNightmare)
  self:SetNightmare(bNightmare)
end

function UMG_WorldCombat_Lifebar_C:MiniGameEnd(bFail)
  Log.Debug("UMG_WorldCombat_Lifebar_C:MiniGameEnd", bFail)
  local bInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInWorldCombat)
  if bInWorldCombat then
    return
  end
  self:SetNightmare(true)
end

function UMG_WorldCombat_Lifebar_C:OnAnimationFinished(Anim)
  if Anim == self.Green_out then
    self.bHasGreenIn = false
    self:UpdateVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if Anim == self.Green_In then
    self.bHasGreenIn = true
  end
  if Anim then
    Log.Debug("UMG_WorldCombat_Lifebar_C:OnAnimationFinished", Anim:GetName())
  end
end

function UMG_WorldCombat_Lifebar_C:OnAnimationStarted(Anim)
  if Anim then
    Log.Debug("UMG_WorldCombat_Lifebar_C:OnAnimationStarted", Anim:GetName())
  end
end

function UMG_WorldCombat_Lifebar_C:OnTick(deltaTime)
  if self.LifeBarState == LifeBarState.Idle or self.LifeBarState == LifeBarState.Broken then
    return
  elseif self.LifeBarState == LifeBarState.Add then
    self.current_percent = self.current_percent + 1 * deltaTime
    if self.current_percent >= self.real_percent then
      self.current_percent = self.real_percent
      self.LifeBarState = LifeBarState.Idle
      if self.bImmune then
        self:OnBarrierImmune()
      end
    end
    self.HpBarShield_light:SetPercent(self.current_percent)
    self.HpBarShield_light:SetIncreasePercent(0)
    self.HpBarShieldLocking:SetPercent(self.current_percent)
    self.HpBarShieldLocking:SetIncreasePercent(0)
    if self.bNightmare then
      self.HpBarNightmare:SetPercent(self.current_percent)
      self.HpBarNightmare:SetIncreasePercent(0)
      self.HpBarNightmareBack:SetPercent(self.current_percent)
      self.HpBarNightmareBack:SetIncreasePercent(0)
    else
      self.HpBarShield:SetPercent(self.current_percent)
      self.HpBarShield:SetIncreasePercent(0)
      self.HpBarShieldBack:SetPercent(self.current_percent)
      self.HpBarShieldBack:SetIncreasePercent(0)
    end
  elseif self.LifeBarState == LifeBarState.Reduce then
    if self.current_percent == nil then
      self.LifeBarState = LifeBarState.Idle
      Log.Error("\230\156\137\233\151\174\233\162\152\229\149\138")
      return
    end
    self.current_percent = self.current_percent - 0.8 * deltaTime
    if self.current_percent <= self.real_percent then
      self.current_percent = self.real_percent
      if 0 == self.current_percent then
        self.LifeBarState = LifeBarState.Broken
        if self.bNightmare then
          self:StopAnimation(self.Red_In)
          self:PlayAnimation(self.Red_Out)
        else
          self:StopAnimation(self.Blue_in)
          self:PlayAnimation(self.Blue_out)
        end
      else
        self:StopAnimation(self.Xublood_in)
        self:StopAnimation(self.Xublood_out)
        self:PlayAnimation(self.Xublood_out)
        self.LifeBarState = LifeBarState.Idle
      end
    end
    if self.bNightmare then
      self.HpBarNightmare:SetPercent(self.current_percent)
      self.HpBarNightmare:SetIncreasePercent(0)
    else
      self.HpBarShield:SetPercent(self.current_percent)
      self.HpBarShield:SetIncreasePercent(0)
    end
    self.HpBarShield_light:SetPercent(self.current_percent)
    self.HpBarShield_light:SetIncreasePercent(0)
    self.HpBarShieldLocking:SetPercent(self.current_percent)
    self.HpBarShieldLocking:SetIncreasePercent(0)
  end
end

function UMG_WorldCombat_Lifebar_C:SetNightmare(bNightmare)
  self.bNightmare = bNightmare
  if bNightmare then
    self.HpBarShield:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HpBarShieldBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HpBarNightmare:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.HpBarNightmareBack:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.HpBarShield:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.HpBarShieldBack:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.HpBarNightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HpBarNightmareBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher:SetActiveWidgetIndex(0)
  end
  self.HpBarShieldLocking:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_WorldCombat_Lifebar_C:ShowLeaderChallengeBtn(State)
  if State then
    if self.Btn_GiveUp then
      self.Btn_GiveUp:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif self.Btn_GiveUp then
    self.Btn_GiveUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_WorldCombat_Lifebar_C:OnBtnGiveUp()
  G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.OpenLeaveBossChallengePanel)
end

return UMG_WorldCombat_Lifebar_C
