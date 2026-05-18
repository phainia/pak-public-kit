local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MusicCollectionModuleEvent = require("NewRoco.Modules.System.MusicCollection.MusicCollectionModuleEvent")
local UMG_MusicList_C = Base:Extend("UMG_MusicList_C")

function UMG_MusicList_C:OnConstruct()
end

function UMG_MusicList_C:OnDestruct()
end

function UMG_MusicList_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self.SystemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local musicCollectionModule = _G.NRCModuleManager:GetModule("MusicCollectionModule")
  local musicCollectionPanel = musicCollectionModule:GetPanel("MusicCollectionPanel")
  if musicCollectionPanel then
    self.OpenType = musicCollectionPanel.OpenType
    self.InMusicId = musicCollectionPanel.InMusicId
  end
  self:SetInfo()
end

function UMG_MusicList_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:SetOnNewStateRemove()
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_in)
    _G.NRCModuleManager:GetModule("MusicCollectionModule"):DispatchEvent(MusicCollectionModuleEvent.ChangeItem, self.MusicConf, self.ApplyConf)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_out)
  end
end

function UMG_MusicList_C:SetOnNewStateRemove()
  if self.NrcRedPoint and self.NrcRedPoint:IsRed() then
    self.NrcRedPoint:EraseRedPoint()
  end
end

function UMG_MusicList_C:OnAnimationFinished(anim)
end

function UMG_MusicList_C:SetApplyRefreshInfo(MusicApplyInfo)
  if self.uiData.id == MusicApplyInfo.music_id then
    if MusicApplyInfo.apply_list_id then
      self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ApplyConf = _G.DataConfigManager:GetMusicApplyListConf(MusicApplyInfo.apply_list_id)
      self.uiData.ApplyId = self.ApplyConf.id
      self.Text:SetText(self.ApplyConf.list_name)
    else
      self.ApplyConf = nil
      self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif MusicApplyInfo.apply_list_id and MusicApplyInfo.apply_list_id == self.uiData.ApplyId then
    self.ApplyConf = nil
    self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_MusicList_C:SetInfo()
  self.MusicConf = _G.DataConfigManager:GetMusicConf(self.uiData.id)
  if self.OpenType == "MagicMessage" then
    if self.uiData.id == self.InMusicId then
      self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Text:SetText(LuaText.magic_message_music_selection)
    else
      self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    if self.uiData.ApplyId then
      self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ApplyConf = _G.DataConfigManager:GetMusicApplyListConf(self.uiData.ApplyId)
      self.Text:SetText(self.ApplyConf.list_name)
    else
      self.ApplyConf = nil
      self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.NrcRedPoint:SetupKey(293, {
      self.MusicConf.music_type,
      self.MusicConf.id
    })
  end
  self.Name:SetText(self.MusicConf.music_name)
  self.Bg:SetPath(self.MusicConf.music_img_path)
end

function UMG_MusicList_C:OnDeactive()
end

return UMG_MusicList_C
