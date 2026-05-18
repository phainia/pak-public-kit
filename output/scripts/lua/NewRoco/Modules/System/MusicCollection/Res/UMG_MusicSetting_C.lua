local MusicCollectionModuleEvent = require("NewRoco.Modules.System.MusicCollection.MusicCollectionModuleEvent")
local UMG_MusicSetting_C = _G.NRCPanelBase:Extend("UMG_MusicSetting_C")

function UMG_MusicSetting_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
end

function UMG_MusicSetting_C:OnDestruct()
end

function UMG_MusicSetting_C:OnActive(MusicId, ApplyList, ApplyPanelId)
  self.data = self.module:GetData("MusicCollectionModuleData")
  self.MusicId = MusicId
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo()
  self:OnAddEventListener()
  if ApplyPanelId and ApplyPanelId > 0 then
    self.LastApplyConf = _G.DataConfigManager:GetMusicApplyListConf(ApplyPanelId)
  end
  local ApplyTempList = {}
  local SelectIndex
  
  local function SortApplyList(a, b)
    local ApplyConfA = _G.DataConfigManager:GetMusicApplyListConf(a)
    local ApplyConfB = _G.DataConfigManager:GetMusicApplyListConf(b)
    return (ApplyConfA.list_sort or 0) < (ApplyConfB.list_sort or 0)
  end
  
  table.sort(ApplyList, SortApplyList)
  for i = 1, #ApplyList do
    local Find = self:IsApplyAnyMusic(ApplyList[i])
    if ApplyList[i] == ApplyPanelId then
      SelectIndex = i - 1
    end
    table.insert(ApplyTempList, {
      id = ApplyList[i],
      IsSet = Find
    })
  end
  self.Gender:InitGridView(ApplyTempList)
  if SelectIndex then
    self.skipAudio = true
    self.Gender:SelectItemByIndex(SelectIndex)
  end
  self:AddPcInputBlock()
end

function UMG_MusicSetting_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftText = _G.LuaText.music_set_btn_affirm_close
  CommonPopUpData.Btn_RightText = _G.LuaText.music_set_affirm_btn_set
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnOk
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_MusicSetting_C:OnDeactive()
  self:RemovePcInputBlock()
end

function UMG_MusicSetting_C:AddPcInputBlock()
end

function UMG_MusicSetting_C:RemovePcInputBlock()
end

function UMG_MusicSetting_C:OpenDialogTips(CurrentMusicApplyPanelName, CurrentMusic, SelectApplyPanelName, OpenType)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local ContentText = ""
  if 1 == OpenType then
    ContentText = string.format(LuaText.music_set_affirm_text1, CurrentMusic, SelectApplyPanelName)
  elseif 2 == OpenType then
    ContentText = string.format(LuaText.music_set_interface_text2, CurrentMusic, SelectApplyPanelName, CurrentMusicApplyPanelName)
  elseif 3 == OpenType then
    ContentText = string.format(LuaText.music_set_interface_text3, CurrentMusic, SelectApplyPanelName, CurrentMusicApplyPanelName)
  elseif 4 == OpenType then
    ContentText = string.format(LuaText.music_set_cancel_affirm, CurrentMusicApplyPanelName)
  end
  
  local function SetMusic()
    _G.NRCModuleManager:DoCmd(MusicCollectionModuleCmd.SetMusicToPanel, self.MusicId, self.ApplyId)
    self:DoClose()
  end
  
  if 4 == OpenType then
    function SetMusic()
      _G.NRCModuleManager:DoCmd(MusicCollectionModuleCmd.SetMusicToPanel, self.MusicId, nil)
      
      self:DoClose()
    end
  end
  Context:SetTitle(LuaText.umg_systemsettingmain_4):SetContent(ContentText):SetMode(DialogContext.Mode.OK_CANCEL):SetCallbackOkOnly(self, SetMusic):SetCloseOnCancel(true):SetCloseOnOK(true):SetButtonText(LuaText.umg_systemsettingmain_5, LuaText.umg_systemsettingmain_6):SetClickAnywhereClose(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_MusicSetting_C:OnSelectedItemIndex(ApplyId)
  if self.skipAudio then
    self.skipAudio = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  end
  if ApplyId then
    self.ApplyId = ApplyId
    self.CurrentApplyConf = _G.DataConfigManager:GetMusicApplyListConf(ApplyId)
    self.IsApplyMusic = self:IsApplyAnyMusic(ApplyId)
    if self.LastApplyConf and self.ApplyId == self.LastApplyConf.id then
      self.PopUp2:SetBtnRightText(_G.LuaText.music_set_affirm_btn_cancel)
    else
      self.PopUp2:SetBtnRightText(_G.LuaText.music_set_affirm_btn_set)
    end
  end
end

function UMG_MusicSetting_C:IsApplyAnyMusic(ApplyId)
  for i = 1, #self.data.MusicList do
    local List = self.data.MusicList[i].List
    for j = 1, #List do
      if ApplyId == List[j].ApplyId then
        return true
      end
    end
  end
  return false
end

function UMG_MusicSetting_C:OnOk()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  if self.LastApplyConf and self.ApplyId == self.LastApplyConf.id then
    self:OpenDialogTips(self.LastApplyConf.list_name, nil, nil, 4)
    return
  end
  if not self.ApplyId then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2313)
    return
  end
  if not self.LastApplyConf and not self.IsApplyMusic then
    _G.NRCModuleManager:DoCmd(MusicCollectionModuleCmd.SetMusicToPanel, self.MusicId, self.ApplyId)
    self:DoClose()
  elseif not self.LastApplyConf and self.IsApplyMusic then
    local musicConf = _G.DataConfigManager:GetMusicConf(self.MusicId)
    self:OpenDialogTips(nil, musicConf.music_name, self.CurrentApplyConf.list_name, 1)
  elseif self.LastApplyConf and not self.IsApplyMusic then
    local musicConf = _G.DataConfigManager:GetMusicConf(self.MusicId)
    self:OpenDialogTips(self.LastApplyConf.list_name, musicConf.music_name, self.CurrentApplyConf.list_name, 2)
  elseif self.LastApplyConf and self.IsApplyMusic then
    local musicConf = _G.DataConfigManager:GetMusicConf(self.MusicId)
    self:OpenDialogTips(self.LastApplyConf.list_name, musicConf.music_name, self.CurrentApplyConf.list_name, 3)
  end
end

function UMG_MusicSetting_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_MusicSetting_C:OnCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
end

function UMG_MusicSetting_C:OnAddEventListener()
  self:RegisterEvent(self, MusicCollectionModuleEvent.SetMusicOption, self.OnSelectedItemIndex)
end

function UMG_MusicSetting_C:OnPcClose()
  self:OnCancel()
end

return UMG_MusicSetting_C
