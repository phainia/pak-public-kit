require("UnLuaEx")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ShowFxDisConf = _G.DataConfigManager:GetNpcGlobalConfig("mark_music_vfx_show_distance")
local WarningConf = _G.DataConfigManager:GetGlobalConfigByKey("mark_music_play_alarm_range")
local MusicPlayConf = _G.DataConfigManager:GetGlobalConfigByKey("mark_music_play_range")
local MusicWarnTipConf = _G.DataConfigManager:GetLocalizationConf("mark_music_stop_alarm")
local BP_NPCMessagePenForTrace_C = Base:Extend("BP_NPCMessagePenForTrace_C")

function BP_NPCMessagePenForTrace_C:Init()
  Base.Init(self)
  self.StartTick = false
  self.ShowFxDis = 0
  self.WarningDis = 0
  self.MusicPlayDis = 0
  self.NextShowTime = 0
  self.ShowFxFlag = true
  self.MusicWarnTip = "no music warn tip"
  if ShowFxDisConf then
    local ShowFx = ShowFxDisConf.num
    if ShowFx then
      self.ShowFxDis = ShowFx * ShowFx
    end
  end
  if WarningConf then
    local Warning = WarningConf.num
    if Warning then
      self.WarningDis = Warning * Warning
    end
  end
  if MusicPlayConf then
    local MusicPlay = MusicPlayConf.num
    if MusicPlay then
      self.MusicPlayDis = MusicPlay * MusicPlay
    end
  end
  if MusicWarnTipConf then
    local MusicWarnTip = MusicWarnTipConf.msg
    if MusicWarnTip then
      self.MusicWarnTip = MusicWarnTip
    end
  end
  self.ShowTipFlag = true
end

function BP_NPCMessagePenForTrace_C:SetPosition(InitPosition, SelectPosition)
  self.InitialPosition = InitPosition
  self.SelectPosition = SelectPosition
end

function BP_NPCMessagePenForTrace_C:SetTopMessageVisible()
  local npc = self.sceneCharacter
  if npc then
    self.music_id = npc.serverData.MagicFeedInfo.music_id
    local hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
    if not hudClass then
      Log.Error("BP_NPCMessagePenForTrace_C:SetTopMessageVisible _G.NRCBigWorldPreloader:Get(PET_HUD) First Failed")
      hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
      if not hudClass then
        Log.Error("BP_NPCMessagePenForTrace_C:SetTopMessageVisible _G.NRCBigWorldPreloader:Get(PET_HUD) Second Failed")
        return
      end
      return
    end
    local hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
    if not hud then
      Log.Error("BP_NPCMessagePenForTrace_C:SetTopMessageVisible Create hud First Failed")
      hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
      if not hud then
        Log.Error("BP_NPCMessagePenForTrace_C:SetTopMessageVisible Create hud Second Failed")
        return
      end
    end
    self.HeadWidget:SetWidget(hud)
    hud:SetParentHUD(self.HeadWidget)
    self.hudComp = npc:EnsureComponent(PetHUDComponent)
    if self.hudComp then
      self.hudComp:OnSetViewObj()
      self.hudComp:ForceUpdate()
    end
  end
end

function BP_NPCMessagePenForTrace_C:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if self.music_id == nil or 0 == self.music_id then
    return
  end
  self.sceneCharacter:ScheduleNextTick(0.1)
  local Dis2Local = self.sceneCharacter.squaredDis2Local
  if Dis2Local < self.ShowFxDis then
    if self.SetMusicFx and self.ShowFxFlag then
      self:SetMusicFx()
      self.ShowFxFlag = false
    end
    if not self.ShowTipFlag then
      self.ShowTipFlag = true
    end
  elseif self.SetMusicFxDeactive and not self.ShowFxFlag then
    self:SetMusicFxDeactive()
    self.ShowFxFlag = true
  end
  if not self.StartTick then
    return
  end
  if Dis2Local > self.WarningDis and Dis2Local < self.MusicPlayDis then
    if self.ShowTipFlag then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.MusicWarnTip)
      self.ShowTipFlag = false
    end
  elseif Dis2Local > self.MusicPlayDis then
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ExitMusicMessage)
  elseif Dis2Local < self.WarningDis and not self.ShowTipFlag then
    self.ShowTipFlag = true
  end
end

function BP_NPCMessagePenForTrace_C:SetTickStart(IsStart)
  self.StartTick = IsStart
  if IsStart then
    self.ShowTipFlag = true
  end
end

return BP_NPCMessagePenForTrace_C
