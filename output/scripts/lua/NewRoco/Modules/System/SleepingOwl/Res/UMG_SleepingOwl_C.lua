local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local UMG_SleepingOwl_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_C")

function UMG_SleepingOwl_C:OnActive(_param)
  local insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu")
  self.insufficientText = insufficientText and insufficientText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176"
  self.IconList = {
    self.Icon1,
    self.Icon2
  }
  self.param = _param
  self:SetIconCanClick(false)
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
  self.IconPos = self:CreatIconUIPos()
  self.Timer = 0
  for i = 1, #self.IconPos do
    self.IconList[i].Slot:SetPosition(self.IconPos[i])
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41500001, "UMG_Magic_Nourish_C:OnConstruct")
  self.module:CmdZoneGetOwlSanctuaryFruitInfoReq()
end

function UMG_SleepingOwl_C:OnConstruct()
  self:RegisterEvent(self, SleepingOwlModuleEvent.UpdateTimer, self.OnUpdateIconTimer)
end

function UMG_SleepingOwl_C:CreatIconUIPos()
  local DpiScaleY = 1
  local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  local pos1 = self.param.owlSanctuary.guozi01:Abs_K2_GetComponentLocation()
  local pos2 = self.param.owlSanctuary.guozi02:Abs_K2_GetComponentLocation()
  local ScreenPos1, result1 = playerController:Abs_ProjectWorldLocationToScreen(pos1, nil, true)
  local ScreenPos2, result2 = playerController:Abs_ProjectWorldLocationToScreen(pos2, nil, true)
  local ViewportPos1 = UE4.USlateBlueprintLibrary.ScreenToViewport(self, ScreenPos1)
  local ViewportPos2 = UE4.USlateBlueprintLibrary.ScreenToViewport(self, ScreenPos2)
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), ScreenPos1, ViewportPos1)
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), ScreenPos2, ViewportPos2)
  local dpi = UE4.UWidgetLayoutLibrary.GetViewportScale(UE4Helper.GetCurrentWorld())
  local offset1 = UE4.FVector2D(-100, 80)
  local offset2 = UE4.FVector2D(0, 0)
  local offsetPos1 = ViewportPos1 + offset1
  local offsetPos2 = ViewportPos2 + offset2
  local IconPos = {offsetPos1, offsetPos2}
  return IconPos
end

function UMG_SleepingOwl_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_SleepingOwl_C:SetIconCanClick(canClick)
  for i = 1, #self.IconList do
    self.IconList[i].CanClick = canClick
  end
end

function UMG_SleepingOwl_C:OnAutoSelectItem()
  self:RefreshPanel()
  self:AutoSelectItem()
end

function UMG_SleepingOwl_C:RefreshPanel(RefreshReason)
  self.ContentId = self.module:GetOwlSanctuaryContentId()
  if not self.ContentId then
    self.ContentId = 2701853
  end
  self.OwlSanctuaryConf = _G.DataConfigManager:GetOwlSanctuaryConf(self.ContentId)
  if self.OwlSanctuaryConf.owl_sanctuary_type ~= _G.Enum.OwlSanctuaryType.OST_BIG then
    local offset1 = UE4.FVector2D(85, -20)
    local pos = self.IconPos[1] + offset1
    self.Icon1.Slot:SetPosition(pos)
  end
  local FruitIdList = self.module:GetFruitIdList()
  if nil == FruitIdList then
    FruitIdList = {}
  end
  local FruitCount = #FruitIdList
  if self.OwlSanctuaryConf then
    for i = 1, #self.IconList do
      if i > self.OwlSanctuaryConf.slot_num then
        self.IconList[i]:Init(false, nil, i - 1)
        self.IconList[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.IconList[i]:Init(true, nil, i - 1)
        self.IconList[i]:SetVisibility(UE4.ESlateVisibility.Visible)
      end
      for j = 1, FruitCount do
        if FruitIdList[j].pos + 1 == i then
          self.IconList[i]:Init(true, FruitIdList[j], FruitIdList[j].pos)
        end
      end
    end
  else
    Log.Error("\232\175\187\229\143\150OwlSanctuaryConf\229\164\177\232\180\165 \231\173\150\229\136\146\229\164\167\228\189\172\232\175\183\230\163\128\230\159\165\230\152\175\229\144\166\229\173\152\229\156\168ID", self.ContentId)
  end
  if -1 ~= self.module.selectIndex then
    for i = 1, 2 do
      if self.IconList[i].index == self.module.selectIndex then
        if RefreshReason then
          if 1 == RefreshReason then
            self.IconList[i]:PlayAnimation(self.IconList[i].Add_Icon)
          end
          if 2 == RefreshReason then
            self.IconList[i]:PlayAnimation(self.IconList[i].Delete_Icon)
          end
        end
        _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlFruitPanel, self.IconList[i].data, self.IconList[i].index)
        break
      end
    end
  end
end

function UMG_SleepingOwl_C:OnUpdateIconTimer()
  for i = 1, #self.IconList do
    self.IconList[i]:OnUpdateIconTimer()
  end
end

function UMG_SleepingOwl_C:AutoSelectItem()
  if self.isAutoSelectEd then
    return
  end
  self.isAutoSelectEd = true
  self:SetIconCanClick(true)
  self.module.selectIndex = 0
  local isSelect = false
  for i = 1, #self.IconList do
    if self.IconList[i].UnLock and not self.IconList[i].data then
      self.module.selectIndex = self.IconList[i].index
      self.IconList[i].NeedAudio = false
      self.IconList[i]:OnTouchEnded()
      isSelect = true
      break
    end
  end
  if not isSelect then
    self.module.selectIndex = self.IconList[1].index
    self.IconList[1].NeedAudio = false
    self.IconList[1]:OnTouchEnded()
  end
end

function UMG_SleepingOwl_C:OnTick(DeltaTime)
end

function UMG_SleepingOwl_C:OnAddEventListener()
  self:RegisterEvent(self, SleepingOwlModuleEvent.ShowCloseOwlBtn, self.ShowCloseBtn)
  self:RegisterEvent(self, SleepingOwlModuleEvent.EmptySlotTimeout, self.EmptySlotTimeout)
  self:RegisterEvent(self, SleepingOwlModuleEvent.AutoSelectItem, self.OnAutoSelectItem)
end

function UMG_SleepingOwl_C:EmptySlotTimeout(index)
  self.IconList[index]:ShowUnlockSlot()
end

function UMG_SleepingOwl_C:RefreshSelectIcon(index)
  for i = 1, #self.IconList do
    if index + 1 ~= i then
      self.IconList[i]:SetCancelSelect()
    end
  end
end

function UMG_SleepingOwl_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, SleepingOwlModuleEvent.ShowCloseOwlBtn)
  self:UnRegisterEvent(self, SleepingOwlModuleEvent.UpdateTimer)
  self:UnRegisterEvent(self, SleepingOwlModuleEvent.AutoSelectItem)
end

function UMG_SleepingOwl_C:ShowCloseBtn(isClose)
  if isClose then
    self:ClosePanel()
  end
end

function UMG_SleepingOwl_C:OnLevelUp()
  Log.Debug("UMG_Magic_Nourish_C:OnLevelUp")
  self:PlayLevelUpAnim()
end

function UMG_SleepingOwl_C:PlayLevelUpEffectBegin()
  self:RefreshPanel(nil)
end

function UMG_SleepingOwl_C:PlayLevelUpEffectEnd()
end

function UMG_SleepingOwl_C:LevelUpAnimComplete()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1302, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  self:PlayAnimation(self.In)
end

function UMG_SleepingOwl_C:OnCloseBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_Magic_Nourish_C:OnCloseBtnClick")
  if self:IsAnimationPlaying(self.In) or self:IsAnimationPlaying(self.Out) then
    return
  end
  self:ClosePanel()
end

function UMG_SleepingOwl_C:ClosePanel()
  self.isRealClosed = true
  self.module:CloseUpdate()
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlHint1Panel)
  _G.NRCAudioManager:PlaySound2DAuto(1076, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.Out)
end

function UMG_SleepingOwl_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if self.isRealClosed then
    else
      self:SetIconCanClick(false)
    end
    if self.param.action then
      self.param.action:EndAction()
      self.param.action = nil
    end
    self:DoClose()
  end
  if anim == self.In then
    self:SetIconCanClick(true)
  end
end

function UMG_SleepingOwl_C:GetCampingMaxLvAndCfg(ContentId, ContentLv)
  local maxLv = 1
  local campingLvTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF)
  local campLvCfgs = campingLvTable:GetAllDatas()
  local CampingLvUpCfg
  for k, v in ipairs(campLvCfgs) do
    if v.content_id == ContentId and maxLv < v.level then
      maxLv = v.level
    end
    if v.content_id == ContentId and v.level == ContentLv then
      CampingLvUpCfg = v
    end
  end
  local OwlSanctuaryConf = _G.DataConfigManager:GetOwlSanctuaryConf(ContentId)
  return maxLv, OwlSanctuaryConf, CampingLvUpCfg
end

return UMG_SleepingOwl_C
