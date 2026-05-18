local UMG_MagicTips_C = _G.NRCPanelBase:Extend("UMG_MagicTips_C")

function UMG_MagicTips_C:OnActive(PetTeam)
  local roleMagicGid = PetTeam.role_magic_gid
  local PetGidList = PetTeam.pet_infos
  self:OnAddEventListener()
  local BagItemConf
  if PetTeam.is_mirror then
    if PetTeam.mirror_magic_id and 0 ~= PetTeam.mirror_magic_id then
      BagItemConf = _G.DataConfigManager:GetBagItemConf(PetTeam.mirror_magic_id)
    end
  else
    local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
    if BagItemS and #BagItemS > 0 then
      local BagItemList = {}
      for index, BagItem in pairs(BagItemS) do
        if roleMagicGid == BagItem.gid then
          self.BagItem = BagItem
        end
      end
    end
    if not self.BagItem then
      return
    end
    BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
  end
  if BagItemConf then
    self.SkillIcon:SetPath(BagItemConf.big_icon)
    self.SkillNameTxt:SetText(BagItemConf.name)
    self.NRCTextDes:SetText(BagItemConf.description)
    local Content
    if BagItemConf.initial_use_times >= 99 then
      self.RemainingUses:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      Content = string.format("%d/%d", BagItemConf.initial_use_times, BagItemConf.initial_use_times)
      self.RemainingUses:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.RemainingTsageTimesText:SetText(Content)
    end
    local PlayerMagicConf = _G.DataConfigManager:GetPlayerMagicConf(BagItemConf.player_skill_id)
    if PlayerMagicConf then
      local SkillConf = _G.DataConfigManager:GetSkillConf(PlayerMagicConf.skill_id)
      if SkillConf then
        local PetDataList = {}
        for i, PetTeam_PetInfo in ipairs(PetGidList) do
          local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(PetTeam_PetInfo.pet_gid)
          if PetData then
            for j, Blood in ipairs(SkillConf.target_blood_limit) do
              if PetData.blood_id == Blood or self:DepartmentMatching(PetData, Blood) then
                table.insert(PetDataList, PetData)
                break
              end
            end
          end
        end
        if PetDataList and #PetDataList > 0 then
          self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.Pet:InitGridView(PetDataList)
        else
          self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
end

function UMG_MagicTips_C:DepartmentMatching(PetData, blood_id)
  for i, type in ipairs(PetData.skill_dam_type) do
    local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(blood_id)
    if PetBloodConf and type == PetBloodConf.blood_type then
      return true
    end
  end
  return false
end

function UMG_MagicTips_C:OnDeactive()
end

function UMG_MagicTips_C:OnPcClose()
  self:DoClose()
end

function UMG_MagicTips_C:ClosePanel()
  self:DoClose()
end

function UMG_MagicTips_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_ShutDown, self.ClosePanel)
end

return UMG_MagicTips_C
