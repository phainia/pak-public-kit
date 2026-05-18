local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TerritoryTrial_EnemyInformationItem_C = Base:Extend("UMG_TerritoryTrial_EnemyInformationItem_C")

function UMG_TerritoryTrial_EnemyInformationItem_C:OnConstruct()
  if self.Magic_HiddenHybrid_Item then
    local Magic_HiddenHybrid_ItemVisibility = UE.ESlateVisibility.Collapsed
    self.Magic_HiddenHybrid_Item:SetVisibility(Magic_HiddenHybrid_ItemVisibility)
  end
  self.props = {}
  self.state = {}
  local initState = {}
  initState.isDetailOpen = false
  initState.isDetailButtonShow = true
  initState.highLightHeadIcon = false
  self:OnAddEventListener()
  self:SetState(initState)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnItemUpdate(_data, datalist, index)
  self:SetProps(_data)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnItemSelected(_bSelected)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnDeactive()
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnAddEventListener()
  self.Combination.btnLevelUp.OnPressed:Add(self, self.OnCombinationButtonPress)
  self.Combination.btnLevelUp.OnReleased:Add(self, self.OnCombinationButtonRelease)
  self.Button.OnClicked:Add(self, self.OnCombinationButtonPress)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnRemoveEventListener()
  self.Combination.btnLevelUp.OnPressed:Remove(self, self.OnCombinationButtonPress)
  self.Combination.btnLevelUp.OnReleased:Remove(self, self.OnCombinationButtonRelease)
  self.Button.OnClicked:Remove(self, self.OnCombinationButtonPress)
end

function UMG_TerritoryTrial_EnemyInformationItem_C.DeriveStateFromProps(prevState, nextProps)
  local isInBattle = nextProps and nextProps.isInBattle
  local isDefeat = nextProps and nextProps.isDefeated
  local guardEntries = nextProps and nextProps.guardEntries or {}
  local nextState = {}
  table.copy(prevState, nextState)
  if isInBattle then
    nextState.isDetailOpen = true
    nextState.highLightHeadIcon = true
  else
    nextState.isDetailOpen = false
    nextState.highLightHeadIcon = false
  end
  if isDefeat then
    nextState.isDetailButtonShow = false
  end
  if 0 == #guardEntries then
    nextState.isDetailOpen = false
    nextState.isDetailButtonShow = false
  end
  return nextState
end

function UMG_TerritoryTrial_EnemyInformationItem_C:RenderWidget(prevProps, nextProps, prevState, nextState)
  local prevPetGid = prevState and prevState.petGid
  local nextPetGid = nextProps and nextProps.petGid
  local prevName = prevProps and prevProps.name
  local nextName = nextProps and nextProps.name
  local prevIconPath = prevProps and prevProps.iconPath
  local nextIconPath = nextProps and nextProps.iconPath
  local prevGuardEntries = prevProps and prevProps.guardEntries
  local nextGuardEntries = nextProps and nextProps.guardEntries
  if prevName ~= nextName then
    self.Title:SetText(nextName)
  end
  if prevIconPath ~= nextIconPath then
    self.HeadPortrait:SetPath(nextIconPath)
  end
  local prevDetailOpen = prevState and prevState.isDetailOpen
  local nextDetailOpen = nextState and nextState.isDetailOpen
  if prevDetailOpen ~= nextDetailOpen then
    if nextDetailOpen then
      self.EntryDetail:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.BossMarkSwitcher:SetActiveWidgetIndex(1)
      self.Combination:SetRenderTransformAngle(0)
    else
      self.EntryDetail:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.BossMarkSwitcher:SetActiveWidgetIndex(0)
      self.Combination:SetRenderTransformAngle(180)
    end
  end
  local prevIsDetailButtonShow = prevState and prevState.isDetailButtonShow
  local nextIsDetailButtonShow = nextState and nextState.isDetailButtonShow
  if prevIsDetailButtonShow ~= nextIsDetailButtonShow then
    if nextIsDetailButtonShow then
      self.Combination:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Combination:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  local prevIsDefeated = prevProps and prevProps.isDefeated
  local nextIsDefeated = nextProps and nextProps.isDefeated
  local intensity = 0.0
  if prevIsDefeated ~= nextIsDefeated then
    if nextIsDefeated then
      self.Defeated:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.BattleInformation:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.Defeated:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.BattleInformation:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  local prevHighLightHeadIcon = prevState and prevState.highLightHeadIcon
  local nextHighLightHeadIcon = nextState and nextState.highLightHeadIcon
  if nextHighLightHeadIcon then
    intensity = 0.0
  else
    intensity = 1.0
  end
  local headPortraitMaterial = self.HeadPortrait:GetDynamicMaterial()
  if UE.UObject.IsValid(headPortraitMaterial) then
    headPortraitMaterial:SetScalarParameterValue("Intensity", intensity)
  end
  local prevIsBoss = prevProps and prevProps.isBoss
  local nextIsBoss = nextProps and nextProps.isBoss
  if prevIsBoss ~= nextIsBoss then
    if nextIsBoss then
      self.BossMarkSwitcher:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.BossMark:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.BossMarkSwitcher:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.BossMark:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  local prevIsInBattle = prevProps and prevProps.isInBattle
  local nextIsInBattle = nextProps and nextProps.isInBattle
  if prevIsInBattle ~= nextIsInBattle then
    local inBattleText = ""
    if nextIsInBattle then
      local tips4Conf = _G.DataConfigManager:GetLocalizationConf("territory_trial_battle_tips4")
      local tips4 = tips4Conf and tips4Conf.msg or ""
      inBattleText = tips4
      self.BgSwitcher:SetActiveWidgetIndex(0)
    else
      self.BgSwitcher:SetActiveWidgetIndex(1)
      local tips5Conf = _G.DataConfigManager:GetLocalizationConf("territory_trial_battle_tips5")
      local tips5 = tips5Conf and tips5Conf.msg or ""
      inBattleText = tips5
    end
    self.NRCText_56:SetText(inBattleText)
  end
  if prevGuardEntries ~= nextGuardEntries then
    nextGuardEntries = nextGuardEntries or {}
    local propsList = {}
    for i, entry in ipairs(nextGuardEntries) do
      local skillId = entry
      local skillConf = _G.SkillUtils.GetSkillConf(skillId, true)
      local skillName = skillConf and skillConf.name
      local skillDesc = skillConf and skillConf.desc
      local props = {}
      props.label = skillName
      props.content = skillDesc
      table.insert(propsList, props)
    end
    self.TextGridView:InitGridView(propsList)
    self.TextGridView:SetItemCount(#propsList)
  end
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnCombinationButtonPress()
  local prevState, nextState = self:GetPrevAndNextState()
  nextState.isDetailOpen = not nextState.isDetailOpen
  self:SetState(nextState)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:OnCombinationButtonRelease()
end

function UMG_TerritoryTrial_EnemyInformationItem_C:SetProps(nextProps)
  local prevProps = self.props
  self.props = nextProps
  local prevState = self.state
  local nextState = self.DeriveStateFromProps(prevState, nextProps)
  self.state = nextState
  self:RenderWidget(prevProps, nextProps, prevState, nextState)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:SetState(nextState)
  local prevState = self.state
  self.state = nextState
  self:RenderWidget(self.props, self.props, prevState, nextState)
end

function UMG_TerritoryTrial_EnemyInformationItem_C:GetPrevAndNextState()
  local prevState = self.state
  local nextState = {}
  table.copy(prevState, nextState)
  return prevState, nextState
end

return UMG_TerritoryTrial_EnemyInformationItem_C
