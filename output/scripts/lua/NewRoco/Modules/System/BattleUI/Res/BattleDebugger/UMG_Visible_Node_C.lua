local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Visible_Node_C = _G.NRCPanelBase:Extend("UMG_Visible_Node_C")

function UMG_Visible_Node_C:OnActive()
  self:OnAddEventListener()
end

function UMG_Visible_Node_C:OnDeactive()
  self.btn.OnClicked:Remove(self, self.OnClickBtn)
end

function UMG_Visible_Node_C:OnAddEventListener()
  self.btn.OnClicked:Add(self, self.OnClickBtn)
end

function UMG_Visible_Node_C:SetUI(data, totalVis)
  self:OnAddEventListener()
  self.totalVis = totalVis
  self.performNode = data.PerformNode
  self.timeLineData = data
  self.isEnemy = false
  self.rateNumber = 0
  self.tickTime = 0
  self.Contenxt:SetText(self:GetDetailText())
  if self.isEnemy then
    self.MyProgress:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.EnemyProgress:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.MyProgress:SetPercent(UE4.ESlateVisibility.Visible)
    self.EnemyProgress:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self:UpdateUI()
end

function UMG_Visible_Node_C:UpdateUI()
  self.rateNumber = self:GetProcessRate()
  if self.isEnemy then
    if self.EnemyProgress.SetPercent then
      self.EnemyProgress:SetPercent(self.rateNumber)
    end
  elseif self.MyProgress.SetPercent then
    self.MyProgress:SetPercent(self.rateNumber)
  end
end

function UMG_Visible_Node_C:GetProcessRate(node)
  local rate = 0
  node = node or self.performNode
  if node:IsPerformed() then
    rate = 1
  elseif node:IsTriggerNode() then
    if node:IsPerforming() then
      rate = 0.2
    else
      if node.LastCast then
        rate = node.LastCast / 15
      end
      rate = 0
    end
  elseif node:IsPerforming() then
    rate = 1
  else
    rate = 0
  end
  if node:IsGroupHead() then
    local childs = {}
    local gId = node:GetGroupID()
    local groups = node:GetGroupNodes()
    if groups then
      for i = 1, 18 do
        for _, v in ipairs(groups) do
          if v:GetCastMoment() == i and v ~= node then
            table.insert(childs, v)
          end
        end
        local totalVisCurrentGroupList = self.totalVis:GetCurrentGroupList()
        for j = gId + 1, #totalVisCurrentGroupList do
          local head = totalVisCurrentGroupList[j].GroupNodes[1]
          if head:GetCastMoment() == i and head:GetGroupRef() == gId then
            table.insert(childs, head)
          end
        end
      end
      for i = 1, #childs do
        rate = rate + self:GetProcessRate(childs[i])
      end
      return rate / (#childs + 1)
    else
      return 1
    end
  else
    return rate
  end
end

function UMG_Visible_Node_C:OnTick(deltaTime)
  if self.rateNumber < 1 then
    self.tickTime = self.tickTime + deltaTime
    if self.tickTime > 0.5 then
      self.tickTime = 0
      self:UpdateUI()
      self.Contenxt:SetText(self:GetDetailText())
    end
  end
end

function UMG_Visible_Node_C:OnClickBtn()
  self.totalVis:ShowDetailInfo(self.performNode, self.Contenxt:GetText())
end

function UMG_Visible_Node_C:GetDetailText()
  local data = self.performNode:GetPerformData()
  local detail = ""
  if self.performNode:IsPerforming() then
    detail = detail .. "I:"
  end
  if self.performNode:IsPerformed() then
    detail = detail .. "D:"
  end
  if not self.performNode:IsPerforming() and not self.performNode:IsPerformed() then
    detail = detail .. "N:"
  end
  detail = detail .. self.performNode:GetClusterID() .. ","
  detail = detail .. self.performNode:GetGroupID() .. ","
  detail = detail .. self.performNode:GetNodeIdx()
  if self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_SKILL_CAST or self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_COMBO_SKILL then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.caster_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.caster_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    local skill = _G.SkillUtils.GetSkillConf(data.skill_id)
    if skill then
      detail = detail .. " \228\189\191\231\148\168\230\138\128\232\131\189 " .. (skill.name or tostring(data.skill_id)) .. "(" .. data.skill_id .. ")"
    end
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_BUFF_CHANGE then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.caster_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.caster_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    local buff = _G.DataConfigManager:GetBuffConf(data.buff_id)
    if buff then
      detail = detail .. " \231\154\132 " .. (buff.name or tostring(data.buff_id))
    end
    if data.type == ProtoEnum.BuffChangeType.BCT_REMOVE then
      detail = detail .. "\232\162\171\231\167\187\233\153\164"
    elseif data.type == ProtoEnum.BuffChangeType.BCT_ADD then
      detail = detail .. "\230\150\176\229\162\158"
    elseif data.type == ProtoEnum.BuffChangeType.BCT_CHANGE then
      detail = detail .. "\229\177\130\230\149\176\230\148\185\229\143\152"
    end
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_BUFF_TRIGGER then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.caster_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.caster_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    local buff = _G.DataConfigManager:GetBuffConf(data.buff_id)
    if buff then
      detail = detail .. " \232\167\166\229\143\145BUFF " .. (buff.name or tostring(data.buff_id)) .. "(" .. data.buff_id .. ")"
    end
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_DAMAGE then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.target_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.target_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    detail = detail .. " \229\143\151\229\136\176\230\148\187\229\135\187"
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_HEAL then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.target_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.target_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    detail = detail .. "\232\162\171\230\178\187\231\150\151"
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_ENERGY then
    data = self.performNode.performInfo.sync_data
    if data.pet_sync_info and data.pet_sync_info[1] then
      local petid = data.pet_sync_info[1].pet_id
      local battlePet = _G.BattleManager.battlePawnManager:GetPetByGuid(petid)
      if battlePet then
        local team = battlePet.teamEnm
        if team == BattleEnum.Team.ENUM_TEAM then
          if battlePet.team == _G.BattleManager.battlePawnManager.playerTeam then
            detail = detail .. "\230\136\145\230\150\185"
          else
            detail = detail .. "\233\152\159\229\143\139"
          end
        else
          self.isEnemy = true
          detail = detail .. "\230\149\140\230\150\185"
        end
        detail = detail .. " \232\131\189\233\135\143\229\143\145\231\148\159\229\143\152\229\140\150 " .. tostring(data.pet_sync_info[1].energy_change)
      end
    else
      detail = detail .. " \232\131\189\233\135\143\229\143\145\231\148\159\229\143\152\229\140\150 (pet_sync_info \231\188\186\229\176\145\230\149\176\230\141\174)"
    end
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_DEATH then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.target_id)
    if pet then
      if pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
        if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
          detail = detail .. "\230\136\145\230\150\185"
        else
          detail = detail .. "\233\152\159\229\143\139"
        end
      else
        self.isEnemy = true
        detail = detail .. "\230\149\140\230\150\185"
      end
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.target_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    detail = detail .. " \230\173\187\228\186\161"
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_EFFECT_TRIGGER then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.caster_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.caster_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    local effect = _G.DataConfigManager:GetEffectConf(data.effect_id)
    if effect then
      detail = detail .. " \232\167\166\229\143\145\228\186\134effect " .. (effect.editor_name or tostring(data.effect_id))
    end
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_SP_ENERGY_CHANGE then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.caster_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    detail = detail .. "\229\138\191\232\131\189\230\148\185\229\143\152"
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_SP_ENERGY_TRIGGER then
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(data.caster_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    detail = detail .. "\232\167\166\229\143\145\228\186\134\229\138\191\232\131\189"
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_CHANGE_MODEL then
    local changeModel = data
    local pet = _G.BattleManager.battlePawnManager:GetPetByGuid(changeModel.pet_id)
    if pet and pet.teamEnm == BattleEnum.Team.ENUM_TEAM then
      if pet.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(changeModel.pet_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    detail = detail .. "\233\128\154\232\191\135\229\143\152\232\186\171\230\136\144\228\184\186"
    local changePetId = changeModel.pet_info.battle_common_pet_info.base_conf_id
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(changePetId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
  elseif self.performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_CHANGE_PET then
    local player = _G.BattleManager.battlePawnManager:GetPlayerByGuid(data.player_id)
    local team = player.teamEnm
    if team == BattleEnum.Team.ENUM_TEAM then
      if player.team == _G.BattleManager.battlePawnManager.playerTeam then
        detail = detail .. "\230\136\145\230\150\185"
      else
        detail = detail .. "\233\152\159\229\143\139"
      end
    else
      self.isEnemy = true
      detail = detail .. "\230\149\140\230\150\185"
    end
    local petId = _G.BattleManager.battleRuntimeData:GetPetConfIDByGuid(data.rest_pet_id)
    if petId then
      local petInfo = _G.DataConfigManager:GetPetbaseConf(petId)
      if petInfo then
        detail = detail .. petInfo.name
      end
    end
    local newpet = player.deck:GetCardByGuid(data.battle_pet_id)
    if newpet then
      detail = detail .. " \230\155\191\230\141\162\228\184\186 " .. (newpet.config.name or newpet.config.id)
    end
  else
    detail = self.performNode.performTypeToWord[self.performNode:GetPerformType()]
  end
  return detail
end

return UMG_Visible_Node_C
