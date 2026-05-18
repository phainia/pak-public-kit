local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleRoundSelectMarkerManager = NRCClass()

function BattleRoundSelectMarkerManager:Ctor()
  self._curPet = nil
end

function BattleRoundSelectMarkerManager:ClearSelection()
  local battleManager = _G.BattleManager
  if battleManager then
    local pawnManager = battleManager.battlePawnManager
    if pawnManager then
      local playerPets = pawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
      local enemyPets = pawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY)
      for _, v in pairs(playerPets) do
        v:SetClickable(false)
      end
      for _, v in pairs(enemyPets) do
        v:SetClickable(false)
      end
    end
  end
end

function BattleRoundSelectMarkerManager:SelectTargetTime(skillType)
  if 0 == skillType then
    self:HideAllSelectMarkers()
  end
  if 1 == skillType then
    self:HideAllSelectMarkers()
    self:ShowSelectMarkers(BattleEnum.SelectMarkerType.ENUM_MYSELF)
  end
  if 2 == skillType then
    self:HideAllSelectMarkers()
    self:ShowSelectMarkers(BattleEnum.SelectMarkerType.ENUM_ALLY)
  end
  if 3 == skillType then
    self:HideAllSelectMarkers()
    self:ShowSelectMarkers(BattleEnum.SelectMarkerType.ENUM_OTHER_ALLY)
  end
  if 4 == skillType then
    self:HideAllSelectMarkers()
    self:ShowSelectMarkers(BattleEnum.SelectMarkerType.ENUM_ENEMY)
  end
  if 5 == skillType then
    self:ShowSelectMarkers(BattleEnum.SelectMarkerType.ENUM_ALL)
  end
  if 6 == skillType then
    self:ShowSelectMarkers(BattleEnum.SelectMarkerType.ENUM_ENEMY_SAME_POS)
  end
end

function BattleRoundSelectMarkerManager:SetAllPetsClickable()
  local battleManager = _G.BattleManager
  if battleManager then
    local pawnManager = battleManager.battlePawnManager
    if pawnManager then
      local playerPets = pawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_TEAM)
      local enemyPets = pawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_ENEMY)
      for _, v in pairs(playerPets) do
        v:SetClickable(true)
      end
      for _, v in pairs(enemyPets) do
        v:SetClickable(true)
      end
    end
  end
end

function BattleRoundSelectMarkerManager:ShowSelectMarkers(markerType)
  local playerPets = _G.BattleManager.battlePawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_TEAM, false)
  local enemyPets = _G.BattleManager.battlePawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_ENEMY, false)
  if markerType == BattleEnum.SelectMarkerType.ENUM_MYSELF then
    self._curPet:SetClickable(true)
  elseif markerType == BattleEnum.SelectMarkerType.ENUM_ALLY then
    for _, v in pairs(playerPets) do
      v:SetClickable(true)
    end
  elseif markerType == BattleEnum.SelectMarkerType.ENUM_OTHER_ALLY then
    for _, v in pairs(playerPets) do
      v:SetClickable(true)
    end
    self._curPet:SetClickable(false)
  elseif markerType == BattleEnum.SelectMarkerType.ENUM_ENEMY then
    for _, v in pairs(enemyPets) do
      v:SetClickable(true)
    end
  elseif markerType == BattleEnum.SelectMarkerType.ENUM_ALL then
    for _, v in pairs(enemyPets) do
      v:SetClickable(true)
    end
    for _, v in pairs(playerPets) do
      v:SetClickable(true)
    end
    self._curPet:SetClickable(false)
  elseif markerType == BattleEnum.SelectMarkerType.ENUM_MYSELF_ALLY then
    local myPets = _G.BattleManager.battlePawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_TEAM, true)
    for _, v in pairs(myPets) do
      v:SetClickable(true)
    end
  end
end

function BattleRoundSelectMarkerManager:SetCurrentPet(pet)
  self._curPet = pet
end

function BattleRoundSelectMarkerManager:ClearCurrentPet(pet)
  self._curPet = nil
end

function BattleRoundSelectMarkerManager:HideAllSelectMarkers()
  local battleManager = _G.BattleManager
  if battleManager then
    local pawnManager = battleManager.battlePawnManager
    if pawnManager then
      local playerPets = pawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
      local enemyPets = pawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY)
      for _, v in pairs(playerPets) do
        v:SetClickable(false)
      end
      for _, v in pairs(enemyPets) do
        v:SetClickable(false)
      end
    end
  end
end

function BattleRoundSelectMarkerManager:ShowCatchRate(rate)
  local enemyPets = _G.BattleManager.battlePawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_ENEMY)
  for _, v in ipairs(enemyPets) do
    if v then
      local r = rate[v.card.config.id]
      if r then
        v:ShowCatchRate(r.rate)
      end
    end
  end
end

function BattleRoundSelectMarkerManager:HideCatchRate()
  local enemyPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY)
  for _, v in ipairs(enemyPets) do
    if v then
      v:HideCatchRate()
    end
  end
end

function BattleRoundSelectMarkerManager:ShowTipTime(time, operateType, targetType, params)
  if targetType == BattleEnum.SelectMarkerType.ENUM_ALLY then
    local playerPets = _G.BattleManager.battlePawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_TEAM)
    for _, v in ipairs(playerPets) do
      if v then
        v:ShowTipTime(time, operateType, params)
      end
    end
  elseif targetType == BattleEnum.SelectMarkerType.ENUM_ENEMY then
    local enemyPets = _G.BattleManager.battlePawnManager:GetCanSelectAllPet(BattleEnum.Team.ENUM_ENEMY)
    for _, v in ipairs(enemyPets) do
      if v then
        v:ShowTipTime(time, operateType, params)
      end
    end
  else
    Log.Error("Target type of this tip not supported: %s", tostring(targetType))
  end
end

function BattleRoundSelectMarkerManager:HideTipTime()
  local enemyPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY)
  for _, v in ipairs(enemyPets) do
    if v then
      v:HideTipTime()
    end
  end
  local playerPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  for _, v in ipairs(playerPets) do
    if v then
      v:HideTipTime()
    end
  end
end

function BattleRoundSelectMarkerManager:HideClickTipUI()
  local enemyPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY)
  for _, v in ipairs(enemyPets) do
    if v then
      v:HideClickTipUI()
      v:HideRestraintUI()
    end
  end
  local playerPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  for _, v in ipairs(playerPets) do
    if v then
      v:HideClickTipUI()
      v:HideRestraintUI()
    end
  end
end

return BattleRoundSelectMarkerManager
