local UMG_RelationTree_IntimacyTips_C = _G.NRCPanelBase:Extend("UMG_RelationTree_IntimacyTips_C")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")

function UMG_RelationTree_IntimacyTips_C:OnActive(PetData)
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_RelationTree_IntimacyTips_C:OnActive")
  self:OnAddEventListener()
  self:UpdateBaseUI()
  self:UpdateClosenessUI()
end

function UMG_RelationTree_IntimacyTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnCloseClick)
end

function UMG_RelationTree_IntimacyTips_C:UpdateBaseUI()
  local PetData = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetPetInfoData)
  if PetData then
    local Name = PetData.name or ""
    self.NameTxt:SetText(Name)
    local level = PetData.level or 0
    self.LvTxt:SetText(level)
    local TargetPetBaseId = PetData.base_conf_id or 0
    local MutationType = PetData.mutation_type or 0
    local GlassInfo = PetData.glass_info
    self.HeadIcon:SetIconPathAndMaterial(TargetPetBaseId, MutationType, GlassInfo)
    local gender = PetData.gender or 1
    for i = 1, 2 do
      local StrInc = string.format("ImagePetGender%s", tostring(i))
      if self[StrInc] then
        if gender == i then
          self[StrInc]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          self[StrInc]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
end

function UMG_RelationTree_IntimacyTips_C:UpdateClosenessUI()
  local PetData = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetPetInfoData)
  if PetData then
    local ClosenessLv, CurClosenessExp = 0, 0
    if PetData.closeness_info and PetData.closeness_info.closeness_lv and PetData.closeness_info.closeness_lv >= 0 then
      ClosenessLv = PetData.closeness_info.closeness_lv
    end
    if PetData.closeness_info and PetData.closeness_info.closeness_exp and PetData.closeness_info.closeness_exp >= 0 then
      CurClosenessExp = PetData.closeness_info.closeness_exp
    end
    self.IntimacyText:SetText(ClosenessLv)
    local BaseId = PetData.base_conf_id or 0
    if BaseId > 0 then
      local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(BaseId)
      if PetBaseConf then
        local BondData = _G.DataConfigManager:GetPetBond(PetBaseConf.pet_bond_id)
        if BondData then
          local CloseLevelNeedExpList = BondData.close_level_need_exp
          local CurNeedExp = CloseLevelNeedExpList[ClosenessLv + 1]
          if ClosenessLv == #CloseLevelNeedExpList - 1 then
            self.HpBarYellow:SetPercent(1)
          elseif ClosenessLv >= 1 then
            local PercentExp = CurClosenessExp - CloseLevelNeedExpList[ClosenessLv]
            local NexMaxPercentExp = CloseLevelNeedExpList[ClosenessLv + 1] - CloseLevelNeedExpList[ClosenessLv]
            self.HpBarYellow:SetPercent(PercentExp / NexMaxPercentExp)
          else
            self.HpBarYellow:SetPercent(CurClosenessExp / CloseLevelNeedExpList[ClosenessLv + 1])
          end
        end
      end
    end
    local ParameLevel = ClosenessLv + 1
    local EffectConf = _G.DataConfigManager:GetPetCloseLevelEffectConf(ParameLevel)
    if EffectConf then
      local LocalizationStr = EffectConf.localization_id
      local Name = PetData.name or ""
      local ShowText = string.format(LuaText[LocalizationStr], Name)
      self.Text:SetText(ShowText)
    end
  end
end

function UMG_RelationTree_IntimacyTips_C:OnCloseClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002014, "UMG_RelationTree_IntimacyTips_C:Disappear")
  self:PlayAnimation(self.Disappear)
end

function UMG_RelationTree_IntimacyTips_C:OnAnimationFinished(anim)
  if anim == self.Disappear then
    _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.CloseRelationTreeIntimacyTipsPanel)
  end
end

function UMG_RelationTree_IntimacyTips_C:OnDeactive()
  self:RemoveButtonListener(self.btnCloseTips, self.OnCloseClick)
end

return UMG_RelationTree_IntimacyTips_C
