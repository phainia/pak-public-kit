local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_MagicBook_C = _G.NRCPanelBase:Extend("UMG_MagicBook_C")

function UMG_MagicBook_C:OnActive(curNPCID)
  if _G.GlobalConfig.DebugOpenUI then
    self:SetCommonPopUpInfo()
    return
  end
  self.HasBadgeFlag = false
  self.curNPCID = curNPCID
  self.NPCDataList = NRCModuleManager:DoCmd(BagModuleCmd.GetRosterData)
  self.finalPageIndex = #self.NPCDataList
  local req = _G.ProtoMessage:newZoneMageBookAwardReq()
  req.npc_id = curNPCID
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_MAGE_BOOK_AWARD_REQ, req, self, self.OnGetRewardRsp)
  for i, NRCData in ipairs(self.NPCDataList) do
    if NRCData.id == curNPCID then
      self.CurPageIndex = i
      self.UIData = self.NPCDataList[i]
      break
    end
  end
  self:SetCommonPopUpInfo()
  self:SetBtnArrow()
  self:UpdateUI()
  UE4Helper.SetDesiredShowCursor(true, "UMG_MagicBook_C")
  self:LoadAnimation(0)
end

function UMG_MagicBook_C:OnGetRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.ret_info.goods_reward and rsp.ret_info.goods_reward.rewards then
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, rsp.ret_info.goods_reward.rewards)
  end
end

function UMG_MagicBook_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_MagicBook_C")
end

function UMG_MagicBook_C:OnAddEventListener()
end

function UMG_MagicBook_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self.describeText = {
    self.addNumTxt,
    self.addNumTxt_2,
    self.addNumTxt_3,
    self.addNumTxt_4,
    self.addNumTxt_5,
    self.addNumTxt_6,
    self.addNumTxt_7
  }
  self.ParticleSystem = {
    self.ParticleSystemWidget2_74,
    self.ParticleSystemWidget2,
    self.ParticleSystemWidget2_1,
    self.ParticleSystemWidget2_2
  }
  self:OnAddEventListener()
end

function UMG_MagicBook_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_MagicBook_C:SetBtnArrow()
  local CommonBtnArrowData1 = {}
  CommonBtnArrowData1.Call = self
  CommonBtnArrowData1.btnHandler = self.OnNextPageBtnClick
  CommonBtnArrowData1.modeIndex = 2
  self.Btn1:SetBtnInfo(CommonBtnArrowData1)
  local CommonBtnArrowData2 = {}
  CommonBtnArrowData2.Call = self
  CommonBtnArrowData2.btnHandler = self.OnPrePageBtnClick
  CommonBtnArrowData2.modeIndex = 1
  self.Btn2:SetBtnInfo(CommonBtnArrowData2)
end

function UMG_MagicBook_C:UpdateUI()
  self.unlockRes = nil
  self.lockRes = nil
  if 1 == self.CurPageIndex then
    self.PopUp2:ShowOrHideBtnLeft(false)
    self.Btn2:SetBtnIcon()
  else
    self.PopUp2:ShowOrHideBtnLeft(true)
    local MageConf = _G.DataConfigManager:GetMageConf(self.NPCDataList[self.CurPageIndex - 1].id)
    self.Btn2:SetBtnIcon(2, MageConf.avatar_res)
    self.PopUp2:SetBtnLeftText(string.format("<%s", MageConf.mage_name))
  end
  if self.CurPageIndex == self.finalPageIndex then
    self.PopUp2:ShowOrHideBtnRight(false)
    self.Btn1:SetBtnIcon()
  else
    self.PopUp2:ShowOrHideBtnRight(true)
    local MageConf = _G.DataConfigManager:GetMageConf(self.NPCDataList[self.CurPageIndex + 1].id)
    if MageConf then
      self.Btn1:SetBtnIcon(2, MageConf.avatar_res)
      self.PopUp2:SetBtnRightText(string.format("%s>", MageConf.mage_name))
    end
  end
  local MageConf = _G.DataConfigManager:GetMageConf(self.curNPCID)
  local iconPath = MageConf.avatar_res
  self.Head:SetPath(iconPath)
  self.Text_Name:SetText(MageConf.mage_name)
  self.Text_Name_1:SetText(MageConf.lune_name)
  local ParticleSystemIndex = 0
  if self.UIData.items then
    for i, dialogData in ipairs(self.UIData.items) do
      if dialogData.unlocked == true then
        local MageInfoConf = _G.DataConfigManager:GetMageInfoConf(dialogData.id)
        self.describeText[i]:SetText(MageInfoConf.text)
        self.describeText[i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        ParticleSystemIndex = math.floor((i + 1) / 2)
        self.ParticleSystem[ParticleSystemIndex]:SetActivate(true)
        if MageInfoConf.lock_res then
          self.lockRes = MageInfoConf.lock_res
        end
        if MageInfoConf.unlock_res then
          self.unlockRes = MageInfoConf.unlock_res
        else
          self.Switcher:SetActiveWidgetIndex(0)
        end
        if MageInfoConf.sp_res then
          self.HasBadgeFlag = true
          self.Badge:SetPath(MageInfoConf.sp_res)
          self.Badge:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        elseif self.HasBadgeFlag == false then
          self.Badge:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
    if self.unlockRes then
      self.Unlocked:SetPath(self.unlockRes)
      self.Switcher:SetActiveWidgetIndex(1)
    elseif self.lockRes then
      self:LoadPanelRes(self.lockRes, 255, self.OnLoadImageResSucc)
      self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Switcher:SetActiveWidgetIndex(0)
    else
      Log.Error("\231\188\186\229\176\145\229\137\170\229\189\177\229\155\190\231\137\135 \231\173\137\229\190\133\231\173\150\229\136\146\233\133\141\231\189\174")
    end
  end
  for i = ParticleSystemIndex + 1, 4 do
    self.ParticleSystem[i]:SetActivate(false)
  end
  local startIndex = 1
  if self.UIData.items then
    startIndex = #self.UIData.items + 1
  end
  for i = startIndex, #self.describeText do
    self.describeText[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  NRCModuleManager:DoCmd(RedPointModuleCmd.EraseRedPoint, 241, {
    tostring(self.curNPCID)
  }, true)
end

function UMG_MagicBook_C:OnLoadImageResSucc(req, asset)
  self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local material = self.Lock:GetDynamicMaterial()
  material:SetTextureParameterValue("SpriteTexture", asset)
end

function UMG_MagicBook_C:SetSketchImage(image)
  local material = image:GetDynamicMaterial()
  material:SetTextureParameterValue("SpriteTexture", self.LockOrigin.Brush.ResourceObject)
  image:SetBrushFromMaterial(material, false)
end

function UMG_MagicBook_C:OnPrePageBtnClick()
  if self.CurPageIndex <= 1 then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_MagicBook_C:OnPrePageBtnClick")
  self.HasBadgeFlag = false
  self.CurPageIndex = self.CurPageIndex - 1
  self.UIData = self.NPCDataList[self.CurPageIndex]
  self.curNPCID = self.UIData.id
  self:UpdateUI()
end

function UMG_MagicBook_C:OnNextPageBtnClick()
  if self.CurPageIndex >= self.finalPageIndex then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401008, "UMG_MagicBook_C:OnNextPageBtnClick")
  self.HasBadgeFlag = false
  self.CurPageIndex = self.CurPageIndex + 1
  self.UIData = self.NPCDataList[self.CurPageIndex]
  self.curNPCID = self.UIData.id
  self.unlockRes = nil
  self.lockRes = nil
  self:UpdateUI()
end

function UMG_MagicBook_C:ClosePanel()
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_MagicBook_C:ClosePanel")
end

function UMG_MagicBook_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_MagicBook_C
