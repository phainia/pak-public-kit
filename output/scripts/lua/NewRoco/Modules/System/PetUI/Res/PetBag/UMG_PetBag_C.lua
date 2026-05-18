local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local NPCShopUIModuleEvent = require("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetBag_C = _G.NRCPanelBase:Extend("UMG_PetBag_C")

function UMG_PetBag_C:OnConstruct()
  self.selectedPet = nil
  self.lockAll = false
  self.isOpenBag = false
  self:SetPetBagIcon()
  self:SetBtnInfo()
  self.startPos = UE4.FVector2D(0, 0)
  self:OnAddEventListener()
  self.PetBagPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NrcRedPoint:SetupKey(138)
  self.NRCText_71:SetText(LuaText.umg_petbag_6)
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetBagOpenState, true)
end

function UMG_PetBag_C:OnActive(arg)
  self.BagListForceCreate = true
  self.CanScroll = true
  if _G.GlobalConfig.DebugOpenUI then
    self.PetBagPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  self.NRCImage_113:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#F4EEE1FF"))
  self.bIsPendingResPetUpdatePkg = false
  self:SetOwner(arg)
  self.ScrollPageController:SetPageChangeHandler(self.OnPageChangeHandle, self)
  self.ScrollPageController.pageScrollTime = 0.25
  self:SetTeamInfo()
  self.lockAll = false
  self:OnOpenPetBag()
  self:BindInputAction()
end

function UMG_PetBag_C:OnDestruct()
  if self.DragItemInstance and UE4.UObject.IsValid(self.DragItemInstance) then
    self.DragItemInstance:RemoveFromParent()
  end
  if self.owner and UE4.UObject.IsValid(self.owner) then
    self.owner.petBagTeamIndex = nil
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetBagOpenState, false)
  self.owner = nil
  self:OnRemoveEventListener()
end

function UMG_PetBag_C:OnLeftSlide()
  if not self.ScrollPageController:IsScrolling() then
    if self.ScrollPageController.curPage > 0 then
      local Success = self.ScrollPageController:ScrollToPage(self.ScrollPageController.curPage - 1, 0.25, true)
    else
      local Success = self.ScrollPageController:ScrollToPage(self.ScrollPageController:GetTotalPageNum() - 1, 0.01, true)
    end
  end
end

function UMG_PetBag_C:OnRightSlide()
  if not self.ScrollPageController:IsScrolling() then
    if self.ScrollPageController.curPage < self.ScrollPageController:GetTotalPageNum() - 1 then
      local Success = self.ScrollPageController:ScrollToPage(self.ScrollPageController.curPage + 1, 0.25, true)
    else
      local Success = self.ScrollPageController:ScrollToPage(0, 0.01, true)
    end
  end
end

function UMG_PetBag_C:OnPageChangeHandle(_page)
  self.Dot_List:SelectItemByIndex(_page)
  if self.OpenSelect_realIndex then
    if not self.HasOpenSelPetBag then
      self.BattlePetList:SelectItemByIndex(self.OpenSelect_realIndex - 1)
    else
      self.HasOpenSelPetBag = false
    end
    self.OpenSelect_realIndex = nil
  end
  self.TeamIndex = _page + 1
  self.owner:SetPetBagCurTeamNameAndBloodLineMagic(self.TeamIndex)
  if _page + 1 == self.TeamIndex then
    return
  end
  if not self.currentItemData then
    return
  end
  if not self.currentItemData.petInfo.petData then
    return
  end
  local IsInBackpack = _G.DataModelMgr.PlayerDataModel:IsInBackpack(self.currentItemData.petInfo.petData.gid)
  if self.curTeamInfo and not IsInBackpack and not self.petAddToTeam then
    local curTeam = self.curTeamInfo.teams[self.TeamIndex]
    if curTeam and curTeam.pet_infos and #curTeam.pet_infos > 0 and (not self.SkipSelectTeamIndex or self.SkipSelectTeamIndex and self.SkipSelectTeamIndex ~= self.TeamIndex) then
      local realIndex = self:GetListRealIndex(self.TeamIndex, 1)
      self:SetSkipItemUnSelectAnim(true)
      self.BattlePetList:SelectItemByIndex(realIndex - 1)
      self.SkipSelectTeamIndex = _page + 1
    end
  end
end

function UMG_PetBag_C:SetSkipItemUnSelectAnim(_bSkip)
  local num = self.BattlePetList:GetTotalItemNumber()
  for i = 1, num do
    local item = self.BattlePetList:GetItemByIndex(i - 1)
    if item then
      item._bSkipUnSelectAnim = _bSkip
    end
  end
end

function UMG_PetBag_C:SetBtnInfo()
  local Icon = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_suishenbeibao1_png.img_suishenbeibao1_png'"
  local Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_suishenbeibao3_png.img_suishenbeibao3_png'"
  local Icon_2 = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_suishenbeibao2_png.img_suishenbeibao2_png'"
  self.Btn_Details:SetPath(Icon)
  self.UMG_Btn:SetBtnText(LuaText.umg_petbag_1)
end

function UMG_PetBag_C:ShowRedPoint()
  local BackpackPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local RedPointList = _G.DataModelMgr.PlayerDataModel:GetRedPointInfo()
  local hasRed = false
  for k, v in ipairs(RedPointList) do
    if (v.reason_type == _G.Enum.RedPointReason.RPR_PET_EVOLVE_TEAM or v.reason_type == _G.Enum.RedPointReason.RPR_PET_EVOLVE_BACKPACK) and v.point_data and #v.point_data > 0 then
      for key, val in ipairs(v.point_data) do
        for l, m in ipairs(BackpackPetList) do
          local dataList = string.Split(val, ".")
          if m.gid == tonumber(dataList[1]) then
            hasRed = true
            break
          end
        end
      end
    end
  end
  if true == hasRed then
    self.NrcRedPoint:SetupKey(138)
  else
    self.NrcRedPoint:SetupKey(0)
  end
end

function UMG_PetBag_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_PetBag_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Details.btnLevelUp, self.OnOpenPetBag)
  self:AddButtonListener(self.Btn_BagSelected, self.OnOpenPetBag)
  self:AddButtonListener(self.Btn_AndSetThemFree, self.SetThemFree)
  self:AddButtonListener(self.backBtn, self.OnClosePetBag)
  self:AddButtonListener(self.UMG_Btn.btnLevelUp, self.BeginAddToBattleTeam)
  self:AddButtonListener(self.teamBigButton, self.CancelAddToBattleTeam)
  self:AddButtonListener(self.CancelBtn.btnLevelUp, self.CancelAddToBattleTeam)
  self.Button:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:AddButtonListener(self.Button, self.OpenPetTeamResonancePanel)
  self:AddButtonListener(self.NRCButton_68, self.OnLeftSlide)
  self:AddButtonListener(self.NRCButton, self.OnRightSlide)
  _G.NRCModuleManager:GetModule("NPCShopUIModule"):RegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_ITEM_REWARS_CLOSE, self.OnPetFreeSuccess)
  self:RegisterEvent(self, PetUIModuleEvent.OnRefreshEvoPetModel, self.OnEvolutionSuccess)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.PET_FLAG_CHANGE, self.OnPetFreeSuccess)
  self:RegisterEvent(self, PetUIModuleEvent.PetRename, self.UpdatePetName)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagStopAllAnimation, self.StopAllAnimations)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagCancelAddToBattleTeam, self.CancelAddToBattleTeam)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagUnlockAllButton, self.UnlockAllButton)
  self:RegisterEvent(self, PetUIModuleEvent.OnOpenPetBag, self.OnOpenPetBag)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagSetVisibility, self.PetBagSetVisibility)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagOnPetItemClick, self.OnPetItemClick)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagOnSelectPetBag, self.OnSelectPetBag)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagNrcRedPointSetupKey, self.NrcRedPoint.SetupKey)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagUpdatePetListInfo, self.UpdatePetListInfo)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagSelectPetBagByGid, self.SelectPetBagByGid)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagPlayAnimation, self.PlayAnimation)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagPlayEvoAnim, self.PetBagPlayEvoAnim)
  self:RegisterEvent(self, PetUIModuleEvent.PetBagPlayEvoBackAnim, self.PetBagPlayEvoBackAnim)
  self:RegisterEvent(self, PetUIModuleEvent.PetSkillTipsOpen, self.IsHideBagPanel)
  self:RegisterEvent(self, PetUIModuleEvent.AttributePanelRefresh, self.RefreshAttributeInfo)
  self:RegisterEvent(self, PetUIModuleEvent.ChangeWorldTeamSuccess, self.OnPetUpdate)
  self:RegisterEvent(self, PetUIModuleEvent.OnSendPetSuccess, self.OnSendPetSuccess)
  _G.NRCEventCenter:RegisterEvent("UMG_PetBag_C", self, PetUIModuleEvent.PetBagDragSelectItem, self.OnDragSelectItem)
  _G.NRCEventCenter:RegisterEvent("UMG_PetBag_C", self, PetUIModuleEvent.SetPanelCanScroll, self.SetSkillsPanelCanScroll)
  _G.NRCEventCenter:RegisterEvent("UMG_PetBag_C", self, _G.NRCGlobalEvent.OnRocoTouchStart, self.OnRocoTouchStartHandler)
  _G.NRCEventCenter:RegisterEvent("UMG_PetBag_C", self, _G.NRCGlobalEvent.OnRocoTouchMove, self.OnRocoTouchMoveHandler)
  self.BagPetList.OnUserScrolled:Add(self, self.OnBagPetListScrolled)
end

function UMG_PetBag_C:OnBagPetListScrolled(offset)
  self.PetBagDragList:SetInfo(nil, offset)
end

function UMG_PetBag_C:ShowExchangeIcon(_bShow)
  self.ShowItemExchange = _bShow
  for i = 0, #self.battlePetInfos - 1 do
    local item = self.BattlePetList:GetItemByIndex(i)
    if item and item.hasPet then
      item.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if _bShow and self.petAddToTeam and item.uiData.gid ~= self.petAddToTeam.petInfo.gid then
        item.Exchange:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        item.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    elseif item then
      item.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if _bShow and self.petAddToTeam then
        item.Add:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        item.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  for i = 0, #self.backpackPetInfos - 1 do
    local item = self.BagPetList:GetItemByIndex(i)
    if item and item.hasPet then
      if _bShow and self.petAddToTeam and item.uiData.gid ~= self.petAddToTeam.petInfo.gid then
        item.Exchange:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        item.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_PetBag_C:SetSkillsPanelCanScroll(CanScroll, ItemUiData)
  if self.CanScroll == CanScroll then
    return
  end
  self.CanScroll = CanScroll
  if CanScroll then
    self.PetBagDragList.IsLongPress = false
    self.ScrollPageController.IsLongPress = false
    self.BagPetList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BagPetList:ForceLayoutPrepass()
    self.ClickImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCButton_68:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCButton:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCImage_113:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#F4EEE1FF"))
    self.NRCImage_19:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#F4EEE1FF"))
    self.UMG_Btn:SetIsEnabled(true)
    self:OnTryDisableDragItem()
    self:CancelAddToBattleTeam()
  else
    self.PetBagDragList:SetInfo(self.BagPetList:GetItemSize(), self.BagPetList:GetScrollOffset())
    self.PetBagDragList.IsLongPress = true
    self.ScrollPageController.IsLongPress = true
    self.UMG_Btn:SetIsEnabled(false)
    self.DragData = ItemUiData
    self.petAddToTeam = ItemUiData
    self.BattlePetListSelect = false
    self.NRCButton_68:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCImage_113:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#929086FF"))
    self.NRCButton:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCImage_19:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#929086FF"))
    for i = 1, #self.battlePetInfos do
      if self.battlePetInfos[i].petInfo.gid and self.battlePetInfos[i].petInfo.gid == self.petAddToTeam.petInfo.gid then
        self.BattlePetListSelect = true
      end
    end
    self:ShowExchangeIcon(true)
    self.ClickImage:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BagPetList:EndInertialScrolling()
    self.BagPetList:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.BagPetList:ForceLayoutPrepass()
    self:OnInitDragItem()
  end
end

function UMG_PetBag_C:OnDragSelectItem(ItemUiData, IsTeam)
  if self.DragData and not self.CanScroll then
    self:SetPetRemoveFromTeam(ItemUiData, IsTeam)
  end
end

function UMG_PetBag_C:OpenPetTeamResonancePanel()
  do return end
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_PetBagFormation1_C:OnItemSelected")
  local teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo()
  local team = teamInfo.teams[_G.DataModelMgr.PlayerDataModel:GetBattleTeamIndex() + 1]
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetTeamResonancePanel, team)
end

function UMG_PetBag_C:PlayAnimationIn()
  self:PlayAnimation(self.Open_jinglingye)
end

function UMG_PetBag_C:OnRemoveEventListener()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.PET_FLAG_CHANGE, self.OnPetFreeSuccess)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetBagDragSelectItem, self.OnDragSelectItem)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.SetPanelCanScroll, self.SetSkillsPanelCanScroll)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchMove, self.OnRocoTouchMoveHandler)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchStart, self.OnRocoTouchStartHandler)
  if _G.NRCModuleManager:GetModule("NPCShopUIModule") then
    _G.NRCModuleManager:GetModule("NPCShopUIModule"):UnRegisterEvent(self, NPCShopUIModuleEvent.NPCSHOP_ITEM_REWARS_CLOSE, self.OnPetFreeSuccess)
  end
  if _G.NRCModuleManager:GetModule("MainUIModule") then
    _G.NRCModuleManager:GetModule("MainUIModule"):UnRegisterEvent(self, PetUIModuleEvent.PET_EVOLUTION_SUCCESS, self.OnEvolutionSuccess)
  end
  self:UnRegisterEvent(self, PetUIModuleEvent.AttributePanelRefresh, self.RefreshAttributeInfo)
  self:UnRegisterEvent(self, PetUIModuleEvent.OnSendPetSuccess, self.OnSendPetSuccess)
end

function UMG_PetBag_C:UpdatePetName(rsp)
  local petData = rsp.ret_info.goods_change_info.changes[1].pet_data
  for _, item in ipairs(self.battlePetInfos) do
    if item.petInfo.gid == petData.gid then
      item.petInfo.petData.name = petData.name
    end
  end
  for _, item in ipairs(self.backpackPetInfos) do
    if item.petInfo.gid == petData.gid then
      item.petInfo.petData.name = petData.name
    end
  end
end

function UMG_PetBag_C:OnEvolutionSuccess()
  self:SetBattlePetList()
  if UE4.UObject.IsValid(self.owner.petInfoMainCtrl) then
    self:OnPetItemClick(self.owner.petInfoMainCtrl.currentSelectedPetIndex, nil, true)
  end
end

function UMG_PetBag_C:OnPetFreeSuccess()
  self.BagListForceCreate = true
  self:SetBattlePetList(true)
  if UE4.UObject.IsValid(self.owner.petInfoMainCtrl) then
    local backpackPetNum = 0
    for _, item in ipairs(self.backpackPetInfos) do
      if item.petInfo and item.petInfo.gid then
        backpackPetNum = backpackPetNum + 1
      end
    end
    if backpackPetNum > 0 then
      self:OnPetItemClickAlwaysClick(self.owner.petInfoMainCtrl.currentSelectedPetIndex)
    else
      self:OnPetItemClickAlwaysClick(1)
    end
  end
end

function UMG_PetBag_C:Reconnects()
  self:SetBattlePetList()
  if UE4.UObject.IsValid(self.owner.petInfoMainCtrl) then
    self:OnPetItemClickAlwaysClick(self.owner.petInfoMainCtrl.currentSelectedPetIndex)
  end
end

function UMG_PetBag_C:OnPlayerDataUpdate()
  if self.bagPanelOpen then
  else
    self:SetBattlePetList()
    if self.selectedPet then
      for _, item in ipairs(self.backpackPetInfos) do
        if item and item.petInfo.gid == self.selectedPet.petInfo.gid then
          self.selectedPet = item
        end
      end
      self:SetPetBagIcon()
    end
  end
  if self.currentItemData and self.currentItemData.petInfo and self.currentItemData.petInfo.petData then
    self.currentItemData.petInfo.petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.currentItemData.petInfo.petData.gid)
  end
end

function UMG_PetBag_C:GetIsInPvpOrPveTeam(petData)
  local IsInTeam, teamInfo = PetUtils.GetIsInPvpOrPveTeamByGid(petData.gid)
  if IsInTeam then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetReleaseTips, petData, teamInfo, {
      caller = self,
      callback = self.ApplyFreePvpOrPvePet
    }, true)
    return true
  else
    return false
  end
end

function UMG_PetBag_C:ApplyFreePvpOrPvePet()
  local petList = {}
  table.insert(petList, self.currentItemData.petInfo.petData)
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenBackpackPetFreePanel, petList)
end

function UMG_PetBag_C:SetThemFree()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_FREE, true)
  if isBan then
    return
  end
  if not self.currentItemData then
    Log.Error("currentItemData\230\149\176\230\141\174\228\184\186\231\169\186")
    return
  end
  if not self.currentItemData.petInfo.petData then
    Log.Error("petData\230\149\176\230\141\174\228\184\186\231\169\186")
    return
  end
  if _G.NRCModuleManager:IsModuleActive("TaskPetFollowModule") then
    local bInFollow, Tip = _G.NRCModuleManager:DoCmd(_G.TaskPetFollowModuleCmd.CheckPetInTaskFollow, self.currentItemData.petInfo.petData.gid, 3)
    if bInFollow then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Tip)
      return
    end
  end
  if self.currentItemData.petInfo.petData.partner_mark and self.currentItemData.petInfo.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    local tip = _G.DataConfigManager:GetPetGlobalConfig("collection_cant_release").str
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tip)
    return
  end
  if PetUtils.CheckPetIsInherited(self.currentItemData.petInfo.petData.gid) then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.LuaText.INHERITANCE_10)
    return
  end
  local petList = {}
  table.insert(petList, self.currentItemData.petInfo.petData)
  for i, petInfo in ipairs(petList) do
    local IsTeamPet = _G.DataModelMgr.PlayerDataModel:GetIsTeamPetByGid(petInfo.gid)
    if IsTeamPet then
      return
    end
  end
  for i, petInfo in ipairs(petList) do
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id)
    if petBaseConf.ban_free and 1 == petBaseConf.ban_free then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petbag_2 .. petBaseConf.name .. LuaText.umg_petbag_3)
      return
    end
  end
  for i, petInfo in ipairs(petList) do
    local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petInfo.gid)
    if isTravel then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petbag_4)
      return
    end
  end
  local IsInPvpOrPveTeam = self:GetIsInPvpOrPveTeam(self.currentItemData.petInfo.petData)
  if not IsInPvpOrPveTeam then
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenBackpackPetFreePanel, petList)
  end
  self:DispatchEvent(PetUIModuleEvent.SelectEmptySkill)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002005, "UMG_PetWarehouse_C:OnNRCButton_0ClickPetFree ")
end

function UMG_PetBag_C:SetOwner(owner)
  self.owner = owner
end

function UMG_PetBag_C:OnOpenPetBag()
  if self.lockAll then
    return
  end
  self.isOpenBag = true
  self:DispatchEvent(PetUIModuleEvent.PetBagChangeSetEggBtn, false)
  self:DispatchEvent(PetUIModuleEvent.OnChangePetBagState, true)
  _G.NRCAudioManager:PlaySound2DAuto(40002001, "UMG_PetBag_C:OnOpenPetBag")
  self:ShowBagPanel()
  self:DispatchEvent(PetUIModuleEvent.OpenDetailCameraLocation, 2)
  if self.owner then
    self.owner:OnPetBagOpen()
  else
    Log.Error("zgx owner is nil at UMG_PetBag_C")
  end
  self:PauseAnimation(self.change2)
  self:DelayShow()
end

function UMG_PetBag_C:DelayShow()
  if self.isOpenBag then
    self:PlayAnimation(self.change2)
  end
end

function UMG_PetBag_C:RefreshAttributeInfo()
  local item = self.BattlePetList:GetSelectedItem()
  if item then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(item.uiData.petData.gid)
    local petInfo = {
      gid = petData.gid,
      base_conf_id = petData.base_conf_id,
      showPetHp = true,
      IsAllUpdate = true,
      level = petData.level,
      petData = petData,
      indexBase = 0
    }
    item.uiData = petInfo
    self.currentItemData.petInfo.petData.partner_mark = petInfo.petData.partner_mark
    item:UpdateCollect()
  end
  local BagItem = self.BagPetList:GetSelectedItem()
  if BagItem then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(BagItem.uiData.petData.gid)
    local petInfo = {
      gid = petData.gid,
      base_conf_id = petData.base_conf_id,
      showPetHp = true,
      IsAllUpdate = true,
      IsTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petData.gid),
      level = petData.level,
      petData = petData,
      indexBase = 6
    }
    BagItem.uiData = petInfo
    self.currentItemData.petInfo.petData.partner_mark = petInfo.petData.partner_mark
    BagItem:UpdateCollect()
  end
end

function UMG_PetBag_C:GetIsLegendaryFull()
  local isLegendaryNum = 0
  local isLegendaryFull = false
  for i = 0, #self.battlePetInfos - 1 do
    local item = self.BattlePetList:GetItemByIndex(i)
    if item and item.uiData and item.uiData.base_conf_id then
      local onePetBaseCfg = _G.DataConfigManager:GetPetbaseConf(item.uiData.base_conf_id)
      if onePetBaseCfg and 1 == onePetBaseCfg.is_pet_legendary then
        isLegendaryNum = isLegendaryNum + 1
      end
    end
  end
  local BATTLE_GLOBAL_CONFIG = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG)
  local legendaryLimitCfg = BATTLE_GLOBAL_CONFIG:GetData("pet_legendary_deployment_limits")
  local legendaryLimit = 1
  if legendaryLimitCfg and legendaryLimitCfg.num then
    legendaryLimit = legendaryLimitCfg.num
  end
  if isLegendaryNum >= legendaryLimit then
    isLegendaryFull = true
  end
  return isLegendaryFull
end

function UMG_PetBag_C:OnClosePetBag()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  if self.lockAll then
    return
  end
  self.isOpenBag = false
  if not self.eventDispatcher then
    return
  end
  self:DispatchEvent(PetUIModuleEvent.PetBagChangeSetEggBtn, true)
  self:DispatchEvent(PetUIModuleEvent.OnChangePetBagState, false)
  NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetBagOpenState, false)
  _G.NRCAudioManager:PlaySound2DAuto(40002002, "UMG_PetBag_C:OnClosePetBag")
  self:HideBagPanel()
  self:DispatchEvent(PetUIModuleEvent.OpenDetailCameraLocation, 3)
  local index
  if self.BagPetList:GetSelectedItem() then
    index = self.BagPetList:GetSelectedItem().index
  end
  self.owner:OnPetBagClose(index)
end

function UMG_PetBag_C:BeginAddToBattleTeam()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetBag_C:BeginAddToBattleTeam")
  self.BattlePetListSelect = false
  if self:IsAnimationPlaying(self.change2) or self:IsAnimationPlaying(self.change1) then
    return
  end
  if not self.currentItemData then
    Log.Error("self.currentItemData Is Nil")
    return
  end
  if not self.battlePetInfos then
    Log.Error("self.battlePetInfos Is Nil")
    return
  end
  self.PetBagDragList:SetInfo(self.BagPetList:GetItemSize(), self.BagPetList:GetScrollOffset())
  self.IsBtnToExChange = true
  self.ScrollPageController.LongPressDrag = false
  self.module:SetRightPanelMarkBtnVisible(true)
  if self.PetBagDragList.IsLongPress then
    self.NRCButton_68:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCImage_113:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#929086FF"))
    self.NRCButton:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCImage_19:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#929086FF"))
  end
  for i = 1, #self.battlePetInfos do
    if self.battlePetInfos[i].petInfo.gid and self.battlePetInfos[i].petInfo.gid == self.currentItemData.petInfo.gid then
      self.BattlePetListSelect = true
    end
  end
  local petBaseInfo = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PETBASE_CONF)
  local currentItemDataPetCfg = petBaseInfo:GetData(self.currentItemData.petInfo.base_conf_id)
  local isLegendaryFull = false
  if not self.BattlePetListSelect and currentItemDataPetCfg and 1 == currentItemDataPetCfg.is_pet_legendary then
    isLegendaryFull = self:GetIsLegendaryFull()
  end
  for i = 1, #self.battlePetInfos do
    self.BattlePetList:OpItemByIndex(i, {
      type = 1,
      currentItemData = self.currentItemData,
      isLegendaryFull = isLegendaryFull,
      BattlePetListSelect = self.BattlePetListSelect
    })
  end
  if not self.BattlePetListSelect then
    self.BagPetList:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  for i = 0, #self.backpackPetInfos - 1 do
    local item = self.BagPetList:GetItemByIndex(i)
    if item then
      if self.BattlePetListSelect then
        if self.backpackPetInfos[i + 1].isEgg then
          item.clickable = false
          item:SwitchToSelectMode(false)
        else
          isLegendaryFull = false
          if currentItemDataPetCfg and 1 ~= currentItemDataPetCfg.is_pet_legendary then
            isLegendaryFull = self:GetIsLegendaryFull()
          end
          if isLegendaryFull then
            local onePetBaseCfg = petBaseInfo:GetData(item.uiData.base_conf_id)
            if onePetBaseCfg and 1 == onePetBaseCfg.is_pet_legendary then
              item.clickable = false
              item:SwitchToSelectMode(false)
            else
              item.clickable = true
              item:SwitchToNormalMode()
              item.preparedForChange = true
            end
          else
            item.clickable = true
            item:SwitchToNormalMode()
            item.preparedForChange = true
          end
        end
      elseif self.currentItemData.petInfo.gid == self.backpackPetInfos[i + 1].petInfo.gid or self.backpackPetInfos[i + 1].isEgg then
        item.clickable = false
        local IsChangeItem = self.currentItemData.petInfo.gid == self.backpackPetInfos[i + 1].petInfo.gid and not self.backpackPetInfos[i + 1].isEgg
        item:SwitchToSelectMode(IsChangeItem)
      elseif item.isEmptyItem then
        item.clickable = false
      else
        item.clickable = true
        item:SwitchToNormalMode()
        item.preparedForChange = true
      end
    end
  end
  self:FadeOutButton()
  self.petAddToTeam = self.currentItemData
  self:ShowExchangeIcon(true)
  self.petRemoveFromTeam = nil
  self.teamBigButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CancelBtn:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_PetBag_C:EndAddToBattleTeam()
  self.ScrollPageController.LongPressDrag = true
  self.IsBtnToExChange = false
  self.petAddToTeam = nil
  self.petRemoveFromTeam = nil
  self.DragData = nil
  for i = 0, #self.battlePetInfos - 1 do
    local item = self.BattlePetList:GetItemByIndex(i)
    if item then
      item.clickable = true
      item:SwitchToNormalMode()
      item.IsToChange = false
    end
  end
  self.NRCButton_68:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BagPetList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.module:SetRightPanelMarkBtnVisible(false)
  for i = 0, #self.backpackPetInfos - 1 do
    local item = self.BagPetList:GetItemByIndex(i)
    if item then
      if item.isEmptyItem then
        item.clickable = false
      else
        item.clickable = true
      end
      item:SwitchToNormalMode()
      item.preparedForChange = false
    end
  end
  self:ShowExchangeIcon(false)
  self.teamBigButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CancelBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetBag_C:CancelAddToBattleTeam()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetBag_C:BeginAddToBattleTeam")
  if self.RemovePet then
    return
  end
  for i, item in ipairs(self.backpackPetInfos) do
    if item.petInfo.gid == self.currentItemData.petInfo.gid then
      self.Btn_AndSetThemFree:SetVisibility(UE4.ESlateVisibility.Visible)
      break
    end
    if i == #self.backpackPetInfos then
      self.Btn_AndSetThemFree:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:FadeInButton()
  self:EndAddToBattleTeam()
end

function UMG_PetBag_C:setPetInfoMainCtrl(_petInfoMainCtrl)
  self.petInfoMainCtrl = _petInfoMainCtrl
end

function UMG_PetBag_C:HideBagPanel()
  local playAnim = false
  if self.PetBagPanel:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
    playAnim = true
  end
  self.backBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.teamBigButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CancelBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetPetBagIcon()
  self.bagPanelOpen = false
  if playAnim then
    self:LockAllButton()
    self:SetListClickState(false)
    if self.owner.PetBagBtn then
      self.owner.PetBagBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
    self:PlayAnimation(self.change1)
  end
  self:ClearAllEnhancedInput()
end

function UMG_PetBag_C:IsHideBagPanel(_PetSkillTipsState)
  if _PetSkillTipsState then
    self.On:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.UnderThe:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.On:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UnderThe:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetBag_C:IsOpenPetBag()
  local PetBagVisible = self.PetBagPanel:GetVisibility()
  if PetBagVisible == UE4.ESlateVisibility.Visible or PetBagVisible == UE4.ESlateVisibility.SelfHitTestInvisible then
    return true
  else
    return false
  end
end

function UMG_PetBag_C:ShowBagPanel()
  self.PetBagPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.backBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.teamBigButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CancelBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetBattlePetList()
  self:UpdateResonanceList()
  self.bagPanelOpen = true
  self:LockAllButton()
  self:SetListClickState(true)
  self:PlayAnimation(self.change2)
end

function UMG_PetBag_C:SetListClickState(IsClick)
  local Count = self.BattlePetList:GetItemCount()
  for i = 1, Count do
    local Item = self.BattlePetList:GetItemByIndex(i - 1)
    if Item then
      Item:SetIsEnabled(IsClick)
    end
  end
  local Count_1 = self.BagPetList:GetItemCount()
  for i = 1, Count_1 do
  end
end

function UMG_PetBag_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    self:UnlockAllButton()
    if self.owner.PetBagBtn then
      self.owner.PetBagBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self:DoClose()
  end
  if Animation == self.change2 then
    self:UnlockAllButton()
  end
end

function UMG_PetBag_C:LockAllButton()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.lockAll = true
end

function UMG_PetBag_C:UnlockAllButton()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.lockAll = false
end

function UMG_PetBag_C:UpdateResonanceList()
  local teamInfo = {}
  local petInfos = {}
  for i, pet in ipairs(self.battlePetInfos) do
    table.insert(petInfos, PetUtils.PetInfoCreate(pet.petInfo.gid))
  end
  teamInfo.pet_infos = petInfos
  local activedResonances = PetUtils.GetPetTeamActivedResonances(teamInfo)
  if not activedResonances or #activedResonances <= 0 then
    self.ResonanceList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ResonanceList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ResonanceList:InitGridView(activedResonances)
  end
end

function UMG_PetBag_C:SetPetBagIcon()
  if self.selectedPet == nil then
    self.State:SetActiveWidgetIndex(0)
  else
  end
end

function UMG_PetBag_C:SetTeamInfo()
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  if not teamInfo then
    return
  end
  self.curTeamInfo = teamInfo
  self.TeamIndex = self.TeamIndex or teamInfo.main_team_idx and teamInfo.main_team_idx + 1 or 1
  local TotalNum = #teamInfo.teams * 6
  self.Dot_List:InitGridView(teamInfo.teams)
  self.ScrollPageController:SetValidItemTotalNum(TotalNum)
end

function UMG_PetBag_C:SetCurTeamPetList()
  self.battlePetInfos = {}
  for index = 1, #self.curTeamInfo.teams do
    for i = 1, 6 do
      table.insert(self.battlePetInfos, {
        petInfo = {},
        parent = self
      })
    end
    local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(index - 1)
    for i, pet_data in ipairs(battlePetList) do
      local petInfo = {
        gid = pet_data.gid,
        base_conf_id = pet_data.base_conf_id,
        showPetHp = true,
        IsAllUpdate = true,
        level = pet_data.level,
        petData = pet_data,
        indexBase = 0
      }
      local realIndex = self:GetListRealIndex(index, i)
      self.battlePetInfos[realIndex].petInfo = petInfo
    end
  end
  self.BattlePetList:InitList(self.battlePetInfos)
  self.ScrollPageController:ScrollToPage(self.TeamIndex - 1, 0.01, false)
  self.SkipSelectTeamIndex = self.TeamIndex
  self.BattlePetList:ClearSelection()
end

function UMG_PetBag_C:SetBattlePetList(NotRefreshTeamInfo, bNeedtoCreateItem)
  if NotRefreshTeamInfo then
    if self.TeamIndex then
      local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(self.TeamIndex - 1)
      if battlePetList and #battlePetList > 0 then
      else
        local ValidIndex = 0
        if self.curTeamInfo then
          ValidIndex = self.curTeamInfo.main_team_idx
          local Num = self.curTeamInfo.teams and #self.curTeamInfo.teams > 0 and #self.curTeamInfo.teams
          if Num then
            for i = 1, Num do
              local curTeam = self.curTeamInfo.teams[i]
              if curTeam and curTeam.pet_infos and #curTeam.pet_infos > 0 then
                ValidIndex = i
                break
              end
            end
          end
        end
        self.TeamIndex = ValidIndex
        self.ScrollPageController:ScrollToPage(self.TeamIndex - 1, 0.01, false)
      end
    end
  else
    self:SetCurTeamPetList()
  end
  self.backpackPetInfos = {}
  local backpackPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  for i, pet_data in ipairs(backpackPetList) do
    local IsTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, pet_data.gid)
    local IsInHome = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPetIsInHome, pet_data.gid)
    local IsInGuard = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePlantGuardPetGid) == pet_data.gid
    if IsTravel then
      table.insert(self.backpackPetInfos, #self.backpackPetInfos + 1, {
        petInfo = {
          gid = pet_data.gid,
          base_conf_id = pet_data.base_conf_id,
          showPetHp = true,
          IsAllUpdate = true,
          IsTravel = IsTravel,
          IsInHome = IsInHome,
          IsInGuard = IsInGuard,
          sortNum = self:GetSortPriority(IsTravel, IsInHome, IsInGuard),
          level = pet_data.level,
          petData = pet_data,
          indexBase = 6
        },
        parent = self
      })
    else
      table.insert(self.backpackPetInfos, 1, {
        petInfo = {
          gid = pet_data.gid,
          base_conf_id = pet_data.base_conf_id,
          showPetHp = true,
          IsAllUpdate = true,
          IsTravel = IsTravel,
          IsInHome = IsInHome,
          IsInGuard = IsInGuard,
          sortNum = self:GetSortPriority(IsTravel, IsInHome, IsInGuard),
          level = pet_data.level,
          petData = pet_data,
          indexBase = 6
        },
        parent = self
      })
    end
  end
  table.stableSort(self.backpackPetInfos, function(a, b)
    local n1 = math.maxinteger
    local n2 = math.maxinteger
    if a.petInfo and a.petInfo.sortNum then
      n1 = a.petInfo.sortNum
    end
    if b.petInfo and b.petInfo.sortNum then
      n2 = b.petInfo.sortNum
    end
    return n1 < n2
  end)
  local offset = self.BagPetList:GetScrollOffset()
  if bNeedtoCreateItem then
    self.BagPetList:InitList(self.backpackPetInfos)
  else
    self.BagPetList:InitList(self.backpackPetInfos, not self.BagListForceCreate)
  end
  if self.BagPetAddToTeam then
    self:DelayFrames(2, function()
      self.BagPetList:NRCSetScrollOffset(offset)
    end)
  end
  self.BagListForceCreate = false
  self.BagPetAddToTeam = false
  self.BagPetList:ClearSelection()
  self.BattlePetList:ClearSelection()
  local bagPetNum = #backpackPetList
  self.bagVolume:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.bagVolume_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCSwitcher_104:SetActiveWidgetIndex(0 == bagPetNum and 2 or 0)
end

function UMG_PetBag_C:GetListRealIndex(TeamIndex, index)
  local RelIndex = 0
  if index <= 3 then
    local n = (TeamIndex - 1) * 3 + (index - 1)
    RelIndex = 2 * n + 1
  else
    local n = (TeamIndex - 1) * 3 + (index - 4)
    RelIndex = 2 * n + 2
  end
  return RelIndex
end

function UMG_PetBag_C:OnPetItemClick(index, sayNothing, _isEvo, IsOpenSelectIndex)
  if 0 == index then
    self.BagPetList:ClearSelection()
    self.BattlePetList:ClearSelection()
    return
  end
  if index <= 6 then
    local realIndex = self:GetListRealIndex(self.TeamIndex, index)
    self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_AndSetThemFree:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BagPetList:ClearSelection()
    if not self.BattlePetList:IsItemIndexSelected(realIndex) and sayNothing then
      local item = self.BattlePetList:GetItemByIndex(realIndex - 1)
      if item then
        item.sayNothing = true
      end
      if IsOpenSelectIndex then
        self.OpenSelect_realIndex = realIndex
      else
        self.BattlePetList:SelectItemByIndex(realIndex - 1)
      end
    end
    self.currentItemData = self.battlePetInfos[realIndex]
    return
  else
    self:FadeInButton(_isEvo)
    self.BattlePetList:ClearSelection()
    if self.selectedPet then
      local realIndex = 0
      for i, item in ipairs(self.backpackPetInfos) do
        if item.petInfo.gid == self.selectedPet.petInfo.gid then
          realIndex = i
          break
        end
      end
      self.BagPetList:SelectItemByIndex(realIndex - 1)
      self.currentItemData = self.backpackPetInfos[realIndex]
      _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.ChangeChoosePet, realIndex + 6, self.currentItemData.petInfo)
      self.selectedPet = nil
    else
      local realIndex = index - 6
      local backpackPetNum = 0
      for _, item in ipairs(self.backpackPetInfos) do
        backpackPetNum = backpackPetNum + 1
      end
      if realIndex > backpackPetNum then
        if 0 == backpackPetNum then
          self.BattlePetList:SelectItemByIndex(0)
          self.currentItemData = self.battlePetInfos[1]
          return
        else
          self.BagPetList:SelectItemByIndex(backpackPetNum - 1)
          realIndex = backpackPetNum
        end
      elseif _isEvo then
        local Item = self.BagPetList:GetItemByIndex(realIndex - 1)
        if Item then
          Item.sayNothing = true
        end
        self.BagPetList:SelectItemByIndex(realIndex - 1)
      end
      self.currentItemData = self.backpackPetInfos[realIndex]
      self.UMG_Btn:SetVisibility(self.currentItemData.petInfo.isEgg and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
      self.Btn_AndSetThemFree:SetVisibility(self.currentItemData.petInfo.isEgg and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_PetBag_C:OnSelectPetBag(gid)
  local index = 1
  for i = 1, #self.backpackPetInfos do
    local item = self.backpackPetInfos[i]
    if item.petInfo.gid == gid then
      index = i
      break
    end
  end
  self.HasOpenSelPetBag = true
  self.BagPetList:SelectItemByIndex(index - 1)
end

function UMG_PetBag_C:OnPetItemClickAlwaysClick(index, ForceSelect)
  if 0 == index then
    self.BagPetList:ClearSelection()
    self.BattlePetList:ClearSelection()
    return
  end
  if index <= 6 then
    local realIndex = self:GetListRealIndex(self.TeamIndex, index)
    self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_AndSetThemFree:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BagPetList:ClearSelection()
    if not self.BattlePetList:IsItemIndexSelected(realIndex) and self.currentItemData and self.battlePetInfos and self.currentItemData.petInfo.gid ~= self.battlePetInfos[realIndex].petInfo.gid or ForceSelect then
      self:DelayFrames(2, function()
        self.BattlePetList:SelectItemByIndex(realIndex - 1)
      end)
    end
    self.currentItemData = self.battlePetInfos[realIndex]
    return
  else
    self:FadeInButton()
    self.BattlePetList:ClearSelection()
    if self.selectedPet then
      local realIndex = 0
      for i, item in ipairs(self.backpackPetInfos) do
        if item.petInfo.gid == self.selectedPet.petInfo.gid then
          realIndex = i
          break
        end
      end
      self.BagPetList:SelectItemByIndex(realIndex - 1)
      self.currentItemData = self.backpackPetInfos[realIndex]
      _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.ChangeChoosePet, realIndex + 6, self.currentItemData.petInfo)
      self.selectedPet = nil
    else
      local realIndex = index - 6
      local backpackPetNum = 0
      for _, item in ipairs(self.backpackPetInfos) do
        if item.petInfo and item.petInfo.gid then
          backpackPetNum = backpackPetNum + 1
        end
      end
      if realIndex > backpackPetNum then
        if 0 == backpackPetNum then
          self.BattlePetList:SelectItemByIndex(0)
          self.currentItemData = self.battlePetInfos[1]
          return
        else
          self.BagPetList:SelectItemByIndex(0)
          realIndex = 1
        end
      elseif not self.BattlePetList:IsItemIndexSelected(realIndex) and self.currentItemData and self.backpackPetInfos and self.currentItemData.petInfo.gid ~= self.backpackPetInfos[realIndex].petInfo.gid or ForceSelect then
        self:DelayFrames(3, function()
          if UE4.UObject.IsValid(self.BagPetList) and self.BagPetList then
            self.BagPetList:SelectItemByIndex(realIndex - 1)
          end
        end)
      end
      self.currentItemData = self.backpackPetInfos[realIndex]
    end
  end
end

function UMG_PetBag_C:SetPetRemoveFromTeam(PetData, IsTeam)
  if nil == PetData or nil == self.petAddToTeam then
    return
  end
  self.RemovePet = true
  self.teamBigButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CancelBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.petRemoveFromTeam = PetData
  if _G.DataModelMgr.PlayerDataModel:IsInBackpack(self.petAddToTeam.petInfo.gid) and (self.petRemoveFromTeam.gid == "IsNil" or nil == self.petRemoveFromTeam.gid) then
    self.BagPetAddToTeam = true
    self.BagListForceCreate = true
  end
  if self.petRemoveFromTeam.gid == "IsNil" and not _G.DataModelMgr.PlayerDataModel:IsInBackpack(self.petAddToTeam.petInfo.gid) and not IsTeam then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.team_pet_take_empty_bag_place)
    self.RemovePet = false
    self:FadeInButton()
    self:EndAddToBattleTeam()
    return
  elseif (_G.DataModelMgr.PlayerDataModel:IsInBackpack(self.petRemoveFromTeam.gid) or self.petRemoveFromTeam.isInBackPack) and _G.DataModelMgr.PlayerDataModel:IsInBackpack(self.petAddToTeam.petInfo.gid) then
    local changeGid
    if self.petRemoveFromTeam.gid and self.petRemoveFromTeam.gid ~= "IsNil" then
      changeGid = self.petRemoveFromTeam.gid
    end
    local AddPetGid = self.petAddToTeam.petInfo.gid
    if changeGid == AddPetGid then
      self:FadeInButton()
      self:EndAddToBattleTeam()
      self:SelectPetByGid(AddPetGid)
      self.RemovePet = false
      return
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetBackInfoInfo, changeGid, AddPetGid)
  else
    local new_team_pet_gid = {}
    local curSelectItemInTeamIndex = _G.DataModelMgr.PlayerDataModel:GetPlayerBattleTeamIndexByGid(self.petAddToTeam.petInfo.gid)
    local PetRemoveItemInTeamIndex = IsTeam and curSelectItemInTeamIndex and (_G.DataModelMgr.PlayerDataModel:GetPlayerBattleTeamIndexByGid(self.petRemoveFromTeam.gid) or self.TeamIndex) or false
    local remove_team_pet_gid = {}
    local isSameTeam = curSelectItemInTeamIndex == PetRemoveItemInTeamIndex
    if PetRemoveItemInTeamIndex and not isSameTeam then
      PetRemoveItemInTeamIndex = PetRemoveItemInTeamIndex - 1
      local RemovePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(PetRemoveItemInTeamIndex)
      for i, v in ipairs(RemovePetList) do
        if v.gid == self.petRemoveFromTeam.gid then
          table.insert(remove_team_pet_gid, self.petAddToTeam.petInfo.gid)
        else
          table.insert(remove_team_pet_gid, v.gid)
        end
      end
      if nil == self.petRemoveFromTeam.gid or self.petRemoveFromTeam.gid == "IsNil" and IsTeam then
        table.insert(remove_team_pet_gid, self.petAddToTeam.petInfo.gid)
      end
    end
    local addTeamIndex = curSelectItemInTeamIndex or self.TeamIndex
    local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(addTeamIndex - 1)
    local IsChangeBattleListPet = false
    if self.BattlePetListSelect then
      local petaddindex = 1
      local petremoveindex = 1
      for i, pet_data in ipairs(battlePetList) do
        table.insert(new_team_pet_gid, pet_data.gid)
        if self.petAddToTeam.petInfo.gid == pet_data.gid then
          petaddindex = i
        end
        if self.petRemoveFromTeam.gid == pet_data.gid then
          petremoveindex = i
          IsChangeBattleListPet = true
        end
      end
      if IsChangeBattleListPet then
        table.remove(new_team_pet_gid, petaddindex)
        table.insert(new_team_pet_gid, petaddindex, self.petRemoveFromTeam.gid)
        table.remove(new_team_pet_gid, petremoveindex)
        table.insert(new_team_pet_gid, petremoveindex, self.petAddToTeam.petInfo.gid)
      else
        table.clear(new_team_pet_gid)
        new_team_pet_gid = {}
        for i, pet_data in ipairs(battlePetList) do
          if pet_data.gid ~= self.petAddToTeam.petInfo.gid then
            table.insert(new_team_pet_gid, pet_data.gid)
          elseif self.petRemoveFromTeam.gid and self.petRemoveFromTeam.gid ~= "IsNil" then
            table.insert(new_team_pet_gid, self.petRemoveFromTeam.gid)
          end
        end
        if nil == self.petAddToTeam.petInfo.gid then
          table.insert(new_team_pet_gid, self.petRemoveFromTeam.gid)
        end
        if (nil == self.petRemoveFromTeam.gid or self.petRemoveFromTeam.gid == "IsNil") and isSameTeam then
          table.insert(new_team_pet_gid, self.petAddToTeam.petInfo.gid)
        end
      end
    else
      for i, pet_data in ipairs(battlePetList) do
        if pet_data.gid ~= self.petRemoveFromTeam.gid then
          table.insert(new_team_pet_gid, pet_data.gid)
        else
          table.insert(new_team_pet_gid, self.petAddToTeam.petInfo.gid)
        end
      end
      if nil == self.petRemoveFromTeam.gid or self.petRemoveFromTeam.gid == "IsNil" then
        table.insert(new_team_pet_gid, self.petAddToTeam.petInfo.gid)
      end
    end
    Log.Debug("\233\152\159\228\188\141\230\155\180\230\141\162\228\191\161\230\129\175", table.tostring(req))
    self.preBackpackPets = {}
    local petAddToTeamGid, petRemoveFromTeamGid
    if not IsChangeBattleListPet and self.BattlePetListSelect then
      petAddToTeamGid = self.petRemoveFromTeam.gid
      petRemoveFromTeamGid = self.petAddToTeam.petInfo.gid
    else
      petAddToTeamGid = self.petAddToTeam.petInfo.gid
      petRemoveFromTeamGid = self.petRemoveFromTeam.gid
    end
    if _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.backpack_info and _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.backpack_info.pet_gid and #_G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.backpack_info.pet_gid >= 1 then
      for _, item in ipairs(_G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.backpack_info.pet_gid) do
        if item ~= petAddToTeamGid then
          self.preBackpackPets[item] = true
        end
      end
    end
    if nil ~= self.petRemoveFromTeam.gid and self.petRemoveFromTeam.gid ~= "IsNil" then
      self.preBackpackPets[petRemoveFromTeamGid] = true
    end
    self.bIsPendingResPetUpdatePkg = true
    local teams = {}
    for i = 1, #new_team_pet_gid do
      local teamPetInfo = _G.ProtoMessage:newPetTeam_PetInfo()
      teamPetInfo.pet_gid = new_team_pet_gid[i]
      table.insert(teams, teamPetInfo)
    end
    local teamList = {}
    local teamIndexList = {}
    table.insert(teamList, teams)
    table.insert(teamIndexList, addTeamIndex - 1)
    if #remove_team_pet_gid > 0 then
      local teams1 = {}
      for i = 1, #remove_team_pet_gid do
        local teamPetInfo = _G.ProtoMessage:newPetTeam_PetInfo()
        teamPetInfo.pet_gid = remove_team_pet_gid[i]
        table.insert(teams1, teamPetInfo)
      end
      table.insert(teamList, teams1)
      table.insert(teamIndexList, PetRemoveItemInTeamIndex)
      self.TeamIndex = PetRemoveItemInTeamIndex + 1
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamsInfo, teamList, teamIndexList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  end
end

function UMG_PetBag_C:OnPetUpdate(rsp)
  self.bIsPendingResPetUpdatePkg = false
  if 0 == rsp.ret_info.ret_code then
    local new_backpack_info = {}
    self.NRCButton_68:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCButton:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetTeamInfo()
    self:SetBattlePetList()
    if self.IsBtnToExChange then
      self.module.NotChangeAnim = true
    else
      self.module.NotChangeAnim = false
    end
    if self.petAddToTeam then
      local AddToTeamGid = self.petAddToTeam.petInfo.gid
      self:DelayFrames(2, function()
        self:SelectPetByGid(AddToTeamGid)
      end)
    else
      local petInfo = self.currentItemData and self.currentItemData.petInfo
      local gid = petInfo and petInfo.gid
      Log.Warning("[UMG_PetBag_C] cannot found pet pending add to team when receive server update pkg, current:", gid)
      if gid then
        if _G.RocoEnv.IS_EDITOR then
          local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id)
          Log.Warning("[UMG_PetBag_C] pet=", petInfo.base_conf_id, "name=", petBaseConf and petBaseConf.name)
        end
        self:SelectPetByGid(gid)
      end
    end
    self:FadeInButton()
    self:EndAddToBattleTeam()
    self:UpdateResonanceList()
  else
    self:FadeInButton()
    self.BagPetAddToTeam = false
    Log.Error("\230\155\180\230\141\162\229\174\160\231\137\169\229\155\158\229\140\133\229\164\177\232\180\165")
    self:EndAddToBattleTeam()
  end
  self.RemovePet = false
end

function UMG_PetBag_C:SelectPetByGid(gid)
  for index, item in ipairs(self.battlePetInfos) do
    if item.petInfo.gid == gid then
      self.BattlePetList:SelectItemByIndex(index - 1)
      return
    end
  end
  for index, item in ipairs(self.backpackPetInfos) do
    if item.petInfo.gid == gid then
      local ListItem = self.BagPetList:GetItemByIndex(index - 1)
      if ListItem then
        ListItem.preparedForChange = false
      end
      self.BagPetList:SelectItemByIndex(index - 1)
      self.PetBagDragList:SetInfo(nil, self.BagPetList:GetScrollOffset())
      return
    end
  end
  local realIndex = self:GetListRealIndex(self.TeamIndex, 1)
  self:DelayFrames(2, function()
    self.BattlePetList:SelectItemByIndex(realIndex - 1)
  end)
end

function UMG_PetBag_C:SelectPetBagByGid(gid)
  for index, item in ipairs(self.battlePetInfos) do
    if item.petInfo.gid == gid then
      self.BattlePetList:SelectItemByIndex(index - 1)
      return
    end
  end
  for index, item in ipairs(self.backpackPetInfos) do
    if item.petInfo.gid == gid then
      self.BagPetList:SelectItemByIndex(index - 1)
      self.ScrollBox_192:SetScrollOffset(999)
      return
    end
  end
  local realIndex = self:GetListRealIndex(self.TeamIndex, 1)
  self.BattlePetList:SelectItemByIndex(realIndex - 1)
end

function UMG_PetBag_C:FadeOutButton()
  self.Button:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if self.owner then
    if UE4.UObject.IsValid(self.owner.petInfoMainCtrl) then
      self.owner.petInfoMainCtrl.UMG_btnClose:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
    self.owner.CloseBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    Log.Error("UMG_PetBag_C:FadeOutButton: self.Owner is nil")
  end
  self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.backBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Btn_AndSetThemFree:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetBag_C:FadeInButton(_isEvo)
  if self.owner then
    if not _isEvo and UE4.UObject.IsValid(self.owner.petInfoMainCtrl) then
      self.owner.petInfoMainCtrl.UMG_btnClose:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if self.owner.CloseBtn then
      self.owner.CloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      Log.Error("UMG_PetBag_C:FadeInButton: CloseBtn is nil")
    end
  else
    Log.Error("UMG_PetBag_C:FadeInButton: self.Owner is nil")
  end
  self.UMG_Btn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.backBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_Btn:SetRenderOpacity(1.0)
end

function UMG_PetBag_C:TrainPet()
  self:OnClosePetBag()
end

function UMG_PetBag_C:OnPetSelect()
end

function UMG_PetBag_C:OnTrainPetSelect(selected)
end

function UMG_PetBag_C:OnGlobalPetItemClick(index)
  if self.selectedPet and index <= 6 then
    self:OnTrainPetSelect(false)
  end
end

function UMG_PetBag_C:UpdatePetListInfo(_petData)
  for index, item in ipairs(self.battlePetInfos) do
    if item.petInfo.gid == _petData.gid then
      item.petInfo.petData = _petData
    end
  end
  for index, item in ipairs(self.backpackPetInfos) do
    if item.petInfo.gid == _petData.gid then
      item.petInfo.petData = _petData
    end
  end
  for i = 0, #self.battlePetInfos - 1 do
    local item = self.BattlePetList:GetItemByIndex(i)
    if item and item.uiData.gid == _petData.gid then
      item:UpdatePetData(_petData)
    end
  end
  for i = 0, #self.backpackPetInfos - 1 do
    local item = self.BagPetList:GetItemByIndex(i)
    if item and item.uiData and item.uiData.gid == _petData.gid then
      item:UpdatePetData(_petData)
    end
  end
end

function UMG_PetBag_C:PetBagSetVisibility(visibility)
  self:SetVisibility(visibility)
end

function UMG_PetBag_C:PetBagPlayEvoAnim()
  self:PlayAnimation(self.To_Jinhua_3)
end

function UMG_PetBag_C:PetBagPlayEvoBackAnim()
  self:PlayAnimation(self.BackTo_Jingling_3)
end

function UMG_PetBag_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_PetBagUI")
  if mappingContext then
    mappingContext:BindAction("IA_ClosePetBagUI", self, "OnPcClose2")
  end
end

function UMG_PetBag_C:OnPcClose2()
  self:OnClosePetBag()
end

function UMG_PetBag_C:RefreshAttributeInfo()
  self:SetBattlePetList()
  if UE4.UObject.IsValid(self.owner.petInfoMainCtrl) then
    self:OnPetItemClickAlwaysClick(self.owner.petInfoMainCtrl.currentSelectedPetIndex, true)
  end
end

function UMG_PetBag_C:OnInitDragItem()
  if not self.DragItemInstance and self.startPos then
    self.DragItemInstance = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), self.DragItem)
    if self.DragItemInstance then
      self.DragItemInstance:AddToViewport(_G.UILayerCtrlCenter.ENUM_LAYER.TOP_MSG, false)
      self.DragItemInstance:SetAlignmentInViewport(UE4.FVector2D(0.5, 0.5))
      self:ShowDragItemStartPos()
    end
  elseif self.DragItemInstance then
    self:ShowDragItemStartPos()
  end
end

function UMG_PetBag_C:OnTryDisableDragItem()
  self.DragItemInstance:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.startPos = UE4.FVector2D(0, 0)
end

function UMG_PetBag_C:ShowDragItemStartPos()
  if self.DragItemInstance then
    if RocoEnv.PLATFORM_WINDOWS then
      local mousePos = UE4.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.UE4Helper.GetCurrentWorld())
      self.DragItemInstance:SetPositionInViewport(mousePos, false)
    else
      self.DragItemInstance:SetPositionInViewport(self.startPos, true)
    end
  end
  if self.DragData then
    self.DragItemInstance:AsDragItemInitInfo(self.DragData)
  end
  self.DragItemInstance:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_PetBag_C:OnRocoTouchMoveHandler(touchIndex, position)
  if self.CanScroll then
    return
  end
  if RocoEnv.PLATFORM_WINDOWS then
    local mousePos = UE4.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.UE4Helper.GetCurrentWorld())
    self.DragItemInstance:SetPositionInViewport(mousePos, false)
  else
    self.DragItemInstance:SetPositionInViewport(position, true)
  end
end

function UMG_PetBag_C:OnRocoTouchStartHandler(touchIndex, position)
  self.startPos.X = position.X
  self.startPos.Y = position.Y
end

function UMG_PetBag_C:OnTouchEnded(_MyGeometry, _TouchEvent)
  _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.SetPanelCanScroll, true)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_PetBag_C:GetSortPriority(IsInTravel, IsInHome, IsInGuard)
  if IsInTravel then
    return 1
  elseif IsInGuard then
    return 2
  elseif IsInHome then
    return 3
  else
    return 0
  end
end

function UMG_PetBag_C:OnBeginGuideTarget(config)
  if config and config:IsStrongGuide() then
    self.ScrollPageController.LongPressDrag = false
    self.IsBtnToExChange = true
  end
end

function UMG_PetBag_C:OnEndGuideTarget(config)
  if config and config:IsStrongGuide() then
    self.ScrollPageController.LongPressDrag = true
    self.IsBtnToExChange = false
  end
end

function UMG_PetBag_C:OnSendPetSuccess()
  self.oldIndex = self.BagPetList:GetSelectedIndex()
  self:SetBattlePetList(nil, true)
  self:DelaySeconds(0.1, function()
    local itemCount = self.BagPetList:GetTotalItemNumber()
    if itemCount >= self.oldIndex and self.oldIndex > 0 then
      self.BagPetList:SelectItemByIndex(self.oldIndex - 1)
    elseif itemCount > 0 and itemCount <= self.oldIndex and self.oldIndex - 2 >= 0 then
      self.BagPetList:SelectItemByIndex(self.oldIndex - 2)
    else
      local BattlePetCount = self.BattlePetList:GetTotalItemNumber()
      if BattlePetCount > 0 then
        self.BattlePetList:SelectItemByIndex(0)
      end
    end
  end)
end

return UMG_PetBag_C
