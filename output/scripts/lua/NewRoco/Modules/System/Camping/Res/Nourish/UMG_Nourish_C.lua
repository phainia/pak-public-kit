local CampingModuleEvent = require("NewRoco.Modules.System.Camping.CampingModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local UMG_Nourish_C = _G.NRCPanelBase:Extend("UMG_Nourish_C")

function UMG_Nourish_C:OnConstruct()
  Log.Error("\230\158\175\230\158\157\230\187\139\229\133\187\231\155\184\229\133\179\229\138\159\232\131\189\232\162\171\229\185\178\230\142\137\228\186\134\239\188\140\233\135\141\230\150\176\229\144\175\231\148\168\232\175\183\233\135\141\230\150\176\230\143\144\233\156\128\230\177\130\229\129\154")
end

function UMG_Nourish_C:OnDestruct()
end

function UMG_Nourish_C:OnActive(_param)
  local insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu")
  self.insufficientText = insufficientText and insufficientText.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176"
  self.IconList = {
    self.Icon1,
    self.Icon2,
    self.Icon3,
    self.Icon4,
    self.Icon5,
    self.Icon6
  }
  self.CircleAnimationList = {
    self.UMG_Nourish_Circle_1,
    self.UMG_Nourish_Circle_2,
    self.UMG_Nourish_Circle_3,
    self.UMG_Nourish_Circle_4,
    self.UMG_Nourish_Circle_5,
    self.UMG_Nourish_Circle_6,
    self.UMG_Nourish_Circle_7,
    self.UMG_Nourish_Circle_8
  }
  self.param = _param
  self:SetIconCanClick(false)
  self:PlayAnimation(self.In)
  self:OnAddEventListener()
  self:RefreshPanel(nil)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1296, "UMG_Magic_Nourish_C:OnConstruct")
end

function UMG_Nourish_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_Nourish_C:SetIconCanClick(canClick)
  for i = 1, #self.IconList do
    self.IconList[i].CanClick = canClick
  end
end

function UMG_Nourish_C:RefreshPanel(RefreshReason)
  if not self.param then
    self.CampingId = 130309
    self.CampingLv = 3
  else
    self.CampingId = self.param.campfire.sceneCharacter.serverData.npc_base.npc_content_cfg_id
    self.CampingLv = self.param.campfire.sceneCharacter.serverData.base.lv
  end
  local maxLv, campingCfg, campingLvUpCfg = self:GetCampingMaxLvAndCfg(self.CampingId, self.CampingLv)
  self.MaxLv = maxLv
  self.CampingCfg = campingCfg
  self.CampingLvUpCfg = campingLvUpCfg
  if not campingLvUpCfg then
    Log.Error("campingLvUpCfg\233\133\141\231\189\174\228\184\162\229\164\177")
    return
  end
  if not campingCfg then
    Log.Error("campingCfg\233\133\141\231\189\174\228\184\162\229\164\177")
    return
  end
  self.Tree:SetPath(self.module:GetCampingIconPathByLv(self.CampingLv))
  self.Camping_Title:SetText(self.CampingCfg.name .. tostring(self.CampingLv) .. LuaText.umg_nourish_2)
  local placeName = _G.DataConfigManager:GetAreaFuncConf(self.CampingCfg.area_id).name
  self.Place_Names:SetText(placeName)
  self.GoodAndBad:Init(self.CampingCfg.advantage_type, self.CampingCfg.disadvantage_type)
  local FruitIdList = self.module:GetFruitIdList()
  local FruitCount = #FruitIdList
  for i = 1, 6 do
    if FruitCount <= 0 then
      if i <= self.CampingLvUpCfg.pet_fruit_num then
        self.IconList[i]:Init(true, nil, i - 1)
      else
        self.IconList[i]:Init(false, nil, i - 1)
      end
    end
    for j = 1, FruitCount do
      if FruitIdList[j].pos + 1 == i then
        if i <= self.CampingLvUpCfg.pet_fruit_num then
          self.IconList[i]:Init(true, FruitIdList[j], FruitIdList[j].pos)
          break
        end
        self.IconList[i]:Init(false, FruitIdList[j], FruitIdList[j].pos)
        break
      end
      if j == FruitCount then
        if i <= self.CampingLvUpCfg.pet_fruit_num then
          self.IconList[i]:Init(true, nil, i - 1)
        else
          self.IconList[i]:Init(false, nil, i - 1)
        end
      end
    end
  end
  if self.MaxLv == self.CampingLv then
    self.IsMaxLv = true
    self.Btn_Upgrade:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Btn_Upgrade:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if -1 ~= self.module.selectIndex then
    for i = 1, 6 do
      if self.IconList[i].index == self.module.selectIndex then
        if RefreshReason then
          if 1 == RefreshReason then
            self.IconList[i]:PlayAnimation(self.IconList[i].Add_Icon)
          end
          if 2 == RefreshReason then
            self.IconList[i]:PlayAnimation(self.IconList[i].Delete_Icon)
          end
        end
        _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OpenNourishRightFruitPanel, self.IconList[i].data, self.IconList[i].index)
        break
      end
    end
  end
end

function UMG_Nourish_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.Btn_Upgrade.btnLevelUp, self.OnUpgradeBtnClick)
  self:AddButtonListener(self.GoodAndBad.GoodAndBadBtn, self.OpenGoodBadTips)
  self:RegisterEvent(self, CampingModuleEvent.ShowCloseNourishBtn, self.ShowCloseBtn)
  if self.param and self.param.campfire then
    self.param.campfire.sceneCharacter:AddEventListener(self, NPCModuleEvent.NPC_LEVEL_UP, self.OnLevelUp)
  end
end

function UMG_Nourish_C:RefreshSelectIcon(index)
  for i = 1, #self.IconList do
    if index + 1 ~= i then
      self.IconList[i]:SetCancelSelect()
    end
  end
end

function UMG_Nourish_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:RemoveButtonListener(self.Btn_Upgrade.btnLevelUp, self.OnUpgradeBtnClick)
  self:RemoveButtonListener(self.GoodAndBad.GoodAndBadBtn, self.OpenGoodBadTips)
  self:UnRegisterEvent(self, CampingModuleEvent.ShowCloseNourishBtn)
  if self.param and self.param.campfire and self.param.campfire.sceneCharacter then
    self.param.campfire.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.NPC_LEVEL_UP, self.OnLevelUp)
  end
end

function UMG_Nourish_C:OpenGoodBadTips()
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowGoodAndBadTips, self.CampingCfg.advantage_type, self.CampingCfg.disadvantage_type)
end

function UMG_Nourish_C:ShowCloseBtn(IsShow)
  if IsShow then
    self.IsSelectIn = false
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    if not self.IsMaxLv then
      self.Btn_Upgrade:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self:PlayAnimation(self.Select_Out)
    for i = 1, #self.IconList do
      self.IconList[i]:SetCancelSelect()
    end
  else
    if self.IsSelectIn then
      return
    end
    self.IsSelectIn = true
    self:PlayAnimation(self.Select_In)
  end
end

function UMG_Nourish_C:OnLevelUp()
  Log.Debug("UMG_Magic_Nourish_C:OnLevelUp")
  self:PlayLevelUpAnim()
end

function UMG_Nourish_C:PlayLevelUpAnim()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1298, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  local lv = self.param.campfire.sceneCharacter.serverData.base.lv
  Log.Error("Level Up \229\183\178\231\187\143\229\186\159\229\188\131\229\149\166!!!!")
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_C:PlayLevelUpEffectBegin()
  self:RefreshPanel(nil)
end

function UMG_Nourish_C:PlayLevelUpEffectEnd()
end

function UMG_Nourish_C:LevelUpAnimComplete()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1302, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  self:PlayAnimation(self.In)
end

function UMG_Nourish_C:SetButtonEnabled(enabled)
  self.CloseBtn.btnClose:SetIsEnabled(enabled)
  self.Btn_Upgrade.btnLevelUp:SetIsEnabled(enabled)
  self.GoodAndBad.GoodAndBadBtn:SetIsEnabled(enabled)
end

function UMG_Nourish_C:OnCloseBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_Magic_Nourish_C:OnCloseBtnClick")
  if self:IsAnimationPlaying(self.In) or self:IsAnimationPlaying(self.Out) then
    return
  end
  self:ClosePanel()
end

function UMG_Nourish_C:ClosePanel()
  self.isRealClosed = true
  _G.NRCAudioManager:PlaySound2DAuto(1076, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_C:OnUpgradeBtnClick()
  if not self.param then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1297, "UMG_Magic_Nourish_C:OnUpgradeBtnClick")
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OpenUpgradeConfirmPanel, self.CampingId, self.CampingLv, self, self.OnLevelUpRsp)
end

function UMG_Nourish_C:OnLevelUpRsp(rsp)
  Log.Debug("UMG_Nourish_C:OnLevelUpRsp", rsp.ret_info.ret_code)
  if 0 ~= rsp.ret_info.ret_code then
    self.isUpgradeReq = false
    local error = _G.DataConfigManager:GetLocalizationConf("Camp_Levelup_error").msg
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, error)
  end
end

function UMG_Nourish_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if self.isRealClosed then
      if self.param and self.param.action then
        self.param.action:EndAction()
      end
      self.module:CloseFruitPanel()
      self.module:CloseUpdate()
      self:DoClose()
    else
      self:SetIconCanClick(false)
      for i = 1, #self.CircleAnimationList do
        self.CircleAnimationList[i]:StopAllAnimations()
      end
    end
  end
  if anim == self.In then
    self:SetButtonEnabled(true)
    self:SetIconCanClick(true)
    for i = 1, #self.CircleAnimationList do
      self.CircleAnimationList[i]:PlayAnimation(self.CircleAnimationList[i].Loop, 0, 99999)
    end
    self.UMG_Nourish_BlueLight:PlayAnimation(self.UMG_Nourish_BlueLight.Loop_BlueLight, 0, 99999)
  end
  if anim == self.Select_In then
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Upgrade:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Nourish_C:GetCampingMaxLvAndCfg(campingId, campingLv)
  local maxLv = 1
  local campingLvTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF)
  local campLvCfgs = campingLvTable:GetAllDatas()
  local CampingLvUpCfg
  for k, v in ipairs(campLvCfgs) do
    if v.content_id == campingId and maxLv < v.level then
      maxLv = v.level
    end
    if v.content_id == campingId and v.level == campingLv then
      CampingLvUpCfg = v
    end
  end
  local campingCfg = _G.DataConfigManager:GetCampConf(campingId)
  return maxLv, campingCfg, CampingLvUpCfg
end

return UMG_Nourish_C
