local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local SkillUtils = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.SkillUtils")
local UMG_Battle_Skillpick_List_C = _G.NRCPanelBase:Extend("UMG_Battle_Skillpick_List_C")

function UMG_Battle_Skillpick_List_C:OnConstruct()
  self:SetChildViews(self.UMGBattleSkillpickItem1, self.UMGBattleSkillpickItem2, self.UMGBattleSkillpickItem3, self.UMGBattleSkillpickItem4, self.UMGBattleSkillpickItem5)
  self.CurSkillInfo = nil
  self.SkillPanelList = {
    self.UMGBattleSkillpickItem1,
    self.UMGBattleSkillpickItem2,
    self.UMGBattleSkillpickItem3,
    self.UMGBattleSkillpickItem4,
    self.UMGBattleSkillpickItem5
  }
  self:UpdateSkillCount()
  self:OnAddEventListener()
  self:PlayOpen()
  if self:IsPCMode() then
    self.BtnSwitchover:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Battle_Skillpick_List_C:PlayLoop()
  if #self.SkillList > 0 then
    self.SkillList[#self.SkillList]:HideLine(true)
  end
end

function UMG_Battle_Skillpick_List_C:PlayLineR()
  self:PlayAnimation(self.LineR_in)
end

function UMG_Battle_Skillpick_List_C:OnDestruct()
  self:OnRemoveEventListener()
  self:UnBindInputAction()
end

function UMG_Battle_Skillpick_List_C:OnActive()
  if self:IsPCMode() then
    self.HorizontalBox_79:SetRenderScale(UE4.FVector2D(0.88, 0.88))
  end
  for i, skill in ipairs(self.SkillList) do
    if 1 == i then
      skill:PlayLoop(false)
    end
    skill:SetParent(self, i)
  end
  self:InitializedSkillList()
  self:PCKeySetting()
end

function UMG_Battle_Skillpick_List_C:BindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_Battle")
  if mappingContext then
    mappingContext:BindAction("IA_BattleClearSkillData", self, "ClearAllSkillData", UE.ETriggerEvent.Triggered)
  end
end

function UMG_Battle_Skillpick_List_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_Battle")
  if mappingContext then
    mappingContext:UnBindAction("IA_BattleClearSkillData", self, "ClearAllSkillData", UE.ETriggerEvent.Triggered)
  end
end

function UMG_Battle_Skillpick_List_C:ClearAllSkillData()
  if BattleUtils.IsWatchingBattle() then
    return
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.Clear_SkillList)
end

function UMG_Battle_Skillpick_List_C:InitializedSkillList()
  local battlePawnManager = BattleManager.battlePawnManager
  local player = battlePawnManager and battlePawnManager.TeamatePlayer
  local skillList = player and player:GetSkillList() or {}
  self:SetPanelInfo(skillList)
end

function UMG_Battle_Skillpick_List_C:OnDeactive()
end

function UMG_Battle_Skillpick_List_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_Battle_Skillpick_List_C:PlayOpen()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.open)
end

function UMG_Battle_Skillpick_List_C:OnEnable()
  self:StopAllAnimations()
  self:PlayOpen()
  self:BindInputAction()
end

function UMG_Battle_Skillpick_List_C:OnDisable()
  self:PlayAnimation(self.close)
  self:UnBindInputAction()
end

function UMG_Battle_Skillpick_List_C:OnAddEventListener()
  self:AddButtonListener(self.BtnSwitchover, self.ClearAllSkillData)
  _G.BattleEventCenter:Bind(self, BattleEvent.Skill_Preload, BattleEvent.UI_HIDE, BattleEvent.ROUND_START, BattleEvent.CHANGE_OPERATE_TYPE, BattleEvent.Clear_SkillList, BattleEvent.SkillListChangeUpdate)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_Skillpick_List_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_Battle_Skillpick_List_C:OnRemoveEventListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_Skillpick_List_C:PCKeySetting()
  if SystemSettingModuleCmd then
    self.PCKey:SetKeyVisibility(true)
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleClearSkillData")
    if "" ~= image then
      self.PCKey:SetImageMode(image)
    else
      self.PCKey:SetText(text)
    end
  end
end

function UMG_Battle_Skillpick_List_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.Skill_Preload then
    self:SetPanelInfo(...)
    return true
  elseif eventName == BattleEvent.UI_HIDE then
    self:ClearAllSkill()
    return true
  elseif eventName == BattleEvent.ROUND_START then
    self:UpdateSkillCount()
    return true
  elseif eventName == BattleEvent.CHANGE_OPERATE_TYPE then
  elseif eventName == BattleEvent.Clear_SkillList then
    self:ClearAllSkill(...)
    return true
  elseif eventName == BattleEvent.SkillListChangeUpdate then
    self:SkillListChangeUpdate(...)
    return true
  end
end

function UMG_Battle_Skillpick_List_C:UpdateSkillCount()
  local MaxNum = #self.SkillPanelList
  local SkillNum = BattleUtils.GetWorldLeaderRewardCount()
  self.SkillList = {}
  if SkillNum then
    for i = 1, MaxNum do
      if i <= SkillNum and SkillNum > 1 then
        self.SkillPanelList[i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        table.insert(self.SkillList, self.SkillPanelList[i])
      else
        self.SkillPanelList[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_Battle_Skillpick_List_C:RoundStart()
  local operationPets = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM, true)
  local energy = 0
  local Index
  for i, skill in ipairs(self.SkillList) do
    if skill.data then
      local SkillConf = SkillUtils.GetSkillConf(skill.data.cast_skill.skill_id)
      energy = energy + SkillConf.energy_cost[1]
      if energy > operationPets[1].card.petBaseConf.max_energy then
        skill:SetData(nil)
        _G.BattleEventCenter:Dispatch(BattleEvent.Clear_SkillList, i)
      else
        Index = i
      end
    end
  end
  if Index and Index + 1 <= #self.SkillList then
    self.SkillList[Index + 1]:SetData(nil, true)
  end
end

function UMG_Battle_Skillpick_List_C:SkillListChangeUpdate(_SkillList)
  self:SetPanelInfo(_SkillList)
end

function UMG_Battle_Skillpick_List_C:SetPanelInfo(_SkillList)
  local Index = 0
  for i, skill in ipairs(self.SkillList) do
    if _SkillList[i] then
      Index = i
    end
  end
  for i, skill in ipairs(self.SkillList) do
    if _SkillList[i] then
      if not skill.data or _SkillList[i].cast_skill.skill_id ~= skill.data.cast_skill.skill_id then
        self.SkillList[i]:SetData(_SkillList[i], i == Index + 1)
      end
    elseif not _SkillList[i] then
      self.SkillList[i]:SetData(nil, i == Index + 1)
    end
  end
  if Index and Index + 1 <= #self.SkillList then
    self.SkillList[Index + 1]:SetData(nil, true)
  end
end

function UMG_Battle_Skillpick_List_C:ClearAllSkill(Index)
  if Index then
    return
  end
  for i, skill in ipairs(self.SkillList) do
    skill:SetData(nil, 1 == i)
  end
  _G.NRCAudioManager:PlaySound2DAuto(1220002009, "UMG_Battle_Skillpick_List_C:ClearAllSkill")
end

function UMG_Battle_Skillpick_List_C:OnAnimationFinished(Anim)
  if Anim == self.close then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Battle_Skillpick_List_C
