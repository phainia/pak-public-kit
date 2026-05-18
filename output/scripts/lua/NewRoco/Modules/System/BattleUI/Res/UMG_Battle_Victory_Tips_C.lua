local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Battle_Victory_Tips_C = _G.NRCPanelBase:Extend("UMG_Battle_Victory_Tips_C")

function UMG_Battle_Victory_Tips_C:OnActive()
end

function UMG_Battle_Victory_Tips_C:OnDeactive()
end

function UMG_Battle_Victory_Tips_C:OnAddEventListener()
end

function UMG_Battle_Victory_Tips_C:GetPetBase(configId)
  local isMonster = BattleUtils:IsMonster(configId)
  if isMonster then
    local monster = _G.DataConfigManager:GetMonsterConf(configId)
    monster = monster or _G.DataConfigManager:GetPetConf(configId)
    return _G.DataConfigManager:GetPetbaseConf(monster.base_id)
  else
    local pet = _G.DataConfigManager:GetPetConf(configId)
    pet = pet or _G.DataConfigManager:GetMonsterConf(configId)
    return _G.DataConfigManager:GetPetbaseConf(pet.base_id)
  end
end

function UMG_Battle_Victory_Tips_C:Show(data, index, petInfos)
  if not data.attack_pet_id then
    return
  end
  self.BadgeList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if data.is_defend_runaway then
    self.Switch:SetActiveWidgetIndex(1)
    self.Pet_Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Left_Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BackgroundImage_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local player = BattleManager.battlePawnManager:GetPlayerEnemyTeam()
    if player then
      self.Pet_Name:SetText(player.roleInfo.base.name)
      local modelId = BattleUtils.GetPlayerModelId(player.roleInfo)
      if modelId == BattleConst.Human_Female then
        self.Left_Pet:SetPath(string.format("%s%s.%s'", _G.UIIconPath.HeadIconPath, "img_nv", "img_nv"))
      elseif modelId == BattleConst.Human_Male then
        self.Left_Pet:SetPath(string.format("%s%s.%s'", _G.UIIconPath.HeadIconPath, "img_nan", "img_nan"))
      else
        local modelConfig = _G.DataConfigManager:GetModelConf(modelId)
        if not modelConfig or not modelConfig.icon then
          self.Left_Pet:SetPath(string.format("%s%s.%s'", _G.UIIconPath.HeadIconPath, "img_nan", "img_nan"))
        else
          self.Left_Pet:SetPath(NRCUtils:FormatConfIconPath(modelConfig.icon, _G.UIIconPath.HeadIconPath))
        end
      end
    end
  else
    self.Switch:SetActiveWidgetIndex(0)
    self.Left_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HeadIcon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BackgroundImage_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local attackCard = self:GetPetInfoById(data.attack_pet_id, petInfos)
    local defendCard = self:GetPetInfoById(data.defend_pet_id, petInfos)
    if attackCard then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(attackCard.petbase_id)
      if petBaseConf then
        self.Pet_Name:SetText(petBaseConf.name)
      end
      self.Pet_Name:SetVisibility(petBaseConf and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
      self.HeadIcon:SetIconPathAndMaterial(attackCard.petbase_id, attackCard.mutation_type, attackCard.glass_info)
      local hasMedal = data.needShowMedal and attackCard.medal_cond_complete and #attackCard.medal_cond_complete > 0
      if hasMedal then
        self:DelaySeconds(0.5 + 0.1 * index, self.ShowMedal, self, attackCard.medal_cond_complete)
      end
    end
    if defendCard then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(defendCard.petbase_id)
      if petBaseConf then
        self.Pet_Name_1:SetText(petBaseConf.name)
      end
      self.Pet_Name_1:SetVisibility(petBaseConf and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
      self.HeadIcon_1:SetIconPathAndMaterial(defendCard.petbase_id, defendCard.mutation_type, defendCard.glass_info)
    end
    local canShow = defendCard
    self.Switch:SetVisibility(canShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_1:SetVisibility(canShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.BackgroundImage_1:SetVisibility(canShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.Pet_Name_1:SetVisibility(canShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.NRCImage_45:SetVisibility(canShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.GoldNumber:SetVisibility(canShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  self.GoldCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCImage_45:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.GoldNumber:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if data.score and data.score > 0 then
    BattleUtils.SetPvpScoreIcon(self.NRCImage_45)
    self.GoldNumber:SetText("x" .. tostring(data.score))
    self:DelaySeconds(0.7 + 0.05 * (index - 1), self.ShowGold, self)
  end
  self:PlayAnimation(self.open)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1199, "UMG_Battle_Victory_Tips_C:show pvp record")
end

function UMG_Battle_Victory_Tips_C:GetPetInfoById(id, infos)
  if not infos then
    return nil
  end
  for _, v in ipairs(infos) do
    if v.pet_id == id then
      return v
    end
  end
end

function UMG_Battle_Victory_Tips_C:ShowGold()
  self.NRCImage_45:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.GoldNumber:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.GoldCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Gold)
end

function UMG_Battle_Victory_Tips_C:ShowMedal(medalList)
  self.BadgeList:InitGridView(medalList)
  self.BadgeList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

return UMG_Battle_Victory_Tips_C
