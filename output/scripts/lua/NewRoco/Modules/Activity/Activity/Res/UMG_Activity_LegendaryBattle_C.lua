local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_LegendaryBattle_C = Base:Extend("UMG_Activity_LegendaryBattle_C")

function UMG_Activity_LegendaryBattle_C:OnConstruct()
  Base.OnConstruct(self)
  self:OnAddEventListener()
  self.cluePath = nil
  self:SetRedPoints()
  self:RefreshView()
  self.UndoneBtn:SetBtnText(_G.DataConfigManager:GetLocalizationConf("LegendaryPet_Survey_Tips").msg)
  self.UndoneBtn:SetShowLockIcon(false)
  self.UndoneBtn.btnLevelUp:SetIsEnabled(false)
end

function UMG_Activity_LegendaryBattle_C:OnActive()
end

function UMG_Activity_LegendaryBattle_C:OnDeactive()
end

function UMG_Activity_LegendaryBattle_C:OnEnable()
  self:PlayAnimation(self.In)
  self:RefreshView()
end

function UMG_Activity_LegendaryBattle_C:OnDestruct()
  self:OnRemoveEventListener()
  self.cluePath = nil
end

function UMG_Activity_LegendaryBattle_C:OnAddEventListener()
  self:AddButtonListener(self.HOMEBtn, self.OnMapBtnClicked)
  self:AddButtonListener(self.Btn_Inhabit, self.OnHabitBtnClicked)
  self.Btn_Inhabit.OnClicked:Add(self, self.OnHabitBtnClicked)
  self.Btn_Inhabit.OnPressed:Add(self, self.OnHabitBtnPressed)
  self:AddButtonListener(self.ExamineBtn, self.OpenPetPanel)
  self:AddButtonListener(self.RewardBtn.btnLevelUp, self.OnRewardBtnClicked)
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.OnTraceBtnClicked)
  self:AddButtonListener(self.ExamineBtn_1, self.OnShopBtnClick)
  self:RegisterEvent(self, ActivityModuleEvent.LBActivityTaskStateChange, self.OnLBActivityTaskStateChange)
end

function UMG_Activity_LegendaryBattle_C:OnRemoveEventListener()
  self.Btn_Inhabit.OnClicked:Remove(self, self.OnHabitBtnClicked)
  self.Btn_Inhabit.OnPressed:Remove(self, self.OnHabitBtnPressed)
  self:UnRegisterEvent(self, ActivityModuleEvent.LBActivityTaskStateChange, self.OnLBActivityTaskStateChange)
end

function UMG_Activity_LegendaryBattle_C:SetRedPoints()
  self.RewardBtn.RedDot:SetupKey(224, self.activityInst:GetTaskId())
  self.TraceBtn.RedDot:SetupKey(225, self.activityInst:GetTaskId())
  self.RedDot:SetupKey(223, self.activityInst:GetTaskId())
end

function UMG_Activity_LegendaryBattle_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_LegendaryBattle_C:RefreshView()
  local taskList = {}
  table.insert(taskList, self.activityInst:GetTaskId())
  self.activityInst:OnZoneTaskQueryReq(taskList)
  self.Text_Title:SetText(self.activityInst:GetActivityUniqueName())
  self.Text_Describe:SetText(self.activityInst:GetActivityUniqueDesc())
  self.Text_hint:SetText(self.activityInst:GetActivityBanText())
  local curWorldLv = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if curWorldLv < self.activityInst:GetWorldLevelRequired() then
    self.UnlockSwitcher:SetActiveWidgetIndex(0)
    self.NotUnlocked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UnlockSwitcher:SetActiveWidgetIndex(1)
    self.NotUnlocked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local petBaseConf = DataConfigManager:GetPetbaseConf(self.activityInst:GetBossPetBaseId())
  local attrDatas = {}
  for i = 1, #petBaseConf.unit_type do
    local petType = petBaseConf.unit_type[i]
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
    table.insert(attrDatas, {
      Name = typeDic.short_name,
      Path = typeDic.type_icon
    })
  end
  self.Attr:InitGridView(attrDatas)
  self.TextName:SetText(petBaseConf.name)
  self:UpdateTime()
  local bgPath, topPath, cluePath = self:GetPicResByPetBaseId(self.activityInst:GetBossPetBaseId())
  self.MythicalCreatures:SetPath(topPath)
  self.MythicalCreaturesBG:SetPath(bgPath)
  self.cluePath = cluePath
  self:ShowRewards(false)
  self:UpdateCoin()
end

function UMG_Activity_LegendaryBattle_C:UpdateCoin()
  local costItemId = _G.DataConfigManager:GetLegendaryGlobalConfig("beast_challenge_ticket_id").num
  local starNum = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItemId)
  if nil == starNum then
    starNum = 0
  else
    starNum = starNum.num
  end
  self.MoneyBtn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_LegendaryBattle_C:GetPicResByPetBaseId(petBaseId)
  local filePath = string.format("%s%d%s", "/Game/NewRoco/Modules/System/Activity/Raw/LegendaryBattle/", petBaseId, "/")
  local bgPath = string.format("%s%s", filePath, "img_beijing.img_beijing")
  local topPath = string.format("%s%s", filePath, "img_jingling.img_jingling")
  local findPath = string.format("%s%s", filePath, "img_xiansuo.img_xiansuo")
  return bgPath, topPath, findPath
end

function UMG_Activity_LegendaryBattle_C:UpdateTime()
  local startStamp, endStamp = self.activityInst:GetStartAndEndTimeStamp()
  local leftTimeStamp = endStamp - ActivityUtils.GetSvrTimestamp()
  local text = ActivityUtils.GetTimeFormatStr(leftTimeStamp)
  self.Text_TimeRemaining:SetText(text)
  self.CanvasPanel_356:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_LegendaryBattle_C:ShowRewards(bShow)
  if bShow then
    self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_LegendaryBattle_C:UpdateIcon(bGetReward)
  local reward = self.activityInst:GetActivityTaskRewards()
  local rewardsTable = {}
  for k, v in ipairs(reward) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.Type
    rewards.itemId = v.Id
    rewards.itemNum = v.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    rewards.bShowGetTag = bGetReward
    table.insert(rewardsTable, rewards)
  end
  self.AwardList:InitList(rewardsTable)
  ActivityUtils.AdjustCtrlSize(self.BG, {
    175,
    326,
    477,
    627,
    702
  }, #rewardsTable)
end

function UMG_Activity_LegendaryBattle_C:OnMapBtnClicked()
end

function UMG_Activity_LegendaryBattle_C:OnHabitBtnPressed()
  self:PlayAnimation(self.Btn_press)
end

function UMG_Activity_LegendaryBattle_C:OnHabitBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008019, "UMG_Activity_LegendaryBattle_C:OnHabitBtnClicked")
  self:PlayAnimation(self.Btn_up)
  self.module:OpenPhotographPanel(self.cluePath)
  self.RedDot:EraseRedPoint()
end

function UMG_Activity_LegendaryBattle_C:OpenPetPanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_LegendaryBattle_C:OpenPetPanel")
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, self.activityInst:GetBossPetBaseId(), true)
end

function UMG_Activity_LegendaryBattle_C:OnRewardBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40007008, "UMG_Activity_LegendaryBattle_C:OnRewardBtnClicked")
  local taskList = {}
  table.insert(taskList, self.activityInst:GetTaskId())
  self.activityInst:OnZoneTaskRewardReq(taskList)
end

function UMG_Activity_LegendaryBattle_C:OnTraceBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008018, "UMG_Activity_LegendaryBattle_C:OnTraceBtnClicked")
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OpenWorldMap, {
    centerNPCRefreshId = self.activityInst:GetRefreshId()
  })
end

function UMG_Activity_LegendaryBattle_C:OnShopBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_LegendaryBattle_C:OnShopBtnClick")
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OpenMainPanel, 2, 20017)
end

function UMG_Activity_LegendaryBattle_C:OnLBActivityTaskStateChange(taskState)
  local bUnlock = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel() >= self.activityInst:GetWorldLevelRequired()
  self:ShowRewards(bUnlock)
  if taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_INIT then
    self:UpdateIcon(false)
    self.Switcher_Btn:SetActiveWidgetIndex(0)
  elseif taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
    self:UpdateIcon(false)
    self.Switcher_Btn:SetActiveWidgetIndex(0)
  elseif taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self:UpdateIcon(false)
    self.Switcher_Btn:SetActiveWidgetIndex(1)
    self.NRCText1:SetText(LuaText.legendary_battle_text_8)
  elseif taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self:UpdateIcon(true)
    self.Switcher_Btn:SetActiveWidgetIndex(2)
    self.NRCText1:SetText(LuaText.legendary_battle_text_8)
  else
    self:UpdateIcon(false)
    self.Switcher_Btn:SetActiveWidgetIndex(0)
  end
end

return UMG_Activity_LegendaryBattle_C
