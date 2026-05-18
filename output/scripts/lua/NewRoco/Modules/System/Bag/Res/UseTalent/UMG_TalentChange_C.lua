local PetUtils = require("NewRoco.Utils.PetUtils")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_TalentChange_C = _G.NRCPanelBase:Extend("UMG_TalentChange_C")

function UMG_TalentChange_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_TalentChange_C:OnDestruct()
end

function UMG_TalentChange_C:OnActive()
  self.data = self.module:GetData("BagModuleData")
  self.PetItemData = self.data.PetTalentItem
  self.BagItem = self.data:GetCurSelectedItemData()
  self:SetCommonPopUpInfo(self.PopUp3)
  self.PopUp3:SetBtnRightEnableStateNew(false)
  if self.BagItem then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
    self.UseAction = BagItemConf.item_behavior[1].use_action
  end
  self:SetItemList()
end

function UMG_TalentChange_C:SetItemList()
  local petlevel = PetUtils.GetBreakThroughStarsList(self.PetItemData)
  local LevelNum = 0
  for i = 1, #petlevel do
    if 1 == petlevel[i].IsShow then
      LevelNum = LevelNum + 1
    end
  end
  local attribute_info = self.PetItemData.attribute_info
  local AttributeList = {}
  local ChangeTalent = self.data.ChangeTalent
  table.insert(AttributeList, {
    type = Enum.AttributeType.AT_HPMAX,
    num = attribute_info.hp.talent,
    ChangeTalent = ChangeTalent,
    LevelNum = LevelNum,
    UseAction = self.UseAction
  })
  table.insert(AttributeList, {
    type = Enum.AttributeType.AT_PHYATK,
    num = attribute_info.attack.talent,
    ChangeTalent = ChangeTalent,
    LevelNum = LevelNum,
    UseAction = self.UseAction
  })
  table.insert(AttributeList, {
    type = Enum.AttributeType.AT_SPEATK,
    num = attribute_info.special_attack.talent,
    ChangeTalent = ChangeTalent,
    LevelNum = LevelNum,
    UseAction = self.UseAction
  })
  table.insert(AttributeList, {
    type = Enum.AttributeType.AT_PHYDEF,
    num = attribute_info.defense.talent,
    ChangeTalent = ChangeTalent,
    LevelNum = LevelNum,
    UseAction = self.UseAction
  })
  table.insert(AttributeList, {
    type = Enum.AttributeType.AT_SPEDEF,
    num = attribute_info.special_defense.talent,
    ChangeTalent = ChangeTalent,
    LevelNum = LevelNum,
    UseAction = self.UseAction
  })
  table.insert(AttributeList, {
    type = Enum.AttributeType.AT_SPEED,
    num = attribute_info.speed.talent,
    ChangeTalent = ChangeTalent,
    LevelNum = LevelNum,
    UseAction = self.UseAction
  })
  self.SortList:InitGridView(AttributeList)
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_TalentChange_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.SetPetTalentChangeItemSelect, self.OnItemSelected)
end

function UMG_TalentChange_C:OnItemSelected(Data)
  self.selectType = Data
  self.PopUp3:SetBtnRightEnableStateNew(true)
end

function UMG_TalentChange_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnOk
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_TalentChange_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_PetCharacter_C", self, BagModuleEvent.SetPetTalentChangeItemSelect, self.OnItemSelected)
end

function UMG_TalentChange_C:OnCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
  self.IsOkBtn = false
end

function UMG_TalentChange_C:OnOk()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnClose")
  if not self.selectType then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.change_attribute_select_tip)
    return
  end
  self:LoadAnimation(2)
  self.IsOkBtn = true
end

function UMG_TalentChange_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    if self.IsOkBtn then
      self.data.ResultTalentType = self.selectType
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.TalentChange, false)
    else
      self.data.ResultTalentType = nil
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.TalentChange, false)
    end
  end
end

return UMG_TalentChange_C
