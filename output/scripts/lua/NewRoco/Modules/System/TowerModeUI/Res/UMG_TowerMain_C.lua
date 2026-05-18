local TowerModeEvent = reload("NewRoco.Modules.Core.TowerMode.TowerModeEvent")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UMG_TowerMain_C = _G.NRCPanelBase:Extend("UMG_TowerMain_C")

function UMG_TowerMain_C:OnConstruct()
  self.LevelReqReached = false
  self.firstIndex = 0
  self.RewardItems = nil
  self.Panel = nil
end

function UMG_TowerMain_C:OnDestruct()
end

function UMG_TowerMain_C:OnActive()
  self:PlayAnimation(self.open, 0.0, 1)
  self.Clicked = false
  self.IsClose = false
  self.data = self.module:GetData("TowerModeData")
  self.Title:SetText(self.data.StageConfigure.name)
  local playerdt = DataModelMgr.PlayerDataModel
  local timeCur = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime) / 3600
  if timeCur >= self.data.StageConfigure.battle_time[1] and timeCur <= self.data.StageConfigure.battle_time[2] then
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self:SetLevelList()
  local level = 0
  local numPets = 0
  local recText = LuaText.umg_towermain_1 .. tostring(self.data.StageConfigure.Recommend_lv)
  local pets = playerdt:GetPetData()
  for _, pet in ipairs(pets) do
    level = level + pet.level
    numPets = numPets + 1
  end
  local levelavg = level / numPets
  if levelavg < self.data.StageConfigure.Recommend_lv - self.data.StageConfigure.Lv_count then
    self.LevRec:SetText(recText .. LuaText.umg_towermain_2)
    self.LevRec2:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelReqReached = false
  else
    self.LevRec2:SetText(recText)
    self.LevRec:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelReqReached = true
  end
  self:OnAddEventListener()
end

function UMG_TowerMain_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.FightBtn.btnLevelUp, self.OnFightBtnClick)
  self:RegisterEvent(self, TowerModeEvent.OnClickTower, self.OnClickTowerChange)
  _G.NRCEventCenter:RegisterEvent("UMG_TowerMain_C", self, DialogueModuleEvent.DialogueEnded, self.OnClose)
  NRCModeManager:DoCmd(DialogueModuleCmd.HideDialoguePanel)
end

function UMG_TowerMain_C:AddRewards(RewardID)
  self:FillReward(self.awardList, RewardID)
end

function UMG_TowerMain_C:FillReward(Panel, RewardID)
  if not Panel then
    return
  end
  Panel:ClearChildren()
  local RewardConf = _G.DataConfigManager:GetRewardConf(RewardID)
  if not RewardConf then
    return
  end
  self.RewardItems = RewardConf.RewardItem
  self.Panel = Panel
  if not self.RewardItems then
    return
  end
  if 0 == #self.RewardItems then
    return
  end
  self:LoadPanelRes("WidgetBlueprint'/Game/NewRoco/TUI/UMG_Common_Props_Icon.UMG_Common_Props_Icon_C'", 255, self.KlassLoadSucceed, nil, nil)
end

function UMG_TowerMain_C:KlassLoadSucceed(resRequest, Klass)
  if not Klass then
    return
  end
  local Padding = UE4.FMargin()
  Padding.Right = 5
  Padding.Left = 5
  for _, RewardItem in ipairs(self.RewardItems) do
    if RewardItem.Type == Enum.GoodsType.GT_NONE then
    elseif RewardItem.Type == Enum.GoodsType.GT_PET_HP then
    elseif RewardItem.Type == Enum.GoodsType.GT_REWARD then
    elseif RewardItem.Type == Enum.GoodsType.GT_CREATENPC then
    else
      local PropIcon = UE4.UWidgetBlueprintLibrary.Create(self, Klass)
      if not PropIcon then
      else
        PropIcon:SetTip(TipObject.FromRewardItem(RewardItem), true)
        local Slot = self.Panel:AddChild(PropIcon)
        Slot:SetPadding(Padding)
      end
    end
  end
end

function UMG_TowerMain_C:SetEnemyPetList()
  local LevelList = self.data:GetLevelList()
  if self.data.IsMultiplayerPV then
    self.MultiPlayer:SetVisibility(UE4.ESlateVisibility.Visible)
    self.EnemyList:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.EnemyList_1:InitList(LevelList[self.data.SelectLevelIndex].EnemyList_1)
    self.EnemyList_2:InitList(LevelList[self.data.SelectLevelIndex].EnemyList_2)
  else
    self.MultiPlayer:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.EnemyList:SetVisibility(UE4.ESlateVisibility.Visible)
    self.EnemyList:InitList(LevelList[self.data.SelectLevelIndex].EnemyList)
  end
end

function UMG_TowerMain_C:SetLevelList()
  local LevelList = self.data:GetLevelList()
  if LevelList and #LevelList > 0 then
    self.levelList_3:HandleItemSelected(nil, -1)
    self.levelList_3:SetDatas(LevelList)
  else
    self.levelList_3:Clear()
  end
  self.levelList_3:SetCaller(self)
  self.levelList_3.OnItemSelected = self.OnLevelListItemSelected
  Log.Debug(self.data.SelectLevelIndex, self.levelList_3:GetFirstIndex(), self.levelList_3:GetLastIndex(), "UMG_TowerMain_C:saSetLevelList")
  if LevelList and #LevelList > 0 then
    self.levelList_3:ScrollToIndex(self.data.SelectLevelIndex - 1)
    self.levelList_3:SetItemSelected(self.data.SelectLevelIndex + 2)
    self.firstIndex = self.levelList_3:GetLastIndex()
  end
end

function UMG_TowerMain_C:OnTick(deltaTime)
  if self.firstIndex ~= self.levelList_3:GetLastIndex() then
    self.levelList_3:SetItemSelected(self.levelList_3:GetLastIndex() - 2)
    self.data:SetSelectLevelIndex(self.levelList_3:GetLastIndex() - 2)
    self.firstIndex = self.levelList_3:GetLastIndex()
  end
end

function UMG_TowerMain_C:OnLevelListItemSelected(item, Index)
  local LevelList = self.data:GetLevelList()
  self.data:SetSelectLevelIndex(Index)
  self.Title:SetText(LevelList[Index].StageConf.name)
  self:SetEnemyPetList()
  self:SetBtnInfo()
end

function UMG_TowerMain_C:OnClickTowerChange(_index)
end

function UMG_TowerMain_C:SetBtnInfo()
  local ClimbChapterConf = _G.DataConfigManager:GetClimbChapterConf(self.data.stageID)
  local PlayerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  for i, ClimbChapter in ipairs(ClimbChapterConf.stage) do
    if i == self.data.SelectLevelIndex - 2 then
      local StageConf = _G.DataConfigManager:GetStageConf(ClimbChapter)
      if PlayerLevel < StageConf.Role_lv_limit then
        self.CantGetRewards:SetVisibility(UE4.ESlateVisibility.Visible)
        self.HasGotRewards:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.FightBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
        local Text = string.format(LuaText.umg_towermain_3, StageConf.Role_lv_limit)
        self.TextBlock_1040:SetText(Text)
        return
      end
    end
  end
  if self.data.curStage + 2 == self.data.SelectLevelIndex then
    self.CantGetRewards:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.HasGotRewards:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.data.curStage + 2 > self.data.SelectLevelIndex then
    self.CantGetRewards:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.HasGotRewards:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.CantGetRewards:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HasGotRewards:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    local Text = string.format("%s%s", LuaText.umg_towermain_4, self.data.StageConfigure.name)
    self.TextBlock_1040:SetText(Text)
  end
end

function UMG_TowerMain_C:OnAwardListItemSelected(item, index)
  if nil ~= item then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.roleExpAwards[index].level_reward_id, self.uiData.roleExpAwards[index].level_reward_type, false)
  end
end

function UMG_TowerMain_C:SetPieces(stage)
  if 1 == stage then
    self:SetCur(self.Stage1)
    self:SetPre(self.Stage2)
    self:SetPre(self.Stage3)
  elseif #DataConfigManager:GetClimbChapterConf(self.data.stageID).stage > self.data.curStage then
    self:SetPost(self.Stage1)
    self:SetCur(self.Stage2)
    self:SetPre(self.Stage3)
  elseif #DataConfigManager:GetClimbChapterConf(self.data.stageID).stage == self.data.curStage then
    self:SetPost(self.Stage1)
    self:SetPost(self.Stage2)
    self:SetCur(self.Stage3)
  else
    self:SetPost(self.Stage1)
    self:SetPost(self.Stage2)
    self:SetPost(self.Stage3)
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Left:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Right:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.awardList:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.RT:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevRec:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevRec2:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Title:SetText(LuaText.umg_towermain_5)
  end
end

function UMG_TowerMain_C:SetCur(piece)
  piece.TowerCur:SetVisibility(UE4.ESlateVisibility.Visible)
  piece.TowerPost:SetVisibility(UE4.ESlateVisibility.Hidden)
  piece.TowerPre:SetVisibility(UE4.ESlateVisibility.Hidden)
  piece.Effects:SetVisibility(UE4.ESlateVisibility.Visible)
  piece:PlayAnimation(piece.Loop, 0.0, 0)
end

function UMG_TowerMain_C:SetPost(piece)
  piece.TowerCur:SetVisibility(UE4.ESlateVisibility.Hidden)
  piece.TowerPost:SetVisibility(UE4.ESlateVisibility.Visible)
  piece.TowerPre:SetVisibility(UE4.ESlateVisibility.Hidden)
  piece.Effects:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_TowerMain_C:SetPre(piece)
  piece.TowerCur:SetVisibility(UE4.ESlateVisibility.Hidden)
  piece.TowerPost:SetVisibility(UE4.ESlateVisibility.Hidden)
  piece.TowerPre:SetVisibility(UE4.ESlateVisibility.Visible)
  piece.Effects:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_TowerMain_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnClose)
end

function UMG_TowerMain_C:OnClose()
  if not self.IsClose then
    self:DoClose()
  end
end

function UMG_TowerMain_C:OnFightBtnClick()
  if self.LevelReqReached then
    self:AfterClick()
  else
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    Context:SetTitle(LuaText.umg_towermain_6):SetContent(LuaText.umg_towermain_7):SetMode(DialogContext.Mode.OK_CANCEL):SetCallbackOkOnly(self, self.AfterClick):SetClickAnywhereClose(true):SetButtonText(LuaText.umg_towermain_8, LuaText.umg_towermain_9)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function UMG_TowerMain_C:AfterClick()
  if self.Clicked then
    return
  end
  self.Clicked = true
  NRCEventCenter:DispatchEvent(TowerModeEvent.CloseMenu)
  local req = ProtoMessage:newZoneSceneCreateBattleReq()
  req.battle_conf_id = self.data.StageConfigure.battle_id
  req.source_data = ProtoMessage:newSourceData()
  req.source_data.source_type = ProtoEnum.EClientBattleSourceType.ECBST_CLIMB_CHAPTER
  req.source_data.chapter_id = self.data.stageID
  req.source_data.stage_id = self.data.battleID
  local sceneNPC = self.data.NPC.owner
  if sceneNPC then
    req.npc_pt = sceneNPC:GetServerPoint()
    req.npc_obj_id = sceneNPC:GetServerId()
    req.npc_conf_id = sceneNPC.config.id
    req.npc_level = sceneNPC.config.npc_level or 1
    req.option_id = sceneNPC.config.option_id[1]
  end
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CREATE_BATTLE_REQ, req, self, self.OnBattleRsp, true, false)
end

function UMG_TowerMain_C:OnBattleRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    local report = ProtoMessage:newZoneSceneEndChapterReq()
    local sceneNPC = self.data.NPC.owner
    report.option_id = sceneNPC.config.option_id[1]
    report.npc_id = sceneNPC:GetServerId()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_CHAPTER_REQ, report, self, self.OnZoneChapterEnd, false, false)
  else
    self:PlayAnimation(self.close, 0.0, 1)
  end
end

function UMG_TowerMain_C:OnZoneChapterEnd(rsp)
  self:PlayAnimation(self.close, 0.0, 1)
end

function UMG_TowerMain_C:OnCloseButtonClicked()
  self.IsClose = true
  local report = ProtoMessage:newZoneSceneEndChapterReq()
  local sceneNPC = self.data.NPC.owner
  report.option_id = sceneNPC.config.option_id[1]
  report.npc_id = sceneNPC:GetServerId()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_CHAPTER_REQ, report, self, self.OnZoneChapterEnd, false, false)
end

function UMG_TowerMain_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    self:DoClose()
  elseif Animation == self.open then
    self:PlayAnimation(self.loop, 0.0, 0)
  end
end

return UMG_TowerMain_C
