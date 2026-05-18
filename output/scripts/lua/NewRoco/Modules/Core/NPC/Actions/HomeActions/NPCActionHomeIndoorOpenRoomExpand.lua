local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local M = Base:Extend("NPCActionHomeIndoorOpenRoomExpand")

function M:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function M:Execute()
  Base.Execute(self)
  self.RunningSkills = {}
  if not self:InternalExecute() then
    self:Finish(true)
  end
end

function M:OnClosePanel(PanelData)
  local Name = PanelData.panelName
  if "HomeExpandPanel" == Name then
    if self.bNeedUnRegisterClosePanel then
      self.bNeedUnRegisterClosePanel = false
      _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
    end
    self:Finish(true)
  end
end

function M:InternalExecute()
  if not HomeIndoorSandbox:InLocalMasterIndoor() then
    return false
  end
  if HomeIndoorSandbox.Module:IsHomeExpandEstablished() then
    if HomeIndoorSandbox.World.Controller:ReqUpgradeHome() then
      HomeIndoorSandbox:DebugTips("\232\175\183\230\177\130\230\137\169\229\187\186\229\174\140\230\136\144")
    end
    return false
  end
  if not DataConfigManager:GetRoomConf(HomeIndoorSandbox.Server.WorldData.RoomLevel + 1) then
    HomeIndoorSandbox:DebugTips("\229\183\178\231\187\143\232\190\190\229\136\176\228\186\134\230\156\128\229\164\167\231\173\137\231\186\167\239\188\140\230\151\160\230\179\149\229\134\141\232\191\155\232\161\140\230\137\169\229\187\186")
    return false
  end
  return self:InternalPerform()
end

function M:InternalPerform()
  HomeIndoorSandbox.World:HideCurrRoomFurniture(true)
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("\230\137\190\228\184\141\229\136\176owner")
    return false
  end
  local skillComp = owner.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Home/G6_Home_ThrowScroll", skillComp, PriorityEnum.Active_Player_Action)
  if not skill then
    Log.Error("\230\137\190\228\184\141\229\136\176Skill")
    return false
  end
  local player = self:GetPlayer()
  if player then
    player:SetVisible(false)
  end
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, true)
  HomeIndoorSandbox.Module:PreLoadPanel("HomeExpandPanel")
  self.RunningSkills[skill] = true
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(owner.viewObj)
  skill:SetTargets({
    owner.viewObj
  })
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  return true
end

function M:OnSkillStart(Skill, Result)
  if Result ~= UE.ESkillStartResult.Success then
    self:SkillComplete()
  else
    DelayManager:DelaySeconds(1, FPartial(self.OnTimeoutThrow, self))
  end
end

function M:OnTimeoutThrow()
  if self.bFinishThisAction then
    return
  end
  self:SkillComplete()
end

function M:SkillComplete()
  if self.bPlaneCompleted then
    return
  end
  self.bPlaneCompleted = true
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeExpandPanel, function(bSuccess)
    if bSuccess then
      _G.NRCEventCenter:RegisterEvent("NPCActionHomeIndoorOpenLevelReward", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
      self.bNeedUnRegisterClosePanel = true
      HomeIndoorSandbox:RegisterEvent(HomeIndoorSandbox.Event.OnReqPlayExpandStartSkill, self, self.OnReqPlayExpandStartSkill)
      self.bNeedUnRegisterExpandStartSkill = true
      self:PreloadG6RelativeRes()
    elseif not self.bFinishThisAction then
      self:Finish(true)
    end
  end)
end

function M:NotifyFinish(success, data, param)
  if self.bFinishThisAction then
    return
  end
  self:Submit()
  Base.Finish(self, success, data, param)
  self.SkipCommit = true
end

function M:Finish(...)
  Base.Finish(self, ...)
  if self.bNeedUnRegisterExpandStartSkill then
    self.bNeedUnRegisterExpandStartSkill = false
    HomeIndoorSandbox:UnRegisterEvent(HomeIndoorSandbox.Event.OnReqPlayExpandStartSkill, self)
  end
  if self.bNeedUnRegisterClosePanel then
    self.bNeedUnRegisterClosePanel = false
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  end
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnReqCloseBlackBarAnimation)
  self.bFinishThisAction = true
  if self.PreloadAssets then
    for k, v in ipairs(self.PreloadAssets) do
      HomeIndoorSandbox.ResMgr:ReleaseResource(v)
    end
  end
  if self.PreloadTimeoutTimer then
    DelayManager:CancelDelayById(self.PreloadTimeoutTimer)
    self.PreloadTimeoutTimer = nil
  end
  for skill, _ in pairs(self.RunningSkills) do
    skill:CancelSkill()
    skill:Destroy()
  end
  local Owner = self:GetOwnerNPC()
  if self.SkillCharacters then
    for k, Actor in pairs(self.SkillCharacters) do
      if Actor and Actor:IsValid() and Actor ~= Owner.viewObj then
        Actor:K2_DestroyActor()
      end
    end
  end
  Owner:SetVisible(true)
  HomeIndoorSandbox.World:HideCurrRoomFurniture(false)
  local player = self:GetPlayer()
  if player then
    player:SetVisible(true)
  end
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_OTHER_PLAYER, false)
  if self.bHasInputBlock then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.RemoveInputBlockMappingContext, "NPCActionHomeIndoorOpenRoomExpand")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "NPCActionHomeIndoorOpenRoomExpand")
  end
end

function M:PreloadG6RelativeRes()
  self.LoadFlags = {}
  self.CombatIndexResourcePath = {
    [BattleConst.CharacterIndex.Player2] = "/Game/ArtRes/BP/Scene/NPC_09802/BP_Scene_NPC_09802.BP_Scene_NPC_09802_C",
    [BattleConst.CharacterIndex.Player3] = "/Game/ArtRes/BP/Scene/NPC_09803/BP_Scene_NPC_09803.BP_Scene_NPC_09803_C",
    [BattleConst.CharacterIndex.Player4] = "/Game/ArtRes/BP/Scene/NPC_09801/BP_Scene_NPC_09801.BP_Scene_NPC_09801_C"
  }
  local CombatResourcePathCnt = 3
  self.PreloadAssets = {}
  local Count = 0
  local bAllFinish = false
  
  local function OnLoad(k, r)
    self.LoadFlags[k] = true
    Count = Count + 1
    HomeIndoorSandbox:LogDebug("[\232\161\168\230\188\148] \233\162\132\229\138\160\232\189\189\229\133\179\232\129\148\232\181\132\230\186\144\229\174\140\230\136\144\239\188\154", self.CombatIndexResourcePath[k], r)
    if Count == CombatResourcePathCnt then
      bAllFinish = true
      HomeIndoorSandbox:LogDebug("[\232\161\168\230\188\148] \233\162\132\229\138\160\232\189\189\229\133\168\233\131\168\231\187\147\230\157\159")
      self:OnPreloadResFinish()
    end
  end
  
  for k, v in pairs(self.CombatIndexResourcePath) do
    table.insert(self.PreloadAssets, HomeIndoorSandbox.ResMgr:ReqResource(FPartial(OnLoad, k), v))
  end
  self.PreloadTimeoutTimer = DelayManager:DelaySeconds(10, function()
    self.PreloadTimeoutTimer = nil
    if not bAllFinish then
      self:OnPreloadResFinish()
    end
  end)
end

function M:OnPreloadResFinish()
  self.bPreloadAllFinishThisAction = true
  self:TryDoPlayExpandSkill()
end

function M:TryDoPlayExpandSkill()
  if self.bFinishThisAction then
    return
  end
  if not self.bPreloadAllFinishThisAction then
    return
  end
  if self.DoPlayExpandSkillAfterResourceLoad then
    HomeIndoorSandbox:LogDebug("[\232\161\168\230\188\148] \230\137\169\229\187\186\229\138\168\228\189\156\229\188\128\229\167\139")
    for k, v in pairs(self.CombatIndexResourcePath) do
      local Res = HomeIndoorSandbox.ResMgr:TryGetResource(v)
      if Res then
        self.SkillCharacters[k] = UE4Helper.GetCurrentWorld():SpawnActor(Res, UE.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
      end
      HomeIndoorSandbox:LogDebug("[\232\161\168\230\188\148] \230\137\169\229\187\186\229\175\185\232\177\161\229\136\155\229\187\186\239\188\154", k, v, Res, self.SkillCharacters[k] and self.SkillCharacters[k]:GetName())
    end
    self.DoPlayExpandSkillAfterResourceLoad()
  end
end

function M:LoadResources(Path, Callback)
  return HomeIndoorSandbox.ResMgr:ReqResource(Callback, Path)
end

function M:OnInterrupted()
  self:SkillComplete()
end

function M:OnExpandStartPerformResult(bStart)
  if self.bExpandPerformStart == false and bStart then
    HomeIndoorSandbox:Ensure(false, "logical error")
    return
  end
  self.bExpandPerformStart = bStart
  if bStart then
    local player = self:GetPlayer()
    if player then
      player:SetVisible(false)
    end
  else
    local player = self:GetPlayer()
    if player then
      player:SetVisible(true)
    end
  end
  if not bStart then
    self:InternalOpenEndAnimation()
    self:NotifyFinish(true, 1, "1")
  end
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnRspPlayExpandStartSkill, bStart)
end

function M:OnReqPlayExpandStartSkill()
  self.bHasInputBlock = true
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.AddInputBlockMappingContext, "NPCActionHomeIndoorOpenRoomExpand")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker, "NPCActionHomeIndoorOpenRoomExpand")
  if self.bNeedUnRegisterExpandStartSkill then
    self.bNeedUnRegisterExpandStartSkill = false
    HomeIndoorSandbox:UnRegisterEvent(HomeIndoorSandbox.Event.OnReqPlayExpandStartSkill, self)
  end
  self.DoPlayExpandSkillAfterResourceLoad = nil
  local player = self:GetPlayer()
  if not player then
    Log.Error("\230\137\190\228\184\141\229\136\176player")
    return self:OnExpandStartPerformResult(false)
  end
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("\230\137\190\228\184\141\229\136\176owner")
    return self:OnExpandStartPerformResult(false)
  end
  local skillComp = owner.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Home/G6_Home_Whistle", skillComp)
  if not skill then
    Log.Error("\230\137\190\228\184\141\229\136\176Skill")
    return self:OnExpandStartPerformResult(false)
  end
  HomeIndoorSandbox.Module:PreLoadPanel("HomeBlackBarAnimation")
  HomeIndoorSandbox.Module:PreLoadPanel("HomeBuildCutscenes")
  self.SkillCharacters = {}
  
  function self.DoPlayExpandSkillAfterResourceLoad()
    if not UE.UObject.IsValid(owner.viewObj) then
      return
    end
    self.SkillCharacters[BattleConst.CharacterIndex.Player1] = owner.viewObj
    self.RunningSkills[skill] = true
    skill:SetCharacters(self.SkillCharacters)
    skill:SetWithLoadAndPlay(true)
    skill:SetCaster(owner.viewObj)
    skill:SetTargets({
      owner.viewObj
    })
    skill:RegisterEventCallback("End", self, self.OnExpandStartSkillComplete1)
    skill:RegisterEventCallback("Interrupt", self, self.OnExpandStartSkillComplete1)
    skill:PlaySkill(self, self.OnExpandStartSkillBegin1)
  end
  
  self:TryDoPlayExpandSkill()
  return self:OnExpandStartPerformResult(true)
end

function M:OnExpandStartSkillBegin1(Skill, Result)
  if Result ~= UE.ESkillStartResult.Success then
    self:OnExpandStartSkillComplete1()
  else
    HomeIndoorSandbox.Module:OpenPanel("HomeBlackBarAnimation")
    DelayManager:DelaySeconds(2, function()
      HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnReqCloseBlackBarAnimation)
    end)
  end
end

function M:OnExpandStartSkillComplete1()
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnReqCloseBlackBarAnimation)
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("\230\137\190\228\184\141\229\136\176owner")
    return self:OnExpandStartPerformResult(false)
  end
  local skillComp = owner.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Home/G6_Home_Work_DiBan", skillComp)
  if not skill then
    Log.Error("\230\137\190\228\184\141\229\136\176Skill")
    return self:OnExpandStartPerformResult(false)
  end
  skill:SetCharacters(self.SkillCharacters)
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(owner.viewObj)
  skill:SetTargets({
    owner.viewObj
  })
  skill:RegisterEventCallback("End", self, self.OnExpandStartSkillComplete2)
  skill:RegisterEventCallback("Interrupt", self, self.OnExpandStartSkillComplete2)
  skill:PlaySkill(self, self.OnExpandStartSkillBegin2)
end

function M:OnExpandStartSkillBegin2(Skill, Result)
  if Result ~= UE.ESkillStartResult.Success then
    self:OnExpandStartSkillComplete2()
  else
    DelayManager:DelaySeconds(3, function()
      self:InternalOpenEndAnimation()
    end)
  end
end

function M:OnExpandStartSkillComplete2()
  self:OnExpandStartPerformResult(false)
end

function M:InternalOpenEndAnimation()
  if self.bFinishThisAction then
    return
  end
  if not self.bEndAnimationOpened then
    self.bEndAnimationOpened = true
    HomeIndoorSandbox.Module:OpenPanel("HomeBuildCutscenes")
  end
end

return M
