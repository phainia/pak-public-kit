require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local RolePlayModuleEvent = require("NewRoco.Modules.System.RolePlay.RolePlayModuleEvent")
local UIVisibilityConstraint = require("Common.UIVisibilityConstraint")
local RolePlayModuleCmd = require("NewRoco.Modules.System.RolePlay.RolePlayModuleCmd")
local RelationTreeEvent = require("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local MiniGameModuleEvent = require("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
local UMG_NPCInteractMain_C = NRCPanelBase:Extend("UMG_NPCInteractMain_C")
local DirtyFlag = {
  None = 0,
  Init = 1,
  Add = 2,
  Recover = 4,
  Hidden = 8,
  Remove = 16,
  FocusPet = 32
}
local PlaceHolder = {bFake = true}

function UMG_NPCInteractMain_C:OnInitialized()
  self.uiVisibilityConstraint = UIVisibilityConstraint()
  self.FocusTimer = 0.3
  self.CurDirtyFlag = DirtyFlag.None
  self._options = {}
  self.ShownOptions = {}
  self.RealShownNum = 0
  self.bFunctionBan = false
  self.focusPet = nil
  self.MaxSequence = -1
  self.bSequenceChanged = false
end

function UMG_NPCInteractMain_C:OnActive()
  if self.module and self.module.CacheOptions then
    for _, option in ipairs(self.module.CacheOptions) do
      table.insert(self._options, option)
    end
    self.CurDirtyFlag = self.CurDirtyFlag | DirtyFlag.Init
    self.module.CacheOptions = nil
  end
  if self:IsPCMode() then
    local PCScale = UE4.FVector2D(0.8, 0.8)
    self.ObjList:SetRenderScale(PCScale)
    self.IntimateButton:SetRenderScale(PCScale)
    local Padding = UE4.FMargin()
    Padding.Left = 150
    Padding.Top = 136
    Padding.Right = 70
    Padding.Bottom = 84
    self.ScrollPCKey.Slot:SetOffsets(Padding)
    self.ObjList.Slot:SetPosition(UE4.FVector2D(96, 124))
  else
    self.ObjList:BindLuaCallback({
      self,
      self.ClearCurSelectedOption
    })
  end
  self.ObjList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ObjListCollapse = true
  self.ObjList:SetOnScrollingEndedCallback(self.OnScrollEnded, self)
  self.ScrollPCKeyCollapsed = true
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ShouldCollapse = false
  self.IsCollapsed = true
  self.LocalMouseCursorShow = false
  self.DpiScaleY = 1
  self.SelectIndex = nil
  self.CurSelectedOption = nil
  self:FollowSomeOne()
  self.IntimateButton:OnActive()
  self.FarmBubbleButton:OnActive()
  self.shouldHideInOnline = false
  local online_npc_option_visible = _G.DataConfigManager:GetNpcGlobalConfig("online_npc_option_visible")
  if online_npc_option_visible and 1 == online_npc_option_visible.num then
    self.shouldHideInOnline = true
  end
  self:InitScrollListModeByPlatform()
  self:BindInputAction()
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.UnRegisterTopKFinder, self)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.RegisterTopKFinder, "UMG_NPCInteractMain_C", 1, nil, function(sceneNpc)
    if not sceneNpc then
      return nil
    end
    local InterComp = sceneNpc.InteractionComponent
    if not InterComp then
      return nil
    end
    local Opt = InterComp:GetValid3DOption()
    return Opt
  end)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, MainUIModuleEvent.MAINUICLOSE, self.OnLobbyMainClosed)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, SceneEvent.PlayerBornFinish, self.OnSceneLoaded)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, RolePlayModuleEvent.RolePlayMainPanelOpen, self.OnRolePlayMainPanelOpen)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, RolePlayModuleEvent.RolePlayMainPanelClosed, self.OnRolePlayMainPanelClosed)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, RelationTreeEvent.RelationInteractionStart, self.InteractionStart)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, RelationTreeEvent.RelationInteractionEnd, self.InteractionEnd)
  _G.NRCEventCenter:RegisterEvent("UMG_NPCInteractMain_C", self, MiniGameModuleEvent.StartFinishedCamera, self.StartFinishedCamera)
  _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_LOAD_HIDE_PLAYER_MANUAL_OPTION_CONF, self, self.OnAddFunctionBan)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.InteractMainReady)
end

function UMG_NPCInteractMain_C:OnEnable()
  if not self.module then
    return
  end
  if _G.NRCModuleManager:IsModuleActive("RolePlayModule") and _G.NRCModuleManager:DoCmd(RolePlayModuleCmd.IsMainPanelOpen) then
    self.uiVisibilityConstraint:AddWidgetDisplayConstraints(self, "RolePlay")
  end
  local MainPanel = self.module:HasPanel("LobbyMain") and self.module:GetPanel("LobbyMain")
  if MainPanel and MainPanel.PanelOpen then
    self.uiVisibilityConstraint:TrySetWidgetVisibility(self, UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.ShouldCollapse then
      Log.Debug("[NPCInteractMainUI] ShouldCollapse changed:", self.ShouldCollapse, "-> false (OnEnable, LobbyMain open)")
    end
    self.ShouldCollapse = false
  else
    self.uiVisibilityConstraint:TrySetWidgetVisibility(self, UE4.ESlateVisibility.Collapsed)
    if not self.ShouldCollapse then
      Log.Debug("[NPCInteractMainUI] ShouldCollapse changed:", self.ShouldCollapse, "-> true (OnEnable, LobbyMain closed)")
    end
    self.ShouldCollapse = true
  end
  self:SetLuoPanSound(true)
end

function UMG_NPCInteractMain_C:OnDisable()
  self:SetLuoPanSound(false)
end

function UMG_NPCInteractMain_C:OnDeactive()
  self:UnBindInputAction()
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUICLOSE, self.OnLobbyMainClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerBornFinish, self.OnSceneLoaded)
  _G.NRCEventCenter:UnRegisterEvent(self, RolePlayModuleEvent.RolePlayMainPanelOpen, self.OnRolePlayMainPanelOpen)
  _G.NRCEventCenter:UnRegisterEvent(self, RolePlayModuleEvent.RolePlayMainPanelClosed, self.OnRolePlayMainPanelClosed)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_LOAD_HIDE_PLAYER_MANUAL_OPTION_CONF, self, self.OnAddFunctionBan)
  _G.NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.RelationInteractionStart, self.InteractionStart)
  _G.NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.RelationInteractionEnd, self.InteractionEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.StartFinishedCamera, self.StartFinishedCamera)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.UnRegisterTopKFinder, self)
  _G.UpdateManager:UnRegister(self)
end

function UMG_NPCInteractMain_C:OnSceneLoaded()
  self:BindInputAction()
end

function UMG_NPCInteractMain_C:BindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MainUIDefault")
  if mappingContext then
    local actions = {
      {
        name = "IA_InteractionStart",
        method = "InteractionStart"
      },
      {
        name = "IA_InteractionEnd",
        method = "InteractionEnd"
      },
      {
        name = "IA_FondlePet",
        method = "IntimatePet"
      }
    }
    for _, action in ipairs(actions) do
      mappingContext:BindAction(action.name, self, action.method, UE.ETriggerEvent.Triggered)
    end
    self.mouseWheelIndex = 0
  end
end

function UMG_NPCInteractMain_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MainUIDefault")
  if mappingContext then
    local actions = {
      {
        name = "IA_InteractionStart"
      },
      {
        name = "IA_InteractionEnd"
      },
      {
        name = "IA_InteractionPrevious"
      },
      {
        name = "IA_InteractionNext"
      },
      {
        name = "IA_FondlePet"
      }
    }
    for _, action in ipairs(actions) do
      mappingContext:UnBindAction(action.name)
    end
  end
end

function UMG_NPCInteractMain_C:OnAddFunctionBan(newState, _)
  self.bFunctionBan = newState
  if newState then
    self.CurDirtyFlag = self.CurDirtyFlag | DirtyFlag.Hidden
  else
    self.CurDirtyFlag = self.CurDirtyFlag | DirtyFlag.Recover
  end
end

local BannedList = {}
local AllowList = {}
local ActionTypeList = {}

function UMG_NPCInteractMain_C:CheckOptionIDBanned(Option)
  local OptionID = Option.config.id
  local ActionType = Option.config.action and Option.config.action.action_type
  return self:CheckBanStatus(OptionID, ActionType)
end

function UMG_NPCInteractMain_C:CollectActiveConfigs()
  table.clear(BannedList)
  table.clear(AllowList)
  table.clear(ActionTypeList)
  local Conds = _G.FunctionBanManager:GetConditionCounterDic()
  for Key, Count in pairs(Conds) do
    if Count and Count > 0 then
      local Conf = _G.DataConfigManager:GetHidePlayerManualOptionConf(Key, true)
      if Conf then
        for _, v in ipairs(Conf.banned_list or {}) do
          BannedList[v] = true
        end
        for _, v in ipairs(Conf.allowed_list or {}) do
          AllowList[v] = true
        end
        for _, v in ipairs(Conf.allow_list or {}) do
          if v.allowed_list then
            ActionTypeList[v.allowed_list] = true
          end
        end
      end
    end
  end
end

function UMG_NPCInteractMain_C:CheckBanStatus(OptionID, ActionType)
  if next(BannedList) then
    if BannedList[OptionID] then
      Log.Debug("UMG_NPCInteractMain_C:CheckOptionIDBanned OptionID:", OptionID, " is in BannedList - BANNED")
      return true
    elseif next(ActionTypeList) then
      if not ActionTypeList[ActionType] then
        Log.Debug("UMG_NPCInteractMain_C:CheckOptionIDBanned OptionID:", OptionID, " ActionType:", ActionType, " not allowed when BannedList exists - BANNED")
        return true
      else
        return false
      end
    else
      return false
    end
  end
  if next(AllowList) then
    if AllowList[OptionID] then
      return false
    elseif next(ActionTypeList) then
      if not ActionTypeList[ActionType] then
        Log.Debug("UMG_NPCInteractMain_C:CheckOptionIDBanned OptionID:", OptionID, " not in AllowList and ActionType:", ActionType, " not allowed - BANNED")
        return true
      else
        return false
      end
    else
      Log.Debug("UMG_NPCInteractMain_C:CheckOptionIDBanned OptionID:", OptionID, " not in AllowList and no ActionType restriction - BANNED")
      return true
    end
  end
  if next(ActionTypeList) then
    if not ActionTypeList[ActionType] then
      Log.Debug("UMG_NPCInteractMain_C:CheckOptionIDBanned OptionID:", OptionID, " ActionType:", ActionType, " not in ActionTypeList - BANNED")
      return true
    else
      return false
    end
  end
  return false
end

function UMG_NPCInteractMain_C:InteractionStart()
  self.ObjList.longTouch = nil
  local selected_item = self.ObjList:GetSelectedItem()
  if selected_item then
    selected_item:OnTouchStarted()
  end
end

function UMG_NPCInteractMain_C:InteractionEnd()
  if self.ObjList.longTouch then
    return
  end
  local selected_item = self.ObjList:GetSelectedItem()
  if selected_item then
    local isLockOpen = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetLockOpenSubUI)
    if isLockOpen then
      selected_item:ClearCacheData()
      return
    end
    selected_item:OnTouchEnded()
  end
end

function UMG_NPCInteractMain_C:SelectNextInteraction(IsFromRelation)
  self.mouseWheelIndex = self.mouseWheelIndex + 1
  if 1 == self.mouseWheelIndex % 2 then
    self:MouseWheelDown(nil, IsFromRelation)
  end
end

function UMG_NPCInteractMain_C:SelectPreviousInteraction(IsFromRelation)
  self.mouseWheelIndex = self.mouseWheelIndex + 1
  if 1 == self.mouseWheelIndex % 2 then
    self:MouseWheelUp(nil, IsFromRelation)
  end
end

function UMG_NPCInteractMain_C:IntimatePet()
  if self.IntimateButton:GetVisibility() == UE4.ESlateVisibility.Visible then
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_NPCInteractMain_C:IntimatePet")
    self.IntimateButton:ExecuteOption()
  end
end

function UMG_NPCInteractMain_C:OnLobbyMainClosed()
  if not self.ShouldCollapse then
    Log.Debug("[NPCInteractMainUI] ShouldCollapse changed:", self.ShouldCollapse, "-> true (OnLobbyMainClosed)")
  end
  self.ShouldCollapse = true
end

function UMG_NPCInteractMain_C:OnLobbyMainReady()
  if self.ShouldCollapse then
    Log.Debug("[NPCInteractMainUI] ShouldCollapse changed:", self.ShouldCollapse, "-> false (OnLobbyMainReady)")
  end
  self.ShouldCollapse = false
end

function UMG_NPCInteractMain_C:AddNPCInteract(option)
  if table.contains(self._options, option) then
    Log.Debug("[NPCInteractMainUI] \230\183\187\229\138\160\233\135\141\229\164\141\231\154\132Option")
    return true
  end
  if option.config.id == self.AutoPlayActionId then
    option:OnOptionAction()
    self.AutoPlayActionId = nil
    return false
  else
    Log.Debug("[NPCInteractMainUI] AddNPCInteract", option.config.id)
    if not self._options then
      Log.Error("[NPCInteractMainUI] \229\135\186\231\142\176\228\186\134\231\165\158\231\167\152\231\154\132\230\151\182\229\186\143\233\151\174\233\162\152\239\188\129\239\188\129\239\188\129")
      self._options = {}
    end
    table.insert(self._options, option)
    if option.IsPetOption and option:IsPetOption() then
      self:TryFocusPet(self._options, true, 0)
    end
    self.CurDirtyFlag = self.CurDirtyFlag | DirtyFlag.Add
    return true
  end
  return false
end

function UMG_NPCInteractMain_C:RemoveNPCInteract(option)
  local InList = table.removeValue(self._options, option)
  if not InList then
    return false
  end
  Log.Debug("[NPCInteractMainUI] RemoveNPCInteract", option.config.id)
  if option.IsPetOption and option:IsPetOption() then
    self:TryFocusPet(self._options, true, 0)
  end
  if option.owner and option.IsPetBond and option:IsPetBond() then
    option.owner:SetPetBondActive(false)
  end
  if option.GetEnableCondition and option:GetEnableCondition() == _G.Enum.OptionVisibleCondition.ENABLE_CONDITION_OPTION_TYPE then
    option.owner:SetHomeOptionActive(false)
  end
  if option == self.CurSelectedOption then
    self.ObjList:ClearSelection()
  end
  self.CurDirtyFlag = self.CurDirtyFlag | DirtyFlag.Remove
  return true
end

function UMG_NPCInteractMain_C:HasDirtyFlag(Flag)
  return 0 ~= self.CurDirtyFlag & Flag
end

function UMG_NPCInteractMain_C:RefreshOptionList()
  self:FilterOptions(self._options)
  self:SortOptionsBySequence(self.ShownOptions)
  self:UpdateScrollListByPlatform()
  self:UpdateScrollIcon(self.ShownOptions)
  local oldObjListCollapse = self.ObjListCollapse
  if 0 == self:GetShowOptionNum() then
    if self.ObjList.longTouchItem then
      self.ObjList.longTouchItem:ClearCacheData()
    end
    if self.CurSelectedOption then
      self.CurSelectedOption.bSelected = false
      self.CurSelectedOption = nil
    end
    if self:HasDirtyFlag(DirtyFlag.Remove) then
      self.SelectIndex = nil
    end
    self.ObjList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if not self:IsPCMode() then
      self.Arrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.ObjListCollapse = true
  else
    self:UpdateSelectIndexByPlatform()
    self.ObjList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self:IsPCMode() then
      self.Arrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.ObjListCollapse = false
  end
  if oldObjListCollapse ~= self.ObjListCollapse then
    Log.Debug("[NPCInteractMainUI] ObjListCollapse changed:", oldObjListCollapse, "->", self.ObjListCollapse, "ShownOptionNum:", self:GetShowOptionNum())
  end
end

function UMG_NPCInteractMain_C:InitScrollListModeByPlatform()
  if not self:IsPCMode() then
    self.ObjList.bSnapToItem = true
    self.ObjList.Owner = self
  else
    self.objList.bSnapToItem = false
    self.Arrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.ShownOptions and next(self.ShownOptions) then
    self.ObjList:InitList(self.ShownOptions)
  end
end

function UMG_NPCInteractMain_C:UpdateScrollListByPlatform()
  if not self:IsPCMode() then
    if #self.ShownOptions >= 2 then
      table.insert(self.ShownOptions, 1, PlaceHolder)
      table.insert(self.ShownOptions, PlaceHolder)
      table.insert(self.ShownOptions, PlaceHolder)
    else
      table.insert(self.ShownOptions, 1, PlaceHolder)
    end
  end
  self.ObjList:InitList(self.ShownOptions)
end

function UMG_NPCInteractMain_C:AutoPlayAction(optionId)
  self.AutoPlayActionId = optionId
  for _, v in pairs(self._options) do
    if v.config.id == optionId then
      v:OnOptionAction()
      self.AutoPlayActionId = nil
    end
  end
end

function UMG_NPCInteractMain_C:SetLuoPanSound(bAdd)
  local bLuoPanPlay = true
  if _G.CinematicModuleCmd then
    local bIsPlaying = _G.NRCModeManager:DoCmd(_G.CinematicModuleCmd.IsPlaying)
    if bIsPlaying then
      bLuoPanPlay = false
    end
  end
  if _G.DialogueModuleCmd then
    local HasDialogue = _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.CheckHasDialogue, true)
    if HasDialogue then
      bLuoPanPlay = false
    end
  end
  if bLuoPanPlay and self:GetShowOptionNum() > 0 then
    for i, _ in ipairs(self.ShownOptions) do
      local Item = self.ObjList:GetItemByIndex(i - 1)
      if Item and Item.IsHasLuoPan then
        if bAdd then
          self:TryPlayLuoPanSound()
        end
        return
      end
    end
  end
  self:TryStopLuoPanSound()
end

function UMG_NPCInteractMain_C:TryPlayLuoPanSound()
  if not self.AudioSession then
    self.AudioSession = _G.NRCAudioManager:PlaySound2DAuto(1220002044, "UMG_NPCInteractItem_C:PlayShine")
  end
end

function UMG_NPCInteractMain_C:TryStopLuoPanSound()
  if self.AudioSession then
    _G.NRCAudioManager:ReleaseSession(self.AudioSession, true, "", false, 1)
    self.AudioSession = nil
  end
end

function UMG_NPCInteractMain_C:MouseWheelDown(action_type, IsFromRelation)
  if 1 == action_type then
    return
  end
  if 0 == self:GetShowOptionNum() then
    return
  end
  if self:IsMouseCursorShow() and not IsFromRelation then
    return
  end
  local CurSelectedItem = self.ObjList:GetSelectedItem()
  CurSelectedItem:SetHoverBG(false)
  CurSelectedItem:ReleaseMouseCapture(false)
  local selected_index = self.ObjList._selectedItemIndex + 1
  while selected_index > self:GetShowOptionNum() do
    selected_index = selected_index - self:GetShowOptionNum()
  end
  self:SelectOptionByIndex(selected_index)
end

function UMG_NPCInteractMain_C:MouseWheelUp(action_type, IsFromRelation)
  if 1 == action_type then
    return
  end
  if 0 == self:GetShowOptionNum() then
    return
  end
  if self:IsMouseCursorShow() and not IsFromRelation then
    return
  end
  local CurSelectedItem = self.ObjList:GetSelectedItem()
  CurSelectedItem:SetHoverBG(false)
  CurSelectedItem:ReleaseMouseCapture(false)
  local selected_index = self.ObjList._selectedItemIndex - 1
  while selected_index < 1 do
    selected_index = selected_index + self:GetShowOptionNum()
  end
  self:SelectOptionByIndex(selected_index)
end

function UMG_NPCInteractMain_C:Interact(action_type)
  if 1 == action_type then
    return
  end
  LoadingProfiler:CheckPoint(LoadingProfilerCheckPoint.InteractMainInteract)
  local selected_item = self.ObjList:GetSelectedItem()
  if selected_item and selected_item.option then
    self.SelectIndex = selected_item._index
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1067, "UMG_NPCInteractMain_C:Interact")
    selected_item.option:OnOptionAction()
  else
    Log.Debug("[NPCInteractMainUI] \231\142\169\229\174\182\231\130\185\229\135\187\228\186\134\230\140\137\233\146\174\228\189\134\230\152\175\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146...")
  end
end

function UMG_NPCInteractMain_C:UpdateSelectIndexByPlatform()
  local itemCount = self.ObjList:GetItemCount()
  if self:GetShowOptionNum() <= 0 or itemCount <= 0 then
    return
  end
  if self.CurSelectedOption and not self.bSequenceChanged then
    local NewIndex = self:FindOptionIndexByPlatform(self.CurSelectedOption)
    if NewIndex then
      self:SelectOptionByIndex(NewIndex)
      return
    end
  end
  if self.SelectIndex and not self.bSequenceChanged then
    self.SelectIndex = math.clamp(self.SelectIndex, 1, self:IsPCMode() and self:GetShowOptionNum() or self:GetShowOptionNum() + 1)
    self:SelectOptionByIndex(self.SelectIndex)
    return
  end
  local DefaultIndex = self:GetDefaultSelectIndexByPlatform()
  self:SelectOptionByIndex(DefaultIndex)
  self.bSequenceChanged = false
end

function UMG_NPCInteractMain_C:FindOptionIndexByPlatform(TargetOption)
  if not self:IsPCMode() then
    local StartIndex = 1
    local EndIndex = self.ObjList:GetItemCount() - 2
    for Index = StartIndex, EndIndex do
      local Item = self.ObjList:GetItemByIndex(Index - 1)
      if Item and Item.option == TargetOption then
        return Index
      end
    end
  else
    for Index, option in ipairs(self.ShownOptions) do
      if option == TargetOption then
        return Index
      end
    end
  end
  return nil
end

function UMG_NPCInteractMain_C:GetDefaultSelectIndexByPlatform()
  if not self:IsPCMode() then
    return 2
  else
    return 1
  end
end

function UMG_NPCInteractMain_C:IsPCMode()
  return _G.UE4Helper.IsPCMode()
end

function UMG_NPCInteractMain_C:UpdateScrollIcon(shown_options)
  local shown_options_num = shown_options and #shown_options or 0
  local isShow = shown_options_num > 1 and self:IsPCMode()
  self.ScrollPCKey:SetScrollMode()
  self.ScrollPCKey:SetKeyVisibility(isShow)
  local oldScrollPCKeyCollapsed = self.ScrollPCKeyCollapsed
  self.ScrollPCKeyCollapsed = not isShow
  if oldScrollPCKeyCollapsed ~= self.ScrollPCKeyCollapsed then
    Log.Debug("[NPCInteractMainUI] ScrollPCKeyCollapsed changed:", oldScrollPCKeyCollapsed, "->", self.ScrollPCKeyCollapsed, "shown_options_num:", shown_options_num, "IsPCMode:", self:IsPCMode())
  end
end

function UMG_NPCInteractMain_C:GetShowOptionNum()
  return self.RealShownNum or 0
end

function UMG_NPCInteractMain_C:IsMouseCursorShow()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    local playerController = localPlayer:GetUEController()
    if playerController then
      self.LocalMouseCursorShow = playerController.bShowMouseCursor
    end
  end
  return self.LocalMouseCursorShow
end

function UMG_NPCInteractMain_C:SelectOptionByIndex(Index)
  self.SelectIndex = Index
  Index = Index - 1
  if Index < 0 or Index >= self.ObjList:GetItemCount() then
    self.ObjList:ClearSelection()
    return
  else
    self:SelectWithScrollByPlatform(Index)
  end
  self.ObjList:GetSelectedItem():SetBackGround(true)
  self:UpdateCurSelectedOption()
end

function UMG_NPCInteractMain_C:SelectWithScrollByPlatform(Index)
  self.ObjList:SelectItemByIndex(Index)
  if self:IsPCMode() then
    self.ObjList:ScrollToIndex(Index, true)
  else
    self.ObjList:SetScrollOffset((Index - 1) * self.ObjList:GetItemSize().Y)
  end
end

function UMG_NPCInteractMain_C:GetCurrentSelectedOption()
  local selected_item = self.ObjList:GetSelectedItem()
  if selected_item and selected_item.option then
    return selected_item.option
  end
  return nil
end

function UMG_NPCInteractMain_C:FollowSomeOne()
  _G.UpdateManager:Register(self)
end

local AddFlags = DirtyFlag.Add | DirtyFlag.Init | DirtyFlag.Recover
local RemoveFlags = DirtyFlag.Remove | DirtyFlag.Hidden

function UMG_NPCInteractMain_C:OnTick(deltaTime)
  if self.focusPet and self:TryFocusPet(self._options, false, deltaTime) then
    self.CurDirtyFlag = self.CurDirtyFlag | DirtyFlag.FocusPet
  end
  if self.CurDirtyFlag ~= DirtyFlag.None then
    Log.Debug("[NPCInteractMainUI] Refresh By DirtyFlag:", self.CurDirtyFlag, #self.ShownOptions)
    self:RefreshOptionList()
    local bAdd
    if self:HasDirtyFlag(AddFlags) then
      bAdd = true
    elseif self:HasDirtyFlag(RemoveFlags) then
      bAdd = false
    end
    if nil ~= bAdd then
      self:SetLuoPanSound(bAdd)
    end
    self.CurDirtyFlag = DirtyFlag.None
  end
  local npcs = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetTopKNPC, "UMG_NPCInteractMain_C")
  self:SetShowCollapse()
  if npcs and #npcs > 0 then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer and localPlayer.statusComponent and (localPlayer.statusComponent:HasStatus(_G.ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING) or localPlayer.statusComponent:HasStatus(_G.ProtoEnum.WorldPlayerStatusType.WPST_FALLING)) then
      self:SetIntimateButtonCollapsed(true)
      self:SetFarmBubbleButtonCollapsed(true)
      self.FarmBubbleButton:SetOption()
      return
    end
    local npc = npcs[1]
    local InterComp = npc and npc.InteractionComponent
    local option = InterComp and InterComp:GetValid3DOption()
    if not option then
      self:SetIntimateButtonCollapsed(true)
      self:SetFarmBubbleButtonCollapsed(true)
      return
    end
    local PlayerInteractState = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetPlayerInteractStateCache)
    if option:IsInteractBanState(PlayerInteractState) then
      self:SetIntimateButtonCollapsed(true)
      self:SetFarmBubbleButtonCollapsed(true)
      return
    end
    if option.config.npc_interact_type == Enum.InteractType.IT_3DUI then
      self.IntimateButton.Slot:SetPosition(self:GetLocatorLocation(npc.viewObj, "locator_Head", true))
      self.IntimateButton:SetOption(option)
    end
    if option.config.npc_interact_type == Enum.InteractType.IT_PLANT_SEED or option.config.npc_interact_type == Enum.InteractType.IT_PLANT_GET then
      self.FarmBubbleButton.Slot:SetPosition(self:GetLocatorLocation(npc.viewObj, nil, false))
      self.FarmBubbleButton:SetOption(option)
    else
      self.FarmBubbleButton:SetOption()
    end
    if npc.viewObj.IsMovementBaseHasTag and npc.viewObj:IsMovementBaseHasTag("DYNAMIC_MOVEBASE") then
      self:SetIntimateButtonCollapsed(true)
      self:SetFarmBubbleButtonCollapsed(true)
    elseif option.config.npc_interact_type == Enum.InteractType.IT_3DUI then
      self:SetIntimateButtonCollapsed(false)
    elseif option.config.npc_interact_type == Enum.InteractType.IT_PLANT_SEED or option.config.npc_interact_type == Enum.InteractType.IT_PLANT_GET then
      self:SetFarmBubbleButtonCollapsed(false)
    end
  else
    self:SetIntimateButtonCollapsed(true)
    self:SetFarmBubbleButtonCollapsed(true)
    self.FarmBubbleButton:SetOption()
  end
end

function UMG_NPCInteractMain_C:SetIntimateButtonCollapsed(isCollapsed)
  if self.IntimateButtonCollapsed == nil or self.IntimateButtonCollapsed ~= isCollapsed then
    if isCollapsed then
      self.IntimateButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.IntimateButton:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.IntimateButtonCollapsed = isCollapsed
  end
end

function UMG_NPCInteractMain_C:SetFarmBubbleButtonCollapsed(isCollapsed)
  if self.FarmBubbleButtonCollapsed == nil or self.FarmBubbleButtonCollapsed ~= isCollapsed then
    if isCollapsed then
      self.FarmBubbleButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.FarmBubbleButton:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.FarmBubbleButtonCollapsed = isCollapsed
    Log.Trace("[NPCInteractMainUI] SetFarmBubbleButtonCollapsed: ", isCollapsed)
  end
end

function UMG_NPCInteractMain_C:SetShowCollapse()
  local IsCollapse = true
  if self.ObjListCollapse and self.ScrollPCKeyCollapsed and self.IntimateButtonCollapsed and self.FarmBubbleButtonCollapsed then
    IsCollapse = true
  else
    IsCollapse = self.ShouldCollapse
  end
  if self.IsCollapsed ~= IsCollapse then
    Log.Debug("[NPCInteractMainUI] IsCollapsed changed:", self.IsCollapsed, "->", IsCollapse, "ObjListCollapse:", self.ObjListCollapse, "ScrollPCKeyCollapsed:", self.ScrollPCKeyCollapsed, "IntimateButtonCollapsed:", self.IntimateButtonCollapsed, "FarmBubbleButtonCollapsed:", self.FarmBubbleButtonCollapsed, "ShouldCollapse:", self.ShouldCollapse)
    self.IsCollapsed = IsCollapse
    if IsCollapse then
      self.uiVisibilityConstraint:TrySetWidgetVisibility(self, UE4.ESlateVisibility.Collapsed)
    else
      self.uiVisibilityConstraint:TrySetWidgetVisibility(self, UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    local actualVisibility = self:GetVisibility()
    local expectedVisibility = IsCollapse and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible
    if actualVisibility ~= expectedVisibility then
      Log.Warning("[NPCInteractMainUI] TrySetWidgetVisibility FAILED! actual:", actualVisibility, "expected:", expectedVisibility)
    end
  end
end

function UMG_NPCInteractMain_C:GetLocatorLocation(viewObj, _, isPet)
  if not viewObj then
    return
  end
  local headPosition
  if isPet then
    local PetMesh = viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
    if not PetMesh then
      return
    end
    local CapsuleComponent = viewObj:GetComponentByClass(UE4.UCapsuleComponent)
    local CapsuleLocation = PetMesh:Abs_GetSocketLocation("locator_head")
    local CapsuleRadius = CapsuleComponent:GetScaledCapsuleRadius()
    headPosition = CapsuleLocation
    headPosition.Z = headPosition.Z + 20
    local rightVector = viewObj:GetActorRightVector()
    headPosition.X = headPosition.X + rightVector.X * CapsuleRadius * 0.5
    headPosition.Y = headPosition.Y + rightVector.Y * CapsuleRadius * 0.5
    headPosition.Z = headPosition.Z + rightVector.Z * CapsuleRadius * 0.5
  else
    headPosition = viewObj:Abs_K2_GetActorLocation()
    headPosition.Z = headPosition.Z + 200
  end
  local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  local ScreenPos = UE4.FVector2D()
  local InScreen = UE4.UGameplayStatics.Abs_ProjectWorldToScreen(playerController, headPosition, ScreenPos)
  if InScreen then
    local ViewportPos = UE4.FVector2D()
    UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), ScreenPos, ViewportPos)
    ViewportPos.X = ViewportPos.X * self.DpiScaleY
    ViewportPos.Y = ViewportPos.Y * self.DpiScaleY
    return ViewportPos
  else
    local ViewportPos = UE4.FVector2D()
    ViewportPos.X = -1000
    ViewportPos.Y = -1000
    return ViewportPos
  end
end

function UMG_NPCInteractMain_C:OnRolePlayMainPanelOpen()
  self.uiVisibilityConstraint:AddWidgetDisplayConstraints(self, "RolePlay")
end

function UMG_NPCInteractMain_C:OnRolePlayMainPanelClosed()
  self.uiVisibilityConstraint:RemoveWidgetDisplayConstraints(self, "RolePlay")
end

function UMG_NPCInteractMain_C:OnPcRemovePlant()
  if self.FarmBubbleButton:IsVisible() and self.FarmBubbleButton.OnClicked then
    self.FarmBubbleButton:OnClicked()
  end
end

function UMG_NPCInteractMain_C:FilterOptions()
  table.clear(self.ShownOptions)
  self:CollectActiveConfigs()
  local RawIndex = 1
  for _, option in ipairs(self._options) do
    if not self.bFunctionBan then
      table.insert(self.ShownOptions, option)
      option.RawIndex = RawIndex
      RawIndex = RawIndex + 1
    elseif self.bFunctionBan and not self:CheckOptionIDBanned(option) then
      table.insert(self.ShownOptions, option)
      option.RawIndex = RawIndex
      RawIndex = RawIndex + 1
    end
  end
  if self.focusPet then
    for i = #self.ShownOptions, 1, -1 do
      local option = self.ShownOptions[i]
      if option.IsPetOption and option:IsPetOption() then
        if option.owner ~= self.focusPet then
          table.remove(self.ShownOptions, i)
          option:SetPetBondOptionActive(false)
        else
          option:SetPetBondOptionActive(true)
        end
      end
      if option.GetEnableCondition and option:GetEnableCondition() == _G.Enum.OptionVisibleCondition.ENABLE_CONDITION_OPTION_TYPE then
        if option.owner ~= self.focusPet then
          table.remove(self.ShownOptions, i)
          option:SetHomeOptionActive(false)
        else
          option:SetHomeOptionActive(true)
        end
      end
    end
  else
    for _, option in ipairs(self.ShownOptions) do
      if option.IsPetOption and option:IsPetOption() then
        option:SetPetBondOptionActive(true)
      end
      if option.GetEnableCondition and option:GetEnableCondition() == _G.Enum.OptionVisibleCondition.ENABLE_CONDITION_OPTION_TYPE then
        option:SetHomeOptionActive(true)
      end
    end
  end
  self.RealShownNum = #self.ShownOptions
end

function UMG_NPCInteractMain_C:SortOptionsBySequence(Options)
  table.sort(Options, function(option1, option2)
    if option1.config.option_sequence == option2.config.option_sequence then
      return option1.RawIndex < option2.RawIndex
    end
    return (option1.config.option_sequence or 0) > (option2.config.option_sequence or 0)
  end)
  if next(self.ShownOptions) then
    local NewMaxSequence = self.ShownOptions[1].config.option_sequence or -1
    if NewMaxSequence > self.MaxSequence then
      self.bSequenceChanged = true
    end
    self.MaxSequence = NewMaxSequence
  end
end

local UMathLibrary = UE4.UKismetMathLibrary

function UMG_NPCInteractMain_C:TryFocusPet(options, bForceFocus, deltaTime)
  if bForceFocus then
    self.FocusTimer = self.FocusTimer + deltaTime
  elseif self.FocusTimer < 0.3 then
    self.FocusTimer = self.FocusTimer + deltaTime
    return false
  else
    self.FocusTimer = self.FocusTimer - 0.3
  end
  if not options or not next(options) then
    return false
  end
  local petDic = {}
  local petCount = 0
  for _, option in ipairs(options) do
    if option.IsPetOption and option:IsPetOption() then
      local owner = option.owner
      if nil ~= owner and not petDic[owner] then
        petDic[owner] = true
        petCount = petCount + 1
      end
    end
  end
  local bChanged = false
  if petCount > 1 then
    bChanged = self:FocusPet(petDic)
  else
    self.focusPet = nil
    self.FocusTimer = 0.3
  end
  return bChanged
end

function UMG_NPCInteractMain_C:FocusPet(petDic)
  local focusPet
  local maxDotProduct = math.mininteger
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return false
  end
  local playerPos = localPlayer:GetActorLocation()
  local playerForward = localPlayer:GetForwardVector()
  playerForward.Z = 0
  for petNpc, _ in pairs(petDic) do
    local pet2PlayerForwardDot = petNpc.PlayerForwardDotCache
    if not pet2PlayerForwardDot then
      local petPos = petNpc:GetActorLocation()
      local directionToPet = UMathLibrary.Subtract_VectorVector(petPos, playerPos)
      directionToPet.Z = 0
      directionToPet = UMathLibrary.Normal(directionToPet)
      pet2PlayerForwardDot = UMathLibrary.Dot_VectorVector(playerForward, directionToPet)
    end
    if maxDotProduct < pet2PlayerForwardDot then
      maxDotProduct = pet2PlayerForwardDot
      focusPet = petNpc
    end
  end
  if self.focusPet ~= focusPet then
    self.focusPet = focusPet
    Log.Debug("[NPCInteractMainUI] focusPet changed:", focusPet and focusPet:DebugNPCNameAndID())
    return true
  end
  return false
end

function UMG_NPCInteractMain_C:OnScrollEnded(Index)
  if self:IsPCMode() then
    return
  end
  self.ObjList:SelectItemByIndex(Index)
  self.SelectIndex = Index + 1
  self:UpdateCurSelectedOption()
end

function UMG_NPCInteractMain_C:UpdateCurSelectedOption()
  local SelectedOption = self:GetCurrentSelectedOption()
  if SelectedOption and SelectedOption ~= self.CurSelectedOption then
    if self.CurSelectedOption then
      self.CurSelectedOption.bSelected = false
    end
    SelectedOption.bSelected = true
    self.CurSelectedOption = SelectedOption
  end
end

function UMG_NPCInteractMain_C:ClearCurSelectedOption()
  local CurSelectedItem = self.ObjList:GetSelectedItem()
  if not CurSelectedItem then
    return
  end
  if self.ObjList.longTouchItem then
    self.ObjList.longTouchItem:ClearCacheData()
  end
  self.ObjList:ClearSelection()
  if self.CurSelectedOption then
    self.CurSelectedOption.bSelected = false
    self.CurSelectedOption = nil
  end
end

function UMG_NPCInteractMain_C:StartFinishedCamera(bStart)
  if self.ShouldCollapse ~= bStart then
    Log.Debug("[NPCInteractMainUI] ShouldCollapse changed:", self.ShouldCollapse, "->", bStart, "(StartFinishedCamera)")
  end
  self.ShouldCollapse = bStart
end

return UMG_NPCInteractMain_C
