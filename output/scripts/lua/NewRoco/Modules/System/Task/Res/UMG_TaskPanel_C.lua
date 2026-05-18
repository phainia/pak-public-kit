local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local Base = _G.NRCPanelBase
local UMG_TaskPanel_C = _G.NRCPanelBase:Extend("UMG_TaskPanel_C")
UMG_TaskPanel_C.DebugMode = false
UMG_TaskPanel_C.TypeList = {
  Enum.TaskClassType.TCT_MAIN,
  Enum.TaskClassType.TCT_SUB,
  Enum.TaskClassType.TCT_EVOLUTION
}
UMG_TaskPanel_C.TypeList_Dungeon = {
  Enum.TaskClassType.TCT_DUNGEON,
  Enum.TaskClassType.TCT_MAIN,
  Enum.TaskClassType.TCT_SUB,
  Enum.TaskClassType.TCT_EVOLUTION
}
UMG_TaskPanel_C.TypeList_Dungeon_Hide = {
  Enum.TaskClassType.TCT_DUNGEON
}

function UMG_TaskPanel_C:OnConstruct()
  self:AddButtonListener(self.btnClose.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.TrackButton.btnLevelUp, self.OnTrackClick)
  self:BtnInit()
end

function UMG_TaskPanel_C:OnDestruct()
  self:RemoveButtonListener(self.CloseButton)
  self:RemoveButtonListener(self.OnTrackClick)
end

function UMG_TaskPanel_C:OnCloseButtonClicked()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  UE4Helper.SetEnableWorldRendering(true)
  UE4.UNRCAudioManager.ResetWorldListenerVolumeOffset()
  _G.NRCAudioManager:PlaySound2DAuto(9020, "UMG_LobbyMain_C:MenuMusic")
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_LobbyMain_C:OnBtnTaskClick")
  self:PlayAnimation(self.close)
  for _, Child in wpairs(self.TaskBlockList) do
    Child:StarClose()
  end
end

function UMG_TaskPanel_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    localPlayer.inputComponent:SetInputEnable(self, true)
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    Base.DoClose(self)
  elseif Animation == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    UE4Helper.SetEnableWorldRendering(false)
  end
end

function UMG_TaskPanel_C:OnActive()
  UE4.UNRCAudioManager.SetWorldListenerVolumeOffset(_G.DataConfigManager:GetGlobalConfigByKeyType("ui_audio_reduction_db", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num)
  _G.NRCAudioManager:PlaySound2DAuto(9019, "UMG_LobbyMain_C:MenuMusic")
  self:ActiveInternal()
end

function UMG_TaskPanel_C:OnTrackReqRsp(rsp)
end

function UMG_TaskPanel_C:OnBtnPress()
  self:PlayAnimation(self.Press)
end

function UMG_TaskPanel_C:OnBtnRelease()
  self:PlayAnimation(self.Up)
end

function UMG_TaskPanel_C:ActiveInternal()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
  self.TraceTasks = self.module:GetAllTraceTask(true)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, false)
  NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
  NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  local DInfo = _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id
  local ListOfTypes = UMG_TaskPanel_C.TypeList
  if DInfo and DInfo[1] > 0 then
    ListOfTypes = UMG_TaskPanel_C.TypeList_Dungeon
    local DConf = DataConfigManager:GetDungeonConf(DInfo[1], true)
    if DConf and (DConf.hide_tag == Enum.HideTagType.HD_ALL or DConf.hide_tag == Enum.HideTagType.HD_PANEL) then
      ListOfTypes = UMG_TaskPanel_C.TypeList_Dungeon_Hide
    end
  end
  local DisplayList = {}
  for _, Type in ipairs(ListOfTypes) do
    local Show = true
    if Show then
      local Style = _G.DataConfigManager:GetTaskStyleConf(Type, true)
      Style = Style or _G.DataConfigManager:GetTaskStyleConf(Enum.TaskClassType.TCT_NONE)
      local TaskList = {}
      local Block = {}
      Block.Type = Type
      Block.List = TaskList
      Block.Style = Style
      Block.Active = true
      for _, TO in ipairs(self.TraceTasks) do
        local Conf = TO.Config
        if TO.Config.task_class == Type and TO:ShowInTaskPanel() or UMG_TaskPanel_C.DebugMode then
          local Data = {}
          Data.Info = TO.Info
          Data.Config = TO.Config
          Data.Type = Type
          Data.Style = Style
          if 0 ~= Conf.paragraph_id then
            Data.ParagraphConfig = _G.DataConfigManager:GetParagraphConf(Conf.paragraph_id)
          end
          table.insert(TaskList, Data)
          Data.Index = #TaskList
          if UMG_TaskPanel_C.DebugMode then
            Data = {}
            Data.Info = TO.Info
            Data.Config = Conf
            Data.Type = Type
            Data.Style = Style
            if 0 ~= Conf.paragraph_id then
              Data.ParagraphConfig = _G.DataConfigManager:GetParagraphConf(Conf.paragraph_id)
            end
            table.insert(TaskList, Data)
            Data.Index = #TaskList
          end
        end
      end
      if #TaskList <= 0 then
        Block.Active = false
      end
      table.insert(DisplayList, Block)
      Block.Index = #DisplayList
    end
  end
  self.DisplayList = DisplayList
  self:RefreshTaskList()
end

function UMG_TaskPanel_C:RefreshTaskList()
  self.TaskBlockList:ClearChildren()
  local Sat = false
  for Index, Block in ipairs(self.DisplayList) do
    local BlockView = UE4.UWidgetBlueprintLibrary.Create(self, self.TaskBlockTemplate)
    self.TaskBlockList:AddChild(BlockView)
    BlockView.Parent = self
    BlockView:SetData(Block, Index)
    if #Block.List > 0 and not Sat then
      for _, task in ipairs(Block.List) do
        if task.Info.is_track then
          BlockView:SetItemSelected(true)
          Sat = true
          break
        end
      end
    end
    BlockView:RefreshTaskList()
  end
  if not Sat then
    for Index, Block in ipairs(self.DisplayList) do
      if #Block.List > 0 and not Sat then
        for TaskInd, task in ipairs(Block.List) do
          local BlockView = self.TaskBlockList:GetChildAt(Index - 1)
          BlockView:SetItemSelected(true)
          BlockView:RefreshTaskList(true)
          Sat = true
          break
        end
      end
    end
  end
  if not Sat then
    self.VB:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HB1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HB2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HB3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Rewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TrackButton:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.VB:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HB1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HB2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.HB3:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Rewards:SetVisibility(UE4.ESlateVisibility.Visible)
    self.TrackButton:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_TaskPanel_C:SetCurrentTask(Task)
  if self.ParagraphTitle then
    if Task.ParagraphConfig then
      self.ParagraphTitle:SetText(Task.ParagraphConfig.title)
    elseif Task.Config then
      self.ParagraphTitle:SetText(Task.Config.name)
    end
  end
  if self.TaskLocation then
    self.TaskLocation:SetText(Task.Config.belong_place)
  end
  if self.ParagraphDesc then
    if Task.ParagraphConfig then
      self.ParagraphDesc:SetText(Task.ParagraphConfig.description)
    elseif Task.Config then
      self.ParagraphDesc:SetText(Task.Config.task_des)
    end
  end
  if self.CondDesc then
    local Desc = {}
    for _, v in ipairs(Task.Config.task_condition) do
      table.insert(Desc, v.text)
    end
    self.CondDesc:SetText(table.concat(Desc, "\n"))
  end
  if self.TrackButton then
    self.TrackButton:SetBtnText(Task.Info.is_track and LuaText.umg_taskpanel_1 or LuaText.umg_taskpanel_2)
  end
  if self.AwardList then
    if Task.Type == Enum.TaskClassType.TCT_EVOLUTION then
      self.AwardDesc:SetText(LuaText.umg_taskpanel_3)
      local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(Task.Info.pet_gid)
      self:FillPet(self.AwardList, PetData)
    else
      self.AwardDesc:SetText(LuaText.umg_taskpanel_4)
      if Task.ParagraphConfig then
        self:FillReward(self.AwardList, Task.ParagraphConfig.Reward)
      elseif Task.Config then
        self:FillReward(self.AwardList, Task.Config.Reward)
      end
    end
  end
  if self.Background then
    self.Background:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Task/Raw/Atlas/Task/image_bg_Sprite.image_bg_Sprite'")
  end
  self.CurrentTask = Task
end

function UMG_TaskPanel_C:SetSelectBlock(Block)
  self.TrackButton:SetVisibility(UE4.ESlateVisibility.Visible)
  for _, Child in wpairs(self.TaskBlockList) do
    Child:SetItemSelected(Child.CurrentData.Type == Block.Type)
    if not Child.IsSelected then
      Child:SetSelectTask(nil)
    end
  end
end

function UMG_TaskPanel_C:OnTrackClick()
  self:PlayAnimation(self.Up)
  if not self.CurrentTask then
    return
  end
  local Track = not self.CurrentTask.Info.is_track
  local Task = self.module:SetTrack(self.CurrentTask.Info.id, Track)
  if not Task then
    return
  end
  if Track ~= Task.isTrack then
    Log.Error(Track, Task.isTrack, "\228\187\187\229\138\161\232\191\189\232\184\170\231\138\182\230\128\129\230\156\137\232\175\175")
  end
  if Task.isTrack then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1041, "UMG_TaskPanel_C:OnTrackClick Track")
    self:OnCloseButtonClicked()
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_TaskPanel_C:OnTrackClick No Track")
    self:SetCurrentTask(self.CurrentTask)
    self:RefreshTaskBlocks()
  end
end

function UMG_TaskPanel_C:RefreshTaskBlocks()
  for _, Child in wpairs(self.TaskBlockList) do
    Child:Refresh()
  end
end

function UMG_TaskPanel_C:OnDeactive()
end

function UMG_TaskPanel_C:FillReward(Panel, RewardID)
  if not Panel then
    return
  end
  Panel:ClearChildren()
  local RewardConf = _G.DataConfigManager:GetRewardConf(RewardID)
  if not RewardConf then
    return
  end
  local RewardItems = RewardConf.RewardItem
  if not RewardItems then
    return
  end
  if 0 == #RewardItems then
    return
  end
  local Klass = UE4.UClass.Load("WidgetBlueprint'/Game/NewRoco/TUI/UMG_Common_Props_Icon.UMG_Common_Props_Icon_C'")
  if not Klass then
    return
  end
  local Padding = UE4.FMargin()
  Padding.Right = 7
  Padding.Left = 7
  for _, RewardItem in ipairs(RewardItems) do
    if RewardItem.Type == Enum.GoodsType.GT_NONE then
    elseif RewardItem.Type == Enum.GoodsType.GT_PET_HP then
    elseif RewardItem.Type == Enum.GoodsType.GT_REWARD then
    else
      local PropIcon = UE4.UWidgetBlueprintLibrary.Create(self, Klass)
      if not PropIcon then
      else
        PropIcon:SetTip(TipObject.FromRewardItem(RewardItem), true)
        local Slot = Panel:AddChild(PropIcon)
        Slot:SetPadding(Padding)
      end
    end
  end
  return RewardItems
end

function UMG_TaskPanel_C:FillPet(Panel, petData)
  if not Panel then
    return
  end
  Panel:ClearChildren()
  if not petData then
    return
  end
  local Klass = UE4.UClass.Load("WidgetBlueprint'/Game/NewRoco/TUI/UMG_Common_Props_Icon.UMG_Common_Props_Icon_C'")
  if not Klass then
    return
  end
  local Padding = UE4.FMargin()
  Padding.Right = 5
  Padding.Left = 5
  local Item = TipObject.FromRaw(TipEnum.TipObjectType.NewPet, _G.ProtoEnum.GoodsType.GT_PET, petData.base_conf_id, 1, false)
  Item.petData = petData
  local PropIcon = UE4.UWidgetBlueprintLibrary.Create(self, Klass)
  PropIcon:SetTip(Item, true)
  local Slot = Panel:AddChild(PropIcon)
  Slot:SetPadding(Padding)
end

function UMG_TaskPanel_C:BtnInit()
  self.TrackButton:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_combtn_di1_png.img_combtn_di1_png'")
end

return UMG_TaskPanel_C
