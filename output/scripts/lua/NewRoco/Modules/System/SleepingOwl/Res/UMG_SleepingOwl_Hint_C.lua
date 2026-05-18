local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local UMG_SleepingOwl_Hint_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_Hint_C")

function UMG_SleepingOwl_Hint_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_SleepingOwl_Hint_C:OnDestruct()
  self:CancelDelay()
end

function UMG_SleepingOwl_Hint_C:OnActive(CampFruitItemData, FruitData, index, IsPutIn)
  _G.NRCAudioManager:PlaySound2DAuto(1002, "CampingModule:OpenNourishRightFruit")
  self.IsPutIn = IsPutIn
  local bagItemConf, petBaseInfo
  self:SetCommonPopUpInfo(self.PopUp4)
  if IsPutIn then
    if FruitData then
      self.data = FruitData
      bagItemConf = _G.DataConfigManager:GetBagItemConf(FruitData.BagItem.id)
      petBaseInfo = _G.DataConfigManager:GetPetbaseConf(FruitData.PetBaseId)
    end
  else
    self.data = CampFruitItemData
    if CampFruitItemData then
      bagItemConf = _G.DataConfigManager:GetBagItemConf(CampFruitItemData.BagItemId)
      petBaseInfo = _G.DataConfigManager:GetPetbaseConf(CampFruitItemData.PetBaseId)
    end
  end
  if self.IsPutIn then
    local slotTimer = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetEmptyTimer, index + 1)
    local fruitTimer = 0
    if FruitData and FruitData.BagItem and FruitData.BagItem.fruit_active_timestamp then
      fruitTimer = self.module:GetActiveCountdown(FruitData.BagItem.fruit_active_timestamp)
    end
    if 0 == slotTimer and 0 == fruitTimer then
      self.textBuffDesc:SetText(LuaText.put_slot_0_fruit_0)
    elseif 0 == slotTimer and fruitTimer > 0 then
      self:GetHoursAndMinutes(fruitTimer, LuaText.put_slot_0_fruit_1)
      self:SetTimeDownText(fruitTimer, LuaText.put_slot_0_fruit_1)
    elseif slotTimer > 0 and 0 == fruitTimer then
      self:GetHoursAndMinutes(slotTimer, LuaText.put_slot_1_fruit_0)
      self:SetTimeDownText(slotTimer, LuaText.put_slot_1_fruit_0)
    elseif slotTimer < fruitTimer then
      self:GetHoursAndMinutes(fruitTimer, LuaText.put_slot_0_fruit_1)
      self:SetTimeDownText(fruitTimer, LuaText.put_slot_0_fruit_1)
    elseif slotTimer > fruitTimer then
      self:GetHoursAndMinutes(slotTimer, LuaText.put_slot_1_fruit_0)
      self:SetTimeDownText(slotTimer, LuaText.put_slot_1_fruit_0)
    else
      self:GetHoursAndMinutes(slotTimer, LuaText.put_slot_1_fruit_0)
      self:SetTimeDownText(slotTimer, LuaText.put_slot_1_fruit_0)
    end
  else
    self.textBuffDesc:SetText(LuaText.pick_pet_fruit)
  end
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_SleepingOwl_Hint_C:GetHoursAndMinutes(Time, Text)
  local hours = math.floor(Time / 60 / 60)
  local minutes = math.floor((Time - hours * 3600) / 60)
  local seconds = Time - hours * 3600 - minutes * 60
  local timeStr = ""
  if hours > 0 then
    timeStr = string.format(LuaText.cd_hour, hours, minutes)
  elseif 0 == hours and minutes > 0 then
    timeStr = string.format(LuaText.cd_minute, minutes, seconds)
  elseif 0 == hours and 0 == minutes then
    timeStr = string.format(LuaText.cd_second, seconds)
  end
  self.textBuffDesc:SetText(string.format(Text, timeStr))
  return hours, minutes, timeStr
end

function UMG_SleepingOwl_Hint_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancelBtnClick
  CommonPopUpData.Btn_RightHandler = self.OnOKBtnClick
  CommonPopUpData.ClosePanelHandler = self.OnCancelBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_SleepingOwl_Hint_C:SetTimeDownText(time, Text)
  self.curTimer = time
  self.curText = Text
  self:OnUpdateText()
end

function UMG_SleepingOwl_Hint_C:OnUpdateText()
  self:GetHoursAndMinutes(self.curTimer, self.curText)
  self.curTimer = self.curTimer - 1
  if self.curTimer <= 0 then
    self.curTimer = 0
    self:CancelDelay()
    self:GetHoursAndMinutes(self.curTimer, self.curText)
    return
  end
  self:DelaySeconds(1, function()
    self:OnUpdateText()
  end)
end

function UMG_SleepingOwl_Hint_C:OnDeactive()
  self:RemoveEventListener()
end

function UMG_SleepingOwl_Hint_C:OnAddEventListener()
end

function UMG_SleepingOwl_Hint_C:RemoveEventListener()
end

function UMG_SleepingOwl_Hint_C:OnOKBtnClick()
  if self.data ~= nil then
    if self.IsPutIn then
      self.module:EquipPutFruitInOwlSanctuary()
    else
      self.module:UnEquipPutFruitInOwlSanctuary(self.data.BagItemId, self.data.gid)
    end
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_SleepingOwl_Hint_C:OnOKBtnClick")
  self:LoadAnimation(2)
end

function UMG_SleepingOwl_Hint_C:OnCancelBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_SleepingOwl_Hint_C:OnCancelBtnClick")
  self:LoadAnimation(2)
end

function UMG_SleepingOwl_Hint_C:OnPcClose()
  if self:IsPlayingAnimation() then
    return
  end
  self:OnCancelBtnClick()
end

function UMG_SleepingOwl_Hint_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_SleepingOwl_Hint_C
