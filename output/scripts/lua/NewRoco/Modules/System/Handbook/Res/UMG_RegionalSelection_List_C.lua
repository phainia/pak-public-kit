local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RegionalSelection_List_C = Base:Extend("UMG_RegionalSelection_List_C")

function UMG_RegionalSelection_List_C:OnConstruct()
end

function UMG_RegionalSelection_List_C:OnDestruct()
end

function UMG_RegionalSelection_List_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.areaInfo = nil
  if _data then
    local conf = _data.conf
    self.Text:SetText(conf.name)
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#47463CFF"))
    self.Bg:SetPath(conf.book_res)
    self.Dot:SetupKey(126, {
      conf.area_handbook_type
    })
    self.areaInfo = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetAreaHandbookInfo, conf.area_handbook_type)
    local collStr = ""
    if self.areaInfo then
      collStr = string.format("%s/", self.areaInfo.collect_coll_num)
    end
    local maxCount = self:GetMaxCount(conf.area_handbook_type)
    self.ProgressText1:SetText(collStr)
    self.ProgressText1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#47463CFF"))
    self.ProgressText2:SetText(maxCount)
    self.ProgressText2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#47463CFF"))
    local curSelectAreaId = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetCurAreaHandbookId)
    if curSelectAreaId == conf.id then
      self:PlayDefaultSelectAnimation()
    end
    if 2 == index then
      self.Bg:SetRenderTransformAngle(2.14)
      self.Bg_1:SetRenderTransformAngle(2.14)
      self.Bg_Mask:SetRenderTransformAngle(2.14)
    elseif 4 == index then
      self.Bg:SetRenderTransformAngle(5.31)
      self.Bg_1:SetRenderTransformAngle(5.31)
      self.Bg_Mask:SetRenderTransformAngle(5.31)
    elseif 1 == index then
      self.Bg:SetRenderTransformAngle(-2.2)
      self.Bg_1:SetRenderTransformAngle(-2.2)
      self.Bg_Mask:SetRenderTransformAngle(-2.2)
    elseif 3 == index then
      self.Bg:SetRenderTransformAngle(-1.48)
      self.Bg_1:SetRenderTransformAngle(-1.48)
      self.Bg_Mask:SetRenderTransformAngle(-1.48)
    end
    local isBan = true
    if 0 == conf.enter_ban_id then
      isBan = false
    else
      local banConf = _G.DataConfigManager:GetUiEnterBanConf(conf.enter_ban_id)
      local banType = banConf.function_entrance
      isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, banType, false)
    end
    if isBan then
      self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Text:SetText(LuaText.lock_area_handbook_2)
    else
      self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_RegionalSelection_List_C:PlayDefaultSelectAnimation()
  self.Text:SetText(self.data.conf.name)
  self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#E7DAC0FF"))
  self.ProgressText1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#E7DAC0FF"))
  self.ProgressText2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#E7DAC0FF"))
  self:PlayAnimation(self.Click_loop, 0, 0)
end

function UMG_RegionalSelection_List_C:GetMaxCount(type)
  local HandBookConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_HANDBOOK)
  local count = 0
  if HandBookConf then
    local confs = HandBookConf:GetAllDatas()
    for key, conf in pairs(confs) do
      for i = 1, #conf.belong_area_handbook do
        if type == conf.belong_area_handbook[i] then
          count = count + 1
        end
      end
    end
  end
  return count
end

function UMG_RegionalSelection_List_C:OnItemSelected(_bSelected)
  if _bSelected then
    local isBan = true
    local banId = self.data.conf.enter_ban_id
    if self.data.conf.enter_ban_id == nil or 0 == self.data.conf.enter_ban_id then
      isBan = false
    else
      local banConf = _G.DataConfigManager:GetUiEnterBanConf(banId)
      isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, banConf.function_entrance, true)
    end
    if not isBan then
      _G.NRCAudioManager:PlaySound2DAuto(1237, "UMG_RegionalSelection_List_C:OnItemSelected")
      _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SelectAreaItem, self.data)
      self:PlayAnimation(self.Click)
      self.Text:SetText(self.data.conf.name)
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#E7DAC0FF"))
      self.ProgressText1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#E7DAC0FF"))
      self.ProgressText2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#E7DAC0FF"))
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401015, "UMG_RegionalSelection_List_C:OnItemSelected")
    end
  end
end

function UMG_RegionalSelection_List_C:UnSelectItem(data)
  if data.conf.area_handbook_type ~= self.data.conf.area_handbook_type then
    self:StopAllAnimations()
    self:PlayAnimation(self.Normal)
    self.Text:SetText(self.data.conf.name)
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#47463CFF"))
    self.ProgressText1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#47463CFF"))
    self.ProgressText2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#47463CFF"))
  end
end

function UMG_RegionalSelection_List_C:OnAnimationFinished(anim)
  if anim == self.Click then
    self:PlayAnimation(self.Click_loop, 0)
  end
end

function UMG_RegionalSelection_List_C:OnDeactive()
end

return UMG_RegionalSelection_List_C
