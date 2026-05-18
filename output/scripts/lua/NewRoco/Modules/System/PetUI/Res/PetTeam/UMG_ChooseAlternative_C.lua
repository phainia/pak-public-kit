local UMG_ChooseAlternative_C = _G.NRCPanelBase:Extend("UMG_ChooseAlternative_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_ChooseAlternative_C:OnActive(type, Data, petIndex, skillIndex, firstSkillValid, petGid)
  _G.NRCAudioManager:PlaySound2DAuto(41400009, "UMG_ChooseAlternative_C:OnActive")
  self:OnAddEventListener()
  self.type = type
  self.firstSkillValid = firstSkillValid
  if 1 == type then
    local dataList = {}
    for i, skillID in ipairs(Data) do
      if #dataList >= 3 then
        break
      end
      local data = {}
      data.id = skillID
      data.parent = self
      data.type = type
      if 1 == i then
        if firstSkillValid then
          local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid)
          local petBaseID = petData.base_conf_id
          local itemDosageInfoList, _, _, skillUnLockInfoList = NRCModuleManager:DoCmd(PetUIModuleCmd.CalcuSkillLearningNeedItems, skillID, petBaseID, petGid)
          data.petGid = petGid
          if itemDosageInfoList then
            self.firstSkillCanLearn = true
          end
          table.insert(dataList, data)
        end
      else
        table.insert(dataList, data)
      end
    end
    self.dataList = dataList
    self.petIndex = petIndex
    self.skillIndex = skillIndex
    self.NRCGridView_95:InitGridView(dataList)
  elseif 2 == type then
    local dataList = {}
    for i, data in ipairs(Data) do
      if i > 3 then
        break
      end
      dataList[i] = {}
      dataList[i].MagicData = data
      dataList[i].parent = self
      dataList[i].type = type
    end
    self.dataList = dataList
    self.NRCGridView_95:InitGridView(dataList)
    self.PopUp2.TitleText:SetText(LuaText.lineup_code_select_magic)
  end
  self.NRCGridView_95:SelectItemByIndex(0)
  self.selectIndex = 1
  self.PopUp2.Btn_Right.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.firstSkillValid then
  end
end

function UMG_ChooseAlternative_C:OnDeactive()
end

function UMG_ChooseAlternative_C:OnAddEventListener()
  self:AddButtonListener(self.PopUp2.btnClose.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.PopUp2.Btn_Right.btnLevelUp, self.OnSaveBtnClick)
  self:AddButtonListener(self.PopUp2.Btn_Left.btnLevelUp, self.OnCloseBtnClick)
  self:RegisterEvent(self, PetUIModuleEvent.SetDescText, self.OnDescTextClicked)
end

function UMG_ChooseAlternative_C:OnCloseHyperLink()
end

function UMG_ChooseAlternative_C:OnDescTextClicked(id)
  local descNote = _G.DataConfigManager:GetDescNoteConf(tonumber(id))
  local descText = string.format("\227\128\144%s\227\128\145\n%s", descNote.note, descNote.desc)
end

function UMG_ChooseAlternative_C:OnCloseBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_ChooseAlternative_C:OnCloseBtnClick")
  self:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_ChooseAlternative_C:OnCloseBtnClick")
  NRCModuleManager:DoCmd(PetUIModuleCmd.CloseSkillLearningPanel)
end

function UMG_ChooseAlternative_C:ChangeSelectIndex(index)
  self.selectIndex = index
end

function UMG_ChooseAlternative_C:OnSaveBtnClick()
  if self.selectIndex then
    if 1 == self.type then
      if self.firstSkillValid and 1 == self.selectIndex then
        if self.firstSkillCanLearn then
          local skillID = self.dataList[1].id
          local petGid = self.dataList[1].petGid
          local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid)
          if petDataInfo then
            local petBaseID = petDataInfo.base_conf_id
            local SkillSourceList = NRCModuleManager:DoCmd(PetUIModuleCmd.GetSkillSourceAndUnlockInfo, skillID, petBaseID, petGid)
            NRCModuleManager:DoCmd(PetUIModuleCmd.OpenSkillLearningPanel, SkillSourceList[1])
            self:OnClose()
          end
        else
          _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.lineup_cant_learn_skill)
        end
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.lineup_code_select_recommend_skill)
        NRCEventCenter:DispatchEvent(PetUIModuleEvent.ChangePetSkill, self.petIndex, self.skillIndex, self.dataList[self.selectIndex].id)
        self:OnClose()
      end
    elseif 2 == self.type then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.lineup_code_select_recommend_magic)
      NRCEventCenter:DispatchEvent(PetUIModuleEvent.ChangeTeamMagic, self.dataList[self.selectIndex].MagicData.id)
      self:OnClose()
    end
  else
    Log.Error("\230\156\170\233\128\137\228\184\173")
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_ChooseAlternative_C:OnSaveBtnClick")
end

function UMG_ChooseAlternative_C:SetConsumeItem(costItems, data, itemSynthesisInfos)
  self.dosageInfoList = costItems
  self.data = data
  self.itemSynthesisInfos = itemSynthesisInfos
end

function UMG_ChooseAlternative_C:UseConsumeItem()
  if self.data.type == Enum.PetNewSkillSrc.PNSS_PET_LEVEL_UP then
    local UseItemList = {}
    if self.dosageInfoList then
      for i, dosageInfo in pairs(self.dosageInfoList) do
        if dosageInfo.needUseNum > 0 and dosageInfo.item then
          table.insert(UseItemList, {
            gid = dosageInfo.item.gid,
            num = dosageInfo.needUseNum,
            para = self.data.petGid
          })
        end
      end
    end
    if #UseItemList > 0 then
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.UseExpItem, UseItemList)
    end
  elseif self.data.type == Enum.PetNewSkillSrc.PNSS_SKILL_BOOK or self.data.type == Enum.PetNewSkillSrc.PNSS_PET_BLOOD then
    local itemSynthesisInfo = self.itemSynthesisInfos[self.formulaIndex]
    if itemSynthesisInfo.exchangeId then
    else
      local bagItem = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, itemSynthesisInfo.id)
      if bagItem then
        _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.UseBagItem, bagItem.gid, 1, self.petData.gid)
      end
    end
  end
end

function UMG_ChooseAlternative_C:OnCancelBtnClick()
  self:OnClose()
end

return UMG_ChooseAlternative_C
