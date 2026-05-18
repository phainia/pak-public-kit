local UMG_BagSkillMain_Tips_C = _G.NRCPanelBase:Extend("UMG_BagSkillMain_Tips_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
UMG_BagSkillMain_Tips_C.DamageTypeMap = {
  [1] = nil,
  [2] = 1,
  [3] = 2
}

function UMG_BagSkillMain_Tips_C:OnActive(skillId, _isBagItem, bagItemId, petBaseId, bQuickUnlock, petGid, IsOpenByChangeSkillPanel)
  self.descText = ""
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BagBlood").SKILLTIPS
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BagModule", "BagBlood", touchReasonType)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002013, "UMG_PetBaseInfo_C:OnBtnLevelUpClick")
  self:OnAddEventListener()
  local pos = self.Content.Slot:GetPosition()
  pos.x = 0
  if IsOpenByChangeSkillPanel then
    pos.x = -72
  end
  self.Content.Slot:SetPosition(pos)
  self:RefreshUI(skillId, _isBagItem, bagItemId, petBaseId, bQuickUnlock, petGid)
  self:LoadAnimation(0)
  if -1 == bagItemId then
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnBagSKillTipsPanelShowChange, true)
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_ShutDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_ShutDown_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_ShutDown_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_ShutDown_3:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_ShutDown:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_ShutDown_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_ShutDown_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_ShutDown_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BagSkillMain_Tips_C:OnDeactive()
end

function UMG_BagSkillMain_Tips_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_ShutDown, self.OnClose)
  self:AddButtonListener(self.Btn_ShutDown_1, self.OnClose)
  self:AddButtonListener(self.Btn_ShutDown_2, self.OnClose)
  self:AddButtonListener(self.Btn_ShutDown_3, self.OnClose)
  self:AddButtonListener(self.CloseHyperLink, self.OnCloseHyperLink)
  self:RegisterEvent(self, PetUIModuleEvent.OpenOrCloseSkillTipsPanel, self.IsShouldCloseTips)
  self.NRCTextDes.OnRichTextClick:Add(self, self.OnDescTextClicked)
  self.NRCTextDes_1.OnRichTextClick:Add(self, self.OnDescTextClicked)
end

function UMG_BagSkillMain_Tips_C:OnCloseHyperLink()
end

function UMG_BagSkillMain_Tips_C:OnClose()
  self:RemoveButtonListener(self.Btn_ShutDown, self.OnClose)
  self:RemoveButtonListener(self.Btn_ShutDown_1, self.OnClose)
  self:RemoveButtonListener(self.Btn_ShutDown_2, self.OnClose)
  self:RemoveButtonListener(self.Btn_ShutDown_3, self.OnClose)
  self:RemoveButtonListener(self.CloseHyperLink, self.OnCloseHyperLink)
  self.NRCTextDes.OnRichTextClick:Remove(self, self.OnDescTextClicked)
  self.NRCTextDes_1.OnRichTextClick:Remove(self, self.OnDescTextClicked)
  self:LoadAnimation(2)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ClearSkillList)
  _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnBagSKillTipsPanelShowChange, false)
end

function UMG_BagSkillMain_Tips_C:OnPcClose()
  self:OnClose()
end

function UMG_BagSkillMain_Tips_C:GetSkillTypePath(type, damage_type)
  if type == Enum.SkillType.ST_DAMAGE then
    self.NumericalValue_2:SetText(LuaText.umg_pet_skill_tips_1)
    if damage_type == Enum.DamageType.DT_SPC then
      return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_04_png.ui_pet_attribute_04_png'"
    else
      return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_02_png.ui_pet_attribute_02_png'"
    end
  elseif type == Enum.SkillType.ST_DEFEND then
    self.NumericalValue_2:SetText(LuaText.umg_pet_skill_tips_2)
    return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/AT_DEFENSE_png.AT_DEFENSE_png'"
  else
    self.NumericalValue_2:SetText(LuaText.umg_pet_skill_tips_3)
    return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/AT_CLASSIFICATION_png.AT_CLASSIFICATION_png'"
  end
end

function UMG_BagSkillMain_Tips_C:RefreshUI(skillId, _isBagItem, bagItemId, petBaseId, bQuickUnlock, petGid)
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BagBlood").SKILLTIPS
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BagModule", "BagBlood", touchReasonType)
  self.skillId = skillId
  self:OnCloseHyperLink()
  local skillConf = _G.DataConfigManager:GetSkillConf(skillId)
  local commonAttrData = {}
  if skillConf then
    self.SkillIcon:SetPath(skillConf.icon)
    self.SkillNameTxt:SetText(skillConf.name)
    local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
    if typeDic then
      table.insert(commonAttrData, {
        Path = typeDic.tips_res
      })
    end
    self.Department:SetPath(self:GetSkillTypePath(skillConf.Skill_Type, skillConf.damage_type))
    if 1 ~= skillConf.damage_type then
      if commonAttrData[1] then
        commonAttrData[1].Name = tostring(skillConf.dam_para[1])
      end
    elseif commonAttrData[1] then
      commonAttrData[1].Name = "-"
    end
    self.descText = skillConf.desc
    self.NRCTextDes:SetText(skillConf.desc)
    self.NRCTextDes_1:SetText(skillConf.flavor_text)
    self.NumericalValue_1:SetText(skillConf.energy_cost[1])
    if skillConf.type == Enum.SkillActiveType.SAT_LEGENDARY then
      self.BeastSkill:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BeastSkill:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.Attr then
      self.Attr:InitGridView(commonAttrData)
    end
  else
    Log.Debug("\230\137\190\228\184\141\229\136\176\232\191\153\228\184\170\230\138\128\232\131\189", skillId)
  end
  if true == _isBagItem then
    self.Type:SetRenderOpacity(0)
    self.HorizontalBox_0:SetRenderOpacity(0)
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, bagItemId)
    local bagItemInfo = _G.DataConfigManager:GetBagItemConf(bagItemId)
    self.Type:SetText(bagItemInfo.type_desc)
    if nil ~= bagItemData then
      self.OwnedText:SetText(tostring(bagItemData.num))
    else
      self.OwnedText:SetText("0")
    end
  else
    self.Type:SetRenderOpacity(0)
    self.HorizontalBox_0:SetRenderOpacity(0)
  end
  self.PromptAcquisitionView:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if petBaseId then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
    if petBaseConf then
      local skillSourceList = _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.GetSkillSourceAndUnlockInfo, skillId, petBaseId, petGid)
      for i, v in pairs(skillSourceList) do
        v.bQuickUnlock = bQuickUnlock
        v.MaxDesiredWidth = 460
      end
      if #skillSourceList > 0 then
        local isTrialPet, trialPetData = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdIsTrailPet, petGid)
        if isTrialPet then
          local icon = skillSourceList[1].icon
          self.PromptAcquisitionView:InitGridView({
            {
              text = LuaText.skill_source_desc_11,
              icon = icon
            }
          })
        else
          self.PromptAcquisitionView:InitGridView(skillSourceList)
        end
        self.PromptAcquisitionView:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_BagSkillMain_Tips_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002014, "UMG_PetBaseInfo_C:OnBtnLevelUpClick")
    self:DoClose()
  end
end

function UMG_BagSkillMain_Tips_C:IsShouldCloseTips(_IsShould)
  if _IsShould then
    self:OnClose()
  end
end

function UMG_BagSkillMain_Tips_C:OnDescTextClicked(id)
  local nounInterpretationTipsInfo = {}
  nounInterpretationTipsInfo.text = self.descText
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
end

function UMG_BagSkillMain_Tips_C:GetCurShowSkillId()
  return self.skillId or 0
end

return UMG_BagSkillMain_Tips_C
