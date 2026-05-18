local UMG_MiracleExchange_C = _G.NRCPanelBase:Extend("UMG_MiracleExchange_C")
local SceneEnum = require("NewRoco.Modules.Core.Scene.Common.SceneEnum")

function UMG_MiracleExchange_C:OnActive(param)
  param.type = param.type or SceneEnum.MiracleExchangeType.CHANGE_FREE
  if param.type == SceneEnum.MiracleExchangeType.CHANGE_FREE then
    self:PlayAnimation(self.open_exchange)
  else
    self:PlayAnimation(self.open_confirm)
  end
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    if not localPlayer.serverData.miracle_change_info then
      localPlayer.serverData.miracle_change_info = ProtoMessage:newActorInfo_AvatarMiracleChange()
      localPlayer.serverData.miracle_change_info.send_miracle_change_times = 0
      localPlayer.serverData.miracle_change_info.recv_miracle_change_times = 0
    end
    self.serveData = localPlayer.serverData.miracle_change_info
  else
    Log.Error("SleepingOwlModule:OnActive LocalPlayer does not exist")
  end
  self.maxReceive = _G.DataConfigManager:GetGlobalConfigNumByKey("magic_change_receive_times", 20)
  self.maxSend = _G.DataConfigManager:GetGlobalConfigNumByKey("magic_change_send_times", 20)
  self.param = param
  self.TransformToChange = false
  self:SetUpList()
  self:SetType()
  self:OnAddEventListener()
end

function UMG_MiracleExchange_C:SetUpList()
  local PetFreeList = {}
  local petData = self.param.data
  local gid = {}
  local petBallIds = {}
  for i, _petData in ipairs(petData) do
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_petData.base_conf_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      table.insert(gid, _petData.gid)
      table.insert(petBallIds, _petData.ball_id)
      table.insert(PetFreeList, {
        IconListInfo = _petData.level,
        gid = _petData.gid,
        PetIcon = modelConf,
        IsTeamPet = false,
        PetBasicProperty = petBaseConf.quality
      })
    end
  end
  self.gid = gid
  self.petBallIds = petBallIds
  PetFreeList = self:SortFreePetList(PetFreeList)
  self.Lise:InitList(PetFreeList)
end

function UMG_MiracleExchange_C:SortFreePetList(_PetFreeList)
  table.sort(_PetFreeList, function(a, b)
    if a.PetBasicProperty < b.PetBasicProperty then
      return a.PetBasicProperty < b.PetBasicProperty
    elseif a.PetBasicProperty == b.PetBasicProperty and a.IconListInfo < b.IconListInfo then
      return a.IconListInfo < b.IconListInfo
    elseif a.PetBasicProperty == b.PetBasicProperty and a.IconListInfo == b.IconListInfo and a.gid < b.gid then
      return a.gid < b.gid
    end
  end)
  return _PetFreeList
end

function UMG_MiracleExchange_C:SetType()
  if self.param.type == SceneEnum.MiracleExchangeType.SENDER then
    self.Description:SetText(_G.DataConfigManager:GetLocalizationConf("magic_change_send_text").msg)
    self.Description_1:SetText(self.Description:GetText())
    self.UMG_Btn2_1:SetBtnText(LuaText.umg_miracleexchange_1)
    self.UMG_Btn_0:SetBtnText(LuaText.umg_miracleexchange_2)
    self.Prompt:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.param.type == SceneEnum.MiracleExchangeType.RECEIVE then
    self.Description:SetText(_G.DataConfigManager:GetLocalizationConf("magic_change_receive_text").msg)
    self.Description_1:SetText(self.Description:GetText())
    self.UMG_Btn2_1:SetBtnText(LuaText.umg_miracleexchange_1)
    self.UMG_Btn_0:SetBtnText(LuaText.umg_miracleexchange_2)
    self.Prompt:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Description:SetText(_G.DataConfigManager:GetLocalizationConf("pet_remove_select").msg)
    self.Description_1:SetText(self.Description:GetText())
    self.UMG_Btn2_1:SetBtnText(_G.DataConfigManager:GetLocalizationConf("pet_remove_free").msg)
    self.UMG_Btn2:SetBtnText(_G.DataConfigManager:GetLocalizationConf("pet_remove_magic_change").msg)
    self.Prompt:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule and MainUIModule:HasPanel("GameInfoMain") then
    self.Switcher_Bg:SetActiveWidgetIndex(0)
  else
    self.Switcher_Bg:SetActiveWidgetIndex(1)
  end
end

function UMG_MiracleExchange_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_MiracleExchange_C:OnAddEventListener()
  if self.isAdd then
    return
  end
  self.isAdd = true
  self:AddButtonListener(self.UMG_Btn_0.btnLevelUp, self.OnBtnCancelClick)
  self:AddButtonListener(self.UMG_Btn2.btnLevelUp, self.OnBtnChangeClick)
  self:AddButtonListener(self.UMG_Btn2_1.btnLevelUp, self.OnBtnOkClick)
  self:AddButtonListener(self.btnCloseRenamePanel.btnClose, self.OnBtnCancelClick)
end

function UMG_MiracleExchange_C:OnRemoveEventListener()
  self.isAdd = false
  self:RemoveAllButtonListener()
end

function UMG_MiracleExchange_C:OnBtnChangeClick()
  self.UMG_Btn2:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_MiracleExchange_C:OnBtnChangeClick")
  if self.param.type == SceneEnum.MiracleExchangeType.CHANGE_FREE then
    self:PlayAnimation(self.close_exchange)
  else
    self:PlayAnimation(self.close_confirm)
  end
  if self:CanChangePet() then
    self.TransformToChange = true
  else
    NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_miracleexchange_3)
  end
end

function UMG_MiracleExchange_C:CanChangePet()
  local areaCfg = _G.NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.GetPlayerZoneInfo)
  if nil ~= areaCfg then
    for i, v in ipairs(areaCfg.area_id) do
      local areaConfig = _G.DataConfigManager:GetAreaConf(v)
      if areaConfig.is_visible or 103 ~= areaConfig.scene_id then
        return false
      end
    end
    return true
  end
  return false
end

function UMG_MiracleExchange_C:OnBtnCancelClick()
  self.UMG_Btn_0:SetIsEnabled(false)
  self.btnCloseRenamePanel.btnClose:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_MiracleExchange_C:OnBtnCancelClick")
  if self.param.type == SceneEnum.MiracleExchangeType.CHANGE_FREE then
    self:PlayAnimation(self.close_exchange)
  else
    self:PlayAnimation(self.close_confirm)
  end
end

function UMG_MiracleExchange_C:OnBtnOkClick()
  self.UMG_Btn2_1:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_MiracleExchange_C:OnBtnOkClick")
  if self.param.type == SceneEnum.MiracleExchangeType.CHANGE_FREE then
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetFreePanel, self.param.data)
  elseif self.param.type == SceneEnum.MiracleExchangeType.RECEIVE then
    if self.serveData and self.serveData.recv_miracle_change_times + #self.gid <= self.maxReceive then
      self.serveData.recv_miracle_change_times = self.serveData.recv_miracle_change_times + #self.gid
      NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.SendSceneFinishMiracleChangeReq, self.gid, self.param.npcId, self.petBallIds, self.param.ballId, self.param.npcAction)
    else
      local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
      local Ctx = DialogContext():SetTitle(LuaText.umg_miracleexchange_4):SetContent(_G.DataConfigManager:GetGlobalConfigStrByKey("magic_change_receive_times_text", "")):SetMode(DialogContext.Mode.OK)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
    end
    Log.Dump(self.param.data, 5, "UMG_MiracleExchange_C:OnBtnOkClick")
  elseif self.serveData and self.serveData.send_miracle_change_times + #self.gid <= self.maxSend then
    self.serveData.send_miracle_change_times = self.serveData.send_miracle_change_times + #self.gid
    NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.SendMiracleExchange, self.gid)
  else
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Ctx = DialogContext():SetTitle(LuaText.umg_miracleexchange_4):SetContent(_G.DataConfigManager:GetGlobalConfigStrByKey("magic_change_send_times_text", "")):SetMode(DialogContext.Mode.OK)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  end
  self:DoClose()
end

function UMG_MiracleExchange_C:OnAnimationFinished(Animation)
  if Animation == self.close_exchange or Animation == self.close_confirm then
    self.UMG_Btn2_1:SetIsEnabled(true)
    self.UMG_Btn2:SetIsEnabled(true)
    self.UMG_Btn_0:SetIsEnabled(true)
    self.btnCloseRenamePanel.btnClose:SetIsEnabled(true)
    if self.TransformToChange then
      self.param.type = SceneEnum.MiracleExchangeType.SENDER
      self:OnActive(self.param)
    else
      self:DoClose()
    end
  end
end

return UMG_MiracleExchange_C
