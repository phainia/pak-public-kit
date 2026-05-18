local Base = require("NewRoco.Modules.System.MainUI.Res.UMG_Hud_Base")
local DeviceUtils = require("NewRoco.Modules.Core.App.DeviceUtils")
local UMG_Hud_Feed_C = Base:Extend("UMG_Hud_Feed_C")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local MessageIdConf = _G.DataConfigManager:GetNpcGlobalConfig("mark_magic_message_id")
local FakeMessageIdConf = _G.DataConfigManager:GetNpcGlobalConfig("mark_fake_magic_message_id")
local LifeFlowerIdConf = _G.DataConfigManager:GetNpcGlobalConfig("mark_life_flower_id")
local EnergyFlowerIdConf = _G.DataConfigManager:GetNpcGlobalConfig("mark_energe_flower_id")
local VideoIdConf = 55591
local energy_flower_name_label = _G.DataConfigManager:GetLocalizationConf("mark_title_energe_flower_disable", true)
local life_flower_name_label = _G.DataConfigManager:GetLocalizationConf("mark_title_life_flower_disable", true)
local canot_energy_flower_label = _G.DataConfigManager:GetLocalizationConf("mark_title_energe_flower_able", true)
local canot_life_flower_name_label = _G.DataConfigManager:GetLocalizationConf("mark_title_life_flower_able", true)
local VideoUploadConf = _G.DataConfigManager:GetLocalizationConf("mark_video_upload", true)

function UMG_Hud_Feed_C:OnEnable(npc, ParentHud)
  if not (MessageIdConf and MessageIdConf.num and FakeMessageIdConf and FakeMessageIdConf.num and LifeFlowerIdConf and LifeFlowerIdConf.num and EnergyFlowerIdConf) or not EnergyFlowerIdConf.num then
    return
  end
  self.FirstOpen = true
  self.npc = npc
  self.IsEnergyFull = true
  self.IsHpFull = true
  self.ParentHud = ParentHud
  self.cfg_id = npc.config.id
  if not self.cfg_id then
    return
  end
  self.Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if (self.cfg_id == LifeFlowerIdConf.num or self.cfg_id == EnergyFlowerIdConf.num) and self.FirstOpen then
    _G.NRCEventCenter:RegisterEvent("UMG_Hud_Feed_C", self, PetUIModuleEvent.PetEnergyChangeForTrace, self.OnEnergyChange)
    if self.Player then
      self.Player:AddEventListener(self, PlayerModuleEvent.ON_ROLE_HP_CHANGE_FOR_TRACE_RAW, self.OnHpChange)
    end
    self.FirstOpen = false
  end
  if self.cfg_id == LifeFlowerIdConf.num then
    self:OnHpChange()
  elseif self.cfg_id == EnergyFlowerIdConf.num then
    self:OnEnergyChange()
  else
    self:SetMessage()
  end
end

function UMG_Hud_Feed_C:OnEnergyChange()
  self.IsEnergyFull = _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.GetPetEnergyFull)
  self:SetMessage()
end

function UMG_Hud_Feed_C:OnHpChange()
  self.IsHpFull = _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.GetPlayerHpFull)
  self:SetMessage()
end

function UMG_Hud_Feed_C:SetMessage()
  local npc = self.npc
  if npc then
    if self.cfg_id == FakeMessageIdConf.num then
      local RefreshContentConf = _G.DataConfigManager:GetNpcRefreshContentConf(npc.contentConf.id)
      if RefreshContentConf and RefreshContentConf.npc_option_ids[1] then
        local OptionConf = _G.DataConfigManager:GetNpcOptionConf(RefreshContentConf.npc_option_ids[1])
        if not OptionConf and not OptionConf.action then
          return
        end
        local FakeMessageId = OptionConf.action.action_param1
        if FakeMessageId then
          FakeMessageId = tonumber(FakeMessageId)
          local FakeMessageInfo = _G.DataConfigManager:GetMarkFakeMagicMessageConf(FakeMessageId, true)
          if FakeMessageInfo then
            local maxType, maxTypeNum = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon1_2_png.img_LeaveTrace_Icon1_2_png", 0
            if FakeMessageInfo.like_count and maxTypeNum < FakeMessageInfo.like_count then
              maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon1_2_png.img_LeaveTrace_Icon1_2_png"
              maxTypeNum = FakeMessageInfo.like_count
            end
            if FakeMessageInfo.hug_count and maxTypeNum < FakeMessageInfo.hug_count then
              maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon2_3_png.img_LeaveTrace_Icon2_3_png"
              maxTypeNum = FakeMessageInfo.hug_count
            end
            if FakeMessageInfo.light_count and maxTypeNum < FakeMessageInfo.light_count then
              maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon3_4_png.img_LeaveTrace_Icon3_4_png"
              maxTypeNum = FakeMessageInfo.light_count
            end
            self.Num:SetText(maxTypeNum)
            if DeviceUtils.OptimizeNameLabel() then
              self.Attitude:SetPathWithCallBack(maxType, {
                self,
                self.OnSuccess
              })
            else
              self.Attitude:SetPath(maxType)
            end
          end
        end
      end
    elseif self.cfg_id == MessageIdConf.num then
      local magicFeedInfo = npc.serverData.MagicFeedInfo
      if magicFeedInfo then
        local maxType, maxTypeNum = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon1_2_png.img_LeaveTrace_Icon1_2_png", 0
        if magicFeedInfo.attitude_like_num and maxTypeNum < magicFeedInfo.attitude_like_num then
          maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon1_2_png.img_LeaveTrace_Icon1_2_png"
          maxTypeNum = self.npc.serverData.MagicFeedInfo.attitude_like_num
        end
        if magicFeedInfo.attitude_hug_num and maxTypeNum < magicFeedInfo.attitude_hug_num then
          maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon2_3_png.img_LeaveTrace_Icon2_3_png"
          maxTypeNum = self.npc.serverData.MagicFeedInfo.attitude_hug_num
        end
        if magicFeedInfo.attitude_inspiration_num and maxTypeNum < magicFeedInfo.attitude_inspiration_num then
          maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon3_4_png.img_LeaveTrace_Icon3_4_png"
          maxTypeNum = self.npc.serverData.MagicFeedInfo.attitude_inspiration_num
        end
        local MaxNumConf = _G.DataConfigManager:GetGlobalConfig("mark_magic_message_hot_name_max", true)
        if MaxNumConf and MaxNumConf.num then
          if maxTypeNum > MaxNumConf.num then
            local MaxNumMsgConf = _G.DataConfigManager:GetLocalizationConf("mark_magic_message_hot_name_max", true)
            if MaxNumMsgConf and MaxNumMsgConf.msg then
              self.Num:SetText(MaxNumMsgConf.msg)
            end
          else
            self.Num:SetText(maxTypeNum)
          end
        end
        if DeviceUtils.OptimizeNameLabel() then
          self.Attitude:SetPathWithCallBack(maxType, {
            self,
            self.OnSuccess
          })
        else
          self.Attitude:SetPath(maxType)
        end
      end
    elseif self.cfg_id == LifeFlowerIdConf.num then
      local magicFeedInfo = npc.serverData.MagicFeedInfo
      if magicFeedInfo then
        local playerName = ""
        if magicFeedInfo.name then
          playerName = magicFeedInfo.name
        end
        self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.TextName:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Common:SetVisibility(UE4.ESlateVisibility.Visible)
        self.TextName:SetText(playerName)
        local Str = ""
        if self.IsHpFull then
          if life_flower_name_label then
            Str = LuaText.mark_title_life_flower_disable
          end
        elseif canot_life_flower_name_label then
          Str = LuaText.mark_title_life_flower_able
        end
        self.Common:SetText(Str)
      end
    elseif self.cfg_id == EnergyFlowerIdConf.num then
      local magicFeedInfo = npc.serverData.MagicFeedInfo
      if magicFeedInfo then
        local playerName = ""
        if magicFeedInfo.name then
          playerName = magicFeedInfo.name
        end
        self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.TextName:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Common:SetVisibility(UE4.ESlateVisibility.Visible)
        self.TextName:SetText(playerName)
        local Str = ""
        if self.IsEnergyFull then
          if energy_flower_name_label then
            Str = LuaText.mark_title_energe_flower_disable
          end
        elseif canot_energy_flower_label then
          Str = LuaText.mark_title_energe_flower_able
        end
        self.Common:SetText(Str)
      end
    elseif self.cfg_id == VideoIdConf then
      if self.npc.serverData.base.videoUploading then
        local Str = ""
        if VideoUploadConf then
          Str = LuaText.mark_video_upload
        end
        self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.Common:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Common:SetText(Str)
      else
        self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Common:SetVisibility(UE4.ESlateVisibility.Hidden)
        local magicFeedInfo = npc.serverData.MagicFeedInfo
        if magicFeedInfo then
          local maxType, maxTypeNum = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon1_2_png.img_LeaveTrace_Icon1_2_png", 0
          if magicFeedInfo.attitude_like_num and maxTypeNum < magicFeedInfo.attitude_like_num then
            maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon1_2_png.img_LeaveTrace_Icon1_2_png"
            maxTypeNum = self.npc.serverData.MagicFeedInfo.attitude_like_num
          end
          if magicFeedInfo.attitude_hug_num and maxTypeNum < magicFeedInfo.attitude_hug_num then
            maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon2_3_png.img_LeaveTrace_Icon2_3_png"
            maxTypeNum = self.npc.serverData.MagicFeedInfo.attitude_hug_num
          end
          if magicFeedInfo.attitude_inspiration_num and maxTypeNum < magicFeedInfo.attitude_inspiration_num then
            maxType = "/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_LeaveTrace_Icon3_4_png.img_LeaveTrace_Icon3_4_png"
            maxTypeNum = self.npc.serverData.MagicFeedInfo.attitude_inspiration_num
          end
          local MaxNumConf = _G.DataConfigManager:GetGlobalConfig("mark_magic_message_hot_name_max", true)
          if MaxNumConf and MaxNumConf.num then
            if maxTypeNum > MaxNumConf.num then
              local MaxNumMsgConf = _G.DataConfigManager:GetLocalizationConf("mark_magic_message_hot_name_max", true)
              if MaxNumMsgConf and MaxNumMsgConf.msg then
                self.Num:SetText(MaxNumMsgConf.msg)
              end
            else
              self.Num:SetText(maxTypeNum)
            end
          end
          if DeviceUtils.OptimizeNameLabel() then
            self.Attitude:SetPathWithCallBack(maxType, {
              self,
              self.OnSuccess
            })
          else
            self.Attitude:SetPath(maxType)
          end
        end
      end
    end
  end
end

function UMG_Hud_Feed_C:OnDisable()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetEnergyChangeForTrace, self.OnEnergyChange)
  if self.Player then
    self.Player:RemoveEventListener(self, PlayerModuleEvent.ON_ROLE_HP_CHANGE_FOR_TRACE_RAW, self.OnHpChange)
    self.Player = nil
  end
  self.FirstOpen = true
end

function UMG_Hud_Feed_C:OnSuccess()
  if self.ParentHud then
    self.ParentHud:SubmitChange()
  end
end

function UMG_Hud_Feed_C:Destruct()
  self.npc = nil
  self.ParentHud = nil
end

return UMG_Hud_Feed_C
