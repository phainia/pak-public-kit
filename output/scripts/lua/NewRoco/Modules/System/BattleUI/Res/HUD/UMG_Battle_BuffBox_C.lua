local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ProtoEnum = require("Data.PB.ProtoEnum")
local UMG_Battle_BuffBox_C = NRCClass:Extend("UMG_Battle_BuffBox_C")
local ShowOnlyOneBuffTypeList = {
  ProtoEnum.BuffType.BFT_O_THIRTYTWO
}

function UMG_Battle_BuffBox_C:Construct()
  self.battleManager = _G.BattleManager
  self.buffs = {}
  self.buffsRef = {}
  self.buffInfos = {}
  self.realShowBuffCount = 0
  setmetatable(self.buffs, {__mode = "k"})
  self:OnAddEventListener()
  if not self.pet then
    local allPets = self.battleManager.battlePawnManager:GetAllPets()
    for _, pet in ipairs(allPets) do
      if pet.battlePetComponents and (pet.battlePetComponents.BuffBoxWidget == self or pet.battlePetComponents.BuffBox2DWidget == self) then
        self.pet = pet
        break
      end
    end
  end
  if self.pet then
    self:RefreshBuff(self.pet)
  end
end

function UMG_Battle_BuffBox_C:Destruct()
  self.pet = nil
  local allBuffs = {}
  for buff, v in pairs(self.buffs) do
    table.insert(allBuffs, buff)
  end
  if self.buffsRef then
    for index, buffMode in pairs(self.buffsRef) do
      if buffMode and UE.UObject.IsValid(buffMode) then
        UnLua.Unref(buffMode)
      end
      self.buffsRef[index] = nil
    end
  end
  for _, buff in ipairs(allBuffs) do
    self:RemoveBuff(buff, true)
  end
  allBuffs = nil
  self:OnRemoveEventListener()
  self.battleManager = nil
  table.clear(self.buffs)
  self.buffs = nil
  self.buffInfos = nil
  self.buffsRef = nil
  self.realShowBuffCount = 0
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_BuffBox_C:OnAddEventListener()
  BattleEventCenter:Bind(self, BattlePerformEvent.BuffChange, BattleEvent.REFRESH_BUFF, BattleEvent.REMOVE_BUFF)
  self.BtnDetails.OnClicked:Add(self, self.onBtnBuffClick)
end

function UMG_Battle_BuffBox_C:SetShowType(type)
  self.ShowType = type
  self:RefreshUIByShowType()
end

function UMG_Battle_BuffBox_C:RefreshUIByShowType()
  if not self.ShowType or self.ShowType == _G.BattleConst.BuffIconShowType.None then
    self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCImage_38:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif self.ShowType == _G.BattleConst.BuffIconShowType.WorldUI then
    if self.btnDetailsState then
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.NRCImage_38:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtn then
    if self.btnDetailsState then
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.NRCImage_38:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtnAndUI then
    if self.btnDetailsState then
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.NRCImage_38:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Battle_BuffBox_C:CheckBtnDetailsShow(state)
  self.btnDetailsState = state
  if state then
    self:RefreshUIByShowType()
  else
    self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_BuffBox_C:OnRemoveEventListener()
  BattleEventCenter:UnBind(self)
  self.BtnDetails.OnClicked:Remove(self, self.onBtnBuffClick)
end

function UMG_Battle_BuffBox_C:BindPet(pet)
  self.pet = pet
end

function UMG_Battle_BuffBox_C:RefreshAttachingPivotScale(model, widgetScale)
  do return end
  if not model then
    return
  end
  local CapsuleComponent = model:GetComponentByClass(UE4.UCapsuleComponent)
  local radius = 50
  if CapsuleComponent then
    radius = CapsuleComponent:GetScaledCapsuleRadius()
  end
  radius = radius * 4 / 5
  self.sourcePos = self.BuffListingBox.Slot:GetPosition()
  if self.ShowType == _G.BattleConst.BuffIconShowType.WorldUI then
    self.BuffListingBox.Slot:SetPosition(UE4.FVector2D(radius, self.sourcePos.Y))
  else
    self.BuffListingBox.Slot:SetPosition(UE4.FVector2D(radius, self.sourcePos.Y))
  end
end

function UMG_Battle_BuffBox_C:OnBattleEvent(eventName, ...)
  if eventName == BattlePerformEvent.BuffChange and self.pet then
    local arg = {
      ...
    }
    local battlePet = arg[1]
    local buffChangeType = arg[2]
    local buff = arg[3]
    local syncData = arg[4]
    if self.pet == battlePet then
      if buffChangeType == ProtoEnum.BuffChangeType.BCT_ADD then
        self:AddBuff(buff, syncData)
      elseif buffChangeType == ProtoEnum.BuffChangeType.BCT_CHANGE then
        self:ChangeBuff(buff, syncData)
      elseif buffChangeType == ProtoEnum.BuffChangeType.BCT_REMOVE then
        self:RemoveBuff(buff, syncData)
      end
    end
    return true
  elseif eventName == BattleEvent.REFRESH_BUFF then
    self:RefreshBuff(...)
    return true
  elseif eventName == BattleEvent.REMOVE_BUFF then
    self:RemoveBuffs(...)
    return true
  end
end

function UMG_Battle_BuffBox_C:RefreshBuff(battlePet)
  if self.pet == battlePet then
    local buffs = battlePet.buffComponent.buffs
    if buffs then
      for k, v in ipairs(buffs or {}) do
        self:BuffHelper(v, k)
      end
    end
    for m, _ in pairs(self.buffs or {}) do
      local found = false
      for _, o in ipairs(buffs or {}) do
        if m.id == o.id then
          found = true
          break
        end
      end
      if not found then
        self:RemoveBuff(m, false)
      end
    end
  end
end

function UMG_Battle_BuffBox_C:BuffHelper(buffInfo, pos)
  if self.buffs[buffInfo] then
    local buffModel = self.buffs[buffInfo]
    local stackPre = buffModel.stack
    if stackPre > buffInfo.stack then
      self:ChangeBuff(buffInfo, false)
    elseif stackPre < buffInfo.stack then
      self:ChangeBuff(buffInfo, true)
    else
      self:ChangeBuff(buffInfo)
    end
  else
    self:AddBuff(buffInfo, pos)
  end
end

function UMG_Battle_BuffBox_C:AddBuff(buff, pos)
  if not self.pet then
    return
  end
  local isMimic, MimicType = self.pet.card:CheckIsMimic()
  if isMimic and MimicType == ProtoEnum.BuffGroupSign.BGS_BATTLE_MIMIC then
    return
  end
  if not buff:NeedShow() then
    return
  end
  local asset = _G.BattleResourceManager:GetCacheAssetDirect(_G.UEPath.UMG_Battle_Buff, true)
  if asset then
    self:LoadBuffOver(asset, buff, pos)
  else
    _G.BattleResourceManager:LoadResAsyncWithParam(self, _G.UEPath.UMG_Battle_Buff, self.LoadBuffOver, nil, buff, pos)
  end
end

function UMG_Battle_BuffBox_C:LoadBuffOver(res, buff, pos)
  if not self.pet then
    return
  end
  if not UE.UObject.IsValid(self.BuffListingBox) then
    return
  end
  buff = self.pet.buffComponent:GetBuff(buff.id)
  if buff and buff.buffInfo then
    for m, _ in pairs(self.buffs) do
      if m.id == buff.id then
        self:ChangeBuff(buff)
        return
      end
    end
    local buffType = buff:GetBuffBaseOrder()
    if table.contains(ShowOnlyOneBuffTypeList, buffType) then
      local sameTypeBuffs = self:GetBuffInfosByType(buffType)
      if #sameTypeBuffs > 0 then
        return
      end
    end
    local buffModel = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), res)
    buffModel:SetBuffInfo(buff)
    buffModel:SetShowType(self.ShowType)
    buffModel:UpdateStack(buff:GetShowStack(), true)
    buffModel:UpdateBurial(buff)
    buffModel:UpdateCornerIcon()
    local Slot = self.BuffListingBox:InsertChildToHorizontalBox(pos - 1, buffModel)
    local Padding = UE4.FMargin()
    Padding.Left = 0
    Padding.Top = 0
    Padding.Right = -20
    Padding.Bottom = 0
    Slot:SetPadding(Padding)
    if buffModel.btnBuff and buffModel.btnBuff.OnClicked then
      buffModel.btnBuff.OnClicked:Add(self, self.onBtnBuffClick)
    else
      Log.Error("zgx onclick is nil , this is weird!!!")
    end
    buffModel:TriggerConstructAnimation()
    local buffIconPath = buff.config.icon
    buffModel:ChangeIcon(buffIconPath)
    local NeedShow = buff:NeedShow()
    buffModel:SetShowState(NeedShow)
    self.buffs[buff] = buffModel
    self.buffsRef[buff] = UnLua.Ref(buffModel)
    if NeedShow then
      self:RefreshBuffModeShow()
      self.realShowBuffCount = self.realShowBuffCount + 1
    end
    table.insert(self.buffInfos, math.min(pos, #self.buffInfos + 1), buff)
  end
end

function UMG_Battle_BuffBox_C:RefreshBuffModeShow()
  local childNum = self.BuffListingBox:GetChildrenCount()
  local canShowNum = _G.DataConfigManager:GetBattleGlobalConfig("buff_list_show_num").num
  local curShowNum = 0
  local willShowNum = 0
  local lastBuffMode
  local Padding = UE4.FMargin()
  Padding.Left = 0
  Padding.Top = 0
  Padding.Right = -20
  Padding.Bottom = 0
  for index = 0, childNum do
    local buffMode = self.BuffListingBox:GetChildAt(index)
    if buffMode then
      local isExist = buffMode:GetNeedShow() and self.buffs[buffMode.buff]
      if isExist then
        willShowNum = willShowNum + 1
      end
      if isExist and canShowNum > curShowNum then
        curShowNum = curShowNum + 1
        buffMode:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        lastBuffMode = buffMode
        buffMode.Slot:SetPadding(Padding)
      else
        buffMode:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  if lastBuffMode then
    Padding.Right = -14
    lastBuffMode.Slot:SetPadding(Padding)
  end
  if canShowNum < willShowNum then
    self:CheckBtnDetailsShow(true)
  else
    self:CheckBtnDetailsShow(false)
  end
end

function UMG_Battle_BuffBox_C:RefreshVisible()
  if self.pet and self.pet.battlePetComponents then
    self.pet.battlePetComponents:AfterRemoveBuffVisible()
  end
end

function UMG_Battle_BuffBox_C:ChangeBuff(buff, isAdd)
  if self.buffs[buff] then
    local buffModel = self.buffs[buff]
    local Conf = _G.DataConfigManager:GetBuffConf(buff.id)
    local buffIconPath = Conf.icon
    local stackPre = buffModel.stack
    buffModel:SetBuffInfo(buff)
    local newStack = buff:GetShowStack()
    buffModel:UpdateStack(newStack, false)
    buffModel:UpdateBurial(buff)
    buffModel:UpdateCornerIcon()
    buffModel:ChangeIcon(buffIconPath)
    local NeedShow = buff:NeedShow()
    buffModel:SetShowState(NeedShow)
    if NeedShow then
      self:RefreshBuffModeShow()
    end
    if nil == isAdd then
      buffModel:UpdateStackDisplay(newStack)
      return
    elseif stackPre > buffModel.stack then
      buffModel:OnTriggerNumberChange(false)
    elseif stackPre < buffModel.stack then
      buffModel:OnTriggerNumberChange(true)
    end
  end
end

function UMG_Battle_BuffBox_C:RemoveBuff(buff, immediate)
  if self.buffs[buff] then
    local buffModel = self.buffs[buff]
    if buffModel.btnBuff and buffModel.btnBuff.OnClicked then
      buffModel.btnBuff.OnClicked:Remove(self, self.onBtnBuffClick)
    else
      Log.Error("zgx onclick is nil , this is weird!!!")
    end
    buffModel.call = nil
    buffModel.caller = nil
    self.buffs[buff] = nil
    local buffMode = self.buffsRef[buff]
    if buffMode and UE.UObject.IsValid(buffMode) then
      UnLua.Unref(buffMode)
    end
    self.buffsRef[buff] = nil
    local visState = buffModel:GetVisibility()
    if visState == UE4.ESlateVisibility.Hidden or visState == UE4.ESlateVisibility.Collapsed then
      buffModel:Remove(true, self, self.RemoveBuffCallBack)
    else
      buffModel:Remove(immediate, self, self.RemoveBuffCallBack)
    end
    local NeedShow = buff:NeedShow()
    if NeedShow then
      self.realShowBuffCount = self.realShowBuffCount - 1
    end
    table.removeValue(self.buffInfos, buff)
    if buff.config and self.pet then
      for _, v in ipairs(buff.config.buff_groupsigns) do
        if v == ProtoEnum.BuffGroupSign.BGS_MIMIC and not self.pet.card.petState:GetMimic() then
          self:RefreshBuff(self.pet)
        end
      end
    end
  end
end

function UMG_Battle_BuffBox_C:RemoveBuffCallBack()
  self:RefreshBuffModeShow()
end

function UMG_Battle_BuffBox_C:RemoveBuffs(battlePet, immediate)
  if self.pet == battlePet then
    for i, v in pairs(self.buffs) do
      self:RemoveBuff(i, immediate)
    end
  end
end

function UMG_Battle_BuffBox_C:onBtnBuffClick()
  Log.Debug("UMG_Battle_BuffBox_C:onBtnBuffClick")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1060, "UMG_Battle_BuffBox_C:ClickBuff")
  if self.pet and self.buffInfos and #self.buffInfos > 0 then
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBuffInfo, {
      buffData = self.buffInfos
    })
  end
end

function UMG_Battle_BuffBox_C:GetBuffInfos()
  return self.realShowBuffCount
end

function UMG_Battle_BuffBox_C:GetBuffInfosByType(buffType)
  local buffs = {}
  for i, buff in ipairs(self.buffInfos) do
    if buff:GetBuffBaseOrder() == buffType then
      table.insert(buffs, buff)
    end
  end
  return buffs
end

return UMG_Battle_BuffBox_C
