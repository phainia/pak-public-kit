local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local AppearanceLoginModuleEvent = require("NewRoco.Modules.System.AppearanceLogin.AppearanceLoginModuleEvent")
local UMG_BeautyLogin_Main_C = _G.NRCPanelBase:Extend("UMG_BeautyLogin_Main_C")

function UMG_BeautyLogin_Main_C:OnConstruct()
  self.data = self.module:GetData("AppearanceLoginModuleData")
  self:OnAddEventListener()
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  local gender = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender)
  self.curAvatarLocation = UE4.FVector(0, 0, 0)
  self.ActorHolder = LoginUtils.GetUObjectHolder()
  self.MaleRotation = UE4.FRotator(0, 97, 0)
  self.FemaleRotation = UE4.FRotator(0, -83, 0)
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    self.curAvatarLocation = self.ActorHolder.Player1:K2_GetActorLocation()
    self:OnBtnMaleClicked(true)
    self.gender = gender
  elseif gender == ProtoEnum.ESexValue.SEX_FEMALE then
    self.curAvatarLocation = self.ActorHolder.Player2:K2_GetActorLocation()
    self:OnBtnFemaleClicked(true)
    self.gender = gender
  end
  self.ActorHolder.Player1:SetOpenEye(true)
  self.ActorHolder.Player2:SetOpenEye(true)
  self.bStartMove = false
  self.moveSpeed = 300
end

function UMG_BeautyLogin_Main_C:OnActive()
  self:PlayAnimation(self.open)
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  self.itemList = self.data:GenerateBeautyItemList()
  self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetCommonTitle()
  self:UpdateTab()
  self.SexBtn_Male.Icon_M:SetVisibility(UE4.ESlateVisibility.Visible)
  self.SexBtn_Male.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:RefreshPanelInfo()
  self.Btn_Confirm:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_BeautyLogin_Main_C:CheckMovePlayerModel(notLoop, tabEnum)
  tabEnum = tabEnum or self.data.curBeautyChooseType
  if tabEnum == Enum.SalonLabelType.SLT_SUIT then
    self.targetPosition = UE4.FVector(480, 315, 508)
  else
    self.targetPosition = UE4.FVector(234, 290, 450)
  end
  if notLoop then
    local ActorHolder = LoginUtils.GetUObjectHolder()
    if ActorHolder then
      ActorHolder.Player1:K2_SetActorLocation(self.targetPosition, false, nil, false)
      ActorHolder.Player2:K2_SetActorLocation(self.targetPosition, false, nil, false)
    end
    return
  end
  self.bStartMove = true
end

function UMG_BeautyLogin_Main_C:OnTick(deltaTime)
  if self.bStartMove then
    local ActorHolder = LoginUtils.GetUObjectHolder()
    if ActorHolder then
      local currentPos = ActorHolder.Player1:K2_GetActorLocation()
      local toTarget = self.targetPosition - currentPos
      local distance = toTarget:Size()
      if distance <= 0.1 then
        ActorHolder.Player1:K2_SetActorLocation(self.targetPosition, false, nil, false)
        ActorHolder.Player2:K2_SetActorLocation(self.targetPosition, false, nil, false)
        self.bStartMove = false
      else
        local moveDistance = self.moveSpeed * deltaTime
        if distance < moveDistance then
          moveDistance = distance
        end
        local direction = toTarget / distance
        local newPos = currentPos + direction * moveDistance
        ActorHolder.Player1:K2_SetActorLocation(newPos, false, nil, false)
        ActorHolder.Player2:K2_SetActorLocation(newPos, false, nil, false)
      end
    end
  end
end

function UMG_BeautyLogin_Main_C:OnDeactive()
end

function UMG_BeautyLogin_Main_C:OnAddEventListener()
  if _G.GlobalConfig.DebugOpenUI then
    self:AddButtonListener(self.CloseBtn.btnClose, self.DoClose)
  end
  self:AddButtonListener(self.SexBtn_Male.SelectButton, self.OnBtnMaleClicked)
  self:AddButtonListener(self.SexBtn_Female.SelectButton, self.OnBtnFemaleClicked)
  self:AddButtonListener(self.Btn_Confirm.btnLevelUp, self.OnBtnConfirmClicked)
end

function UMG_BeautyLogin_Main_C:OnRemoveEventListener()
end

function UMG_BeautyLogin_Main_C:OnDestruct()
  self:CheckMovePlayerModel(true, Enum.SalonLabelType.SLT_SKIN)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  self:OnRemoveEventListener()
end

function UMG_BeautyLogin_Main_C:OnBtnMaleClicked(firstFlag)
  if self.BtnClickAudio then
    _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Beauty_Item1_C:OnItemSelected")
  else
    self.BtnClickAudio = true
  end
  local bNeedDelayRotation = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetNeedDelayRotation)
  if not self.hasRotated and not firstFlag and bNeedDelayRotation then
    Log.Debug("\228\184\187\232\167\146\230\156\170\230\151\139\232\189\172\229\174\140\230\175\149")
    return
  end
  if firstFlag or self.gender == ProtoEnum.ESexValue.SEX_FEMALE then
    self.SexBtn_Male:StopAllAnimations()
    self.SexBtn_Female:StopAllAnimations()
    self.SexBtn_Male:PlayAnimation(self.SexBtn_Male.Select)
    self.SexBtn_Female:PlayAnimation(self.SexBtn_Female.Out)
    self.gender = ProtoEnum.ESexValue.SEX_MALE
  end
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetCurRegisterGender, ProtoEnum.ESexValue.SEX_MALE)
  if not firstFlag then
    self:SetCharacterRotation(true)
    self:CheckMovePlayerModel(true)
  else
    self.ActorHolder.Player1:SetActorHiddenInGame(false)
    self.ActorHolder.Player2:SetActorHiddenInGame(true)
    self.ActorHolder.Player2.DecoratorComponent:SetDecoratorVisible(false)
  end
  self.module:SaveBeautyData(ProtoEnum.ESexValue.SEX_MALE)
  self:RefreshPanelInfo()
end

function UMG_BeautyLogin_Main_C:OnBtnFemaleClicked(firstFlag)
  if self.BtnClickAudio then
    _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Beauty_Item1_C:OnItemSelected")
  else
    self.BtnClickAudio = true
  end
  local bNeedDelayRotation = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetNeedDelayRotation)
  if not self.hasRotated and not firstFlag and bNeedDelayRotation then
    Log.Debug("\228\184\187\232\167\146\230\156\170\230\151\139\232\189\172\229\174\140\230\175\149")
    return
  end
  if firstFlag or self.gender == ProtoEnum.ESexValue.SEX_MALE then
    self.SexBtn_Male:StopAllAnimations()
    self.SexBtn_Female:StopAllAnimations()
    self.SexBtn_Female:PlayAnimation(self.SexBtn_Female.Select)
    self.SexBtn_Male:PlayAnimation(self.SexBtn_Male.Out)
    self.gender = ProtoEnum.ESexValue.SEX_FEMALE
  end
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetCurRegisterGender, ProtoEnum.ESexValue.SEX_FEMALE)
  if not firstFlag then
    self:SetCharacterRotation(false)
    self:CheckMovePlayerModel(true)
  else
    self.ActorHolder.Player1:SetActorHiddenInGame(true)
    self.ActorHolder.Player2:SetActorHiddenInGame(false)
    self.ActorHolder.Player2.DecoratorComponent:SetDecoratorVisible(true)
  end
  self.module:SaveBeautyData(ProtoEnum.ESexValue.SEX_FEMALE)
  self:RefreshPanelInfo()
end

function UMG_BeautyLogin_Main_C:SetCharacterRotation(MaleFlag)
  if MaleFlag then
    self.ActorHolder.Player1:SetActorHiddenInGame(false)
    self.ActorHolder.Player2:SetActorHiddenInGame(true)
    self.ActorHolder.Player2.DecoratorComponent:SetDecoratorVisible(false)
    self.ActorHolder.PlayerCenter:K2_SetActorRotation(self.MaleRotation, false)
    self:ForceLod(self.ActorHolder.Player1)
  else
    self.ActorHolder.Player1:SetActorHiddenInGame(true)
    self.ActorHolder.Player2:SetActorHiddenInGame(false)
    self.ActorHolder.Player2.DecoratorComponent:SetDecoratorVisible(true)
    self.ActorHolder.PlayerCenter:K2_SetActorRotation(self.FemaleRotation, false)
    self:ForceLod(self.ActorHolder.Player2)
  end
end

function UMG_BeautyLogin_Main_C:ForceLod(Player)
  local AllComponents = Player:K2_GetComponentsByClass(UE4.USkeletalMeshComponent)
  if AllComponents and AllComponents:Num() > 0 then
    for i, Comp in tpairs(AllComponents) do
      if Comp and UE4.UObject.IsValid(Comp) then
        Comp:SetForcedLod(1)
        UE4.UNRCStatics.ForceUpdateStreamingAssets(Comp.SkeletalMesh, 3)
      end
    end
  end
end

function UMG_BeautyLogin_Main_C:SetAvatarRotation(delta)
  local centerRotation1 = self.ActorHolder.Player1:K2_GetActorRotation()
  local centerRotation2 = self.ActorHolder.Player2:K2_GetActorRotation()
  self.ActorHolder.Player1:K2_SetActorRotation(centerRotation1 - UE4.FVector(0, delta, 0), false)
  self.ActorHolder.Player2:K2_SetActorRotation(centerRotation2 - UE4.FVector(0, delta, 0), false)
end

function UMG_BeautyLogin_Main_C:LuaOnTouchMoved(dir)
  self:SetAvatarRotation(dir.X)
end

function UMG_BeautyLogin_Main_C:SetControllerRotate(bMale)
  local controller = LoginUtils.GetLoginController()
end

function UMG_BeautyLogin_Main_C:OnBtnConfirmClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_Beauty_Item1_C:OnItemSelected")
  if _G.CreatePlayerModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.CreatePlayerModuleCmd.CheckNameUsable)
  else
    _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.CheckNameUsable)
  end
end

function UMG_BeautyLogin_Main_C:RefreshPanelInfo()
  self:UpdateBeautyList()
end

function UMG_BeautyLogin_Main_C:UpdateBeautyList()
  local itemList
  self.ColorBottle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  itemList = self:GetBeautyData(self.data.curBeautyChooseType)
  self.ViewItemList = itemList
  if nil == itemList or 0 == #itemList then
    return
  end
  self.View_List:InitGridView(itemList)
  local fashionFlag, colorFlag, fashionIndex, colorIndex = self:CheckHasChoosed()
  if true == fashionFlag then
    if fashionIndex > 0 then
      self.View_List:SelectItemByIndex(fashionIndex - 1)
    end
  else
    self.View_List:SelectItemByIndex(0)
  end
  if self.data.curBeautyChooseType ~= Enum.SalonLabelType.SLT_EYES then
    if true == colorFlag then
      self.Props_List:SelectItemByIndex(colorIndex)
    elseif self.ColorBottle:GetVisibility() == UE4.ESlateVisibility.Visible then
      self.Props_List:SelectItemByIndex(0)
    end
  end
  self:RefreshCommonTitle()
end

function UMG_BeautyLogin_Main_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_BeautyLogin_Main_C:RefreshCommonTitle()
  if self.titleConf and self.titleConf.subtitle then
    if self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_SKIN then
      self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_HAIR then
      self.Title1:SetSubtitle(self.titleConf.subtitle[2].subtitle)
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_EYEBORWS then
      self.Title1:SetSubtitle(self.titleConf.subtitle[3].subtitle)
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_EYELASH then
      self.Title1:SetSubtitle(self.titleConf.subtitle[4].subtitle)
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_EYES then
      self.Title1:SetSubtitle(self.titleConf.subtitle[5].subtitle)
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_MAKEUP then
      self.Title1:SetSubtitle(self.titleConf.subtitle[6].subtitle)
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_SUIT then
      self.Title1:SetSubtitle((self.titleConf.subtitle[7] or {}).subtitle or "")
    end
  end
end

function UMG_BeautyLogin_Main_C:CheckHasChoosed()
  local itemList = self:GetBeautyData(self.data.curBeautyChooseType)
  if self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_SUIT then
    local selectedSuitId = _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.GetInitialSelectedSuitId, _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender))
    if selectedSuitId then
      for k, v in ipairs(itemList) do
        if v == selectedSuitId then
          return true, false, k, 0
        end
      end
    end
    return false, false, 0, 0
  end
  local fashionFlag = false
  local colorFlag = false
  local fashionIndex = 0
  local colorIndex = 0
  local curGender = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender)
  local tempBeautyData = {}
  if curGender == Enum.ESexValue.SEX_MALE then
    tempBeautyData = self.data.curMaleBeautyData
  else
    tempBeautyData = self.data.curFemaleBeautyData
  end
  if tempBeautyData and #tempBeautyData > 0 then
    for k, v in ipairs(tempBeautyData) do
      if v.SalonId then
        local salonConfIds = self.data.AvatarSalonIdToSalonIds[v.SalonId]
        local salonItemConf = _G.DataConfigManager:GetSalonItemConf(salonConfIds[1])
        if salonItemConf.type == self.data.curBeautyChooseType then
          for i = 1, #itemList do
            if itemList[i].avatarId == v.SalonId then
              fashionIndex = i
              if v.SalonColorIndex > 0 then
                colorIndex = v.SalonColorIndex
                colorFlag = true
              end
              fashionFlag = true
            end
          end
        end
      end
    end
  end
  return fashionFlag, colorFlag, fashionIndex, colorIndex
end

function UMG_BeautyLogin_Main_C:GetBeautyData(beautyType)
  if beautyType == Enum.SalonLabelType.SLT_SUIT then
    local gender = _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.GetCurRegisterGender)
    return _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.GetInitialOptionalSuitIds, gender)
  end
  local showList = {}
  if not self.itemList then
    return showList
  end
  local curRegisterGender = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender)
  for k, v in pairs(self.itemList) do
    if v and #v > 0 then
      local salonItemConf = _G.DataConfigManager:GetSalonItemConf(v[1])
      if salonItemConf.type == beautyType and (curRegisterGender == salonItemConf.gender or salonItemConf.gender == _G.Enum.ESexValue.SEX_NOT_SEL) then
        table.insert(showList, {avatarId = k, salonItems = v})
      end
    end
  end
  table.sort(showList, function(a, b)
    return a.avatarId < b.avatarId
  end)
  return showList
end

function UMG_BeautyLogin_Main_C:UpdateTab()
  local tabConfTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.SALON_TAB_CONF)
  local tabConfDatas = tabConfTable:GetAllDatas()
  local showTable = {}
  for k, v in pairs(tabConfDatas) do
    table.insert(showTable, {
      Order = v.id,
      Type = v.use_SalonLabelType,
      Icon = v.icon
    })
  end
  self.Tab:InitGridView(showTable)
  self.Tab:SelectItemByIndex(0)
end

function UMG_BeautyLogin_Main_C:SetBeautyColorList(salonItems, colorIndex)
  if self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_EYES then
    self.ColorBottle:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if salonItems and #salonItems > 0 and type(salonItems[1]) == "number" then
      local salonItemConf = _G.DataConfigManager:GetSalonItemConf(salonItems[1])
      _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.SetAvatarSalon, salonItemConf.avatar_id, salonItemConf.texture_id)
    end
  else
    self.ColorBottle:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Props_List:InitGridView(salonItems)
    self.Props_List:SelectItemByIndex(colorIndex and colorIndex <= #salonItems and colorIndex - 1 or 0)
  end
end

function UMG_BeautyLogin_Main_C:OnAnimationStarted(anim)
  if anim == self.open then
    self:DelaySeconds(2.5, function()
      self.hasRotated = true
    end)
  end
end

return UMG_BeautyLogin_Main_C
