local JsonUtils = require("Common.JsonUtils")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
local DebugTabHistory = require("NewRoco.Modules.System.Debug.Tabs.DebugTabHistory")
local UMG_DebugPanel_C = _G.NRCPanelBase:Extend("UMG_DebugPanel_C")

function UMG_DebugPanel_C:SetupTabs()
  self.module.data:ClearGMItemData()
  self:AddCategory("\229\142\134\229\143\178", "NewRoco.Modules.System.Debug.Tabs.DebugTabHistory")
  self:AddCategory("\229\133\168\229\177\128\230\144\156\231\180\162", "NewRoco.Modules.System.Debug.Tabs.DebugTabGlobalSearch")
  self:AddCategory("PGC", "NewRoco.Modules.System.Debug.Tabs.DebugTabPGC")
  self:AddCategoryFromExcel()
  self:AddCategory("\228\184\139\232\189\189", "NewRoco.Modules.System.Debug.Tabs.DebugTabDownload")
  self:AddCategory("Profiler", "Profiler.DebugTabProfiler", "Profiler", false)
  self:AddCategory("Profiler", "Profiler.DebugTabPerfDogExtension", "PerfDog", false)
  self:AddCategory("TUI", "NewRoco.Modules.System.Debug.Tabs.DebugTabOperationUI", "\232\191\144\232\144\165\231\155\184\229\133\179UI")
  self:AddCategory("\229\156\186\230\153\175", "NewRoco.Modules.System.Debug.Tabs.DebugTabSceneTest", "\230\181\139\232\175\149")
  self:AddCategory("\230\148\182\232\151\143\233\161\181\231\173\190", "NewRoco.Modules.System.Debug.Tabs.DebugTabCollect")
  self:AddCategory("\233\173\148\230\179\149", "NewRoco.Modules.System.Debug.Tabs.DebugTabMagicReplay", "\231\149\153\229\189\177\233\173\148\230\179\149")
  self:AddCategory("\229\133\171\229\164\167\229\139\139\231\171\160", "NewRoco.Modules.System.Debug.Tabs.DebugTabBattleRogueEvent", "\230\136\152\230\150\151\228\186\139\228\187\182")
  self.module.data:SetGMItemDataFinishFlag()
  local Order = {}
  table.insert(Order, {
    name = "\229\133\168\233\131\168",
    NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
  })
  self.DebugDropDownList_3:OnActive(Order)
  self:AddServerGm()
end

function UMG_DebugPanel_C:SetlockImage()
  self.LockSeting = JsonUtils.LoadSaved("LockSet", {})
  for Index, Category in ipairs(self.Categories) do
    local Name = Category[1]
    local Found = self.LockSeting[Name]
    if not Found then
      self.LockSeting[Name] = {}
      self.LockSeting[Name][self.BoxLockStat] = {false, ""}
      self.LockSeting[Name][self.FrameLockStat] = {false, ""}
    end
    if Category.SecondTabInfo and #Category.SecondTabInfo > 0 then
      for SecondIndex, SecondCategory in ipairs(Category.SecondTabInfo) do
        local SecondName = SecondCategory[1]
        local SecondFound = self.LockSeting[Name][SecondName]
        if not SecondFound then
          self.LockSeting[Name][SecondName] = {}
          self.LockSeting[Name][SecondName][self.BoxLockStat] = {false, ""}
          self.LockSeting[Name][SecondName][self.FrameLockStat] = {false, ""}
        end
      end
    end
  end
end

function UMG_DebugPanel_C:OnConstruct()
  self.Categories = {}
  self.CategoriesMap = {}
  self.AllLabel = {}
  self.SecondCategories = {}
  self.MostUse = {}
  self.OriginalOrder = {}
  self.SecondOriginalOrder = {}
  self.SecondTabCategories = {}
  self.SecondTabCategoriesInfo = {}
  self.Items = {}
  self.Options = {}
  self.UniversalItem = {}
  self.CustomOrders = {}
  self.args = nil
  self.CurrentTabName = ""
  self.SecondTabName = ""
  self.CurrentSecondTabName = nil
  self.InputBoxName = "InputBox"
  self.InputFrameName = "InputFrame"
  self.BoxLockStat = "BoxLock"
  self.FrameLockStat = "FrameLock"
  self.DebugDropDownList:setDebugInfoMainCtrl(self.SortSearchTabs, self.InputBoxName, self)
  self.DebugDropDownListTest:setDebugInfoMainCtrl(self.SortSearchTabs, self.InputFrameName, self)
  self.LockSeting = {}
  self.CharArray = {}
  self.CharSizeArray = {}
  self.CharTextSizeList = {
    self.NRCTextSize,
    self.NRCTextSize_1,
    self.NRCTextSize_2,
    self.NRCTextSize_3,
    self.NRCTextSize_4,
    self.NRCTextSize_5,
    self.NRCTextSize_6,
    self.NRCTextSize_7,
    self.NRCTextSize_8,
    self.NRCTextSize_9,
    self.NRCTextSize_10,
    self.NRCTextSize_11,
    self.NRCTextSize_12,
    self.NRCTextSize_13,
    self.NRCTextSize_14,
    self.NRCTextSize_15,
    self.NRCTextSize_16,
    self.NRCTextSize_17,
    self.NRCTextSize_18,
    self.NRCTextSize_19
  }
  self.SearchStartTime = 0
  self.SearchEndTime = 0.5
  self.CharDeltaTime = 0
  self.CanRemove = false
  self.CharItem = nil
  self.ConfIndex = 1
  self:OnAddEventListener()
  if not RocoEnv.IS_EDITOR then
    self.CloseButton.OnClicked:Add(self, self.OnCloseButton)
  end
  self:BindCloseBtn(self.CloseButton)
  if not RocoEnv.IS_EDITOR then
    self.InputBoxLockBtn.OnClicked:Add(self, self.OnInputBoxLockBtn)
  end
  self:AddButtonListener(self.InputBoxLockBtn, self.OnInputBoxLockBtn)
  if not RocoEnv.IS_EDITOR then
    self.InputFrameLockBtn.OnClicked:Add(self, self.OnInputFrameLockBtn)
  end
  self:AddButtonListener(self.InputFrameLockBtn, self.OnInputFrameLockBtn)
  self.SortTab = self.module:GetData("DebugModuleData")
  self.IsCollect = false
  self.IsHistory = false
  self.CancelCollect = false
  self.CancelHistory = false
  self.CollectSateText = nil
  self.ButtonInfo = nil
  self.Instruction = nil
  self.UseType = nil
  self.Order = nil
  self.IsSearch = false
  self.Button_OutPutExcel.Caption:SetText("\229\175\188\229\135\186\230\140\135\228\187\164")
  self.NRCSwitcher:SetActiveWidgetIndex(0)
  self:SortTabListSet()
  self.DebugDropDownList_1:setDebugInfoMainCtrl(self.SortSearchTabs, self.InputBoxName, self)
  self.DebugDropDownList_2:setDebugInfoMainCtrl(self.SortSearchTabs, self.InputBoxName, self)
  self.DebugDropDownList_3:setDebugInfoMainCtrl(self.SortSearchTabs, self.InputBoxName, self)
  self.isshowabbrevia = false
  self.IsPCState = false
  self:AddButtonListener(self.AbbreviaButton, self.SwitchPanelState)
  self:AddButtonListener(self.Button_backexpand, self.SwitchPanelState)
  self:AddButtonListener(self.CloseButton_abbre, self.OnCloseAbbrePanel)
  self:AddButtonListener(self.Button_SwitchPCState, self.SwitchPCState)
  self:AddButtonListener(self.Button_SwitchPCState_1, self.SwitchPCState)
  self:AddButtonListener(self.Btn_ClearResult, self.ClearResult)
  self:AddButtonListener(self.Btn_ClearHistory, self.ClearHistory)
  self:ClearResult()
end

function UMG_DebugPanel_C:SortTabListSet()
  local Instruction = self.SortTab:GetInstruction()
  local UseType = self.SortTab:GetUseType()
  self.DebugDropDownList_1:OnActive(Instruction[1])
  self.DebugDropDownList_2:OnActive(UseType[1])
end

function UMG_DebugPanel_C:OnAddEventListener()
  self.InputFrame.OnTextChanged:Add(self, self.OnClickSearchButton)
  self.InputBox.OnTextChanged:Add(self, self.OnClickSearchButtonBox)
  self.AbbreInputBox.OnTextChanged:Add(self, self.OnClickSearchButtonBox)
  self.InputFrame.OnTextCommitted:Add(self, self.OnClickTextCommitted)
  self:RegisterEvent(self, DebugModuleEvent.SelectSearchContent, self.SetInputInfo)
  self:RegisterEvent(self, DebugModuleEvent.FindShortcutKey, self.FindBindKeyBoard)
  self:RegisterEvent(self, DebugModuleEvent.DeleteFile, self.DeleteFileEvent)
  self:RegisterEvent(self, DebugModuleEvent.SelectSearchInstruction, self.SetInstructionInfo)
  self:RegisterEvent(self, DebugModuleEvent.RefreshResult, self.RefreshResult)
  self:RegisterEvent(self, DebugModuleEvent.RefreshHistory, self.RefreshHistory)
  self:AddButtonListener(self.Button_Collect.Button, self.AddCollect)
  self:AddButtonListener(self.Button_ClearHistory.Button, self.ClearSelectedHistory)
  self:AddButtonListener(self.Button_OutPutExcel.Button, self.OutPutExcel)
  self.InputBox.OnTextCommitted:Add(self, self.OnInputBoxTextCommitted)
end

function UMG_DebugPanel_C:OnCloseButton()
  _G.NRCModuleManager:GetModule("DebugModule"):DispatchEvent(DebugModuleEvent.OpenOrCloseDebugPanel)
end

function UMG_DebugPanel_C:RefreshResult(Result)
  self.TextResult:SetText(Result)
end

function UMG_DebugPanel_C:ClearResult()
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.ClearResult)
  self.TextResult:SetText("")
end

function UMG_DebugPanel_C:ClearHistory()
  if self.CollectSateText == "\229\142\134\229\143\178" then
    local SaveButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
    if SaveButtonInfos then
      JsonUtils.DeleteFile("DebugTabHistory")
    end
    NRCModuleManager:DoCmd(_G.DebugModuleCmd.RefreshHistory)
  end
end

function UMG_DebugPanel_C:OnInputBoxLockBtn()
  if not string.IsNilOrEmpty(self.SecondTabName) then
    if not self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][1] then
      self.InputBoxLockSwitcher:SetActiveWidgetIndex(0)
      local InputText = self:GetInputString()
      self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][2] = InputText
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\231\188\147\229\173\152\229\189\147\229\137\141\230\149\176\230\141\174\229\136\176json\230\150\135\228\187\182")
    end
    if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][1] then
      self.InputBoxLockSwitcher:SetActiveWidgetIndex(1)
      self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][2] = ""
      self.InputBox:SetText("")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\135\138\230\148\190\229\189\147\229\137\141\230\149\176\230\141\174")
    end
    self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][1] = not self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][1]
  else
    if not self.LockSeting[self.CurrentTabName][self.BoxLockStat][1] then
      self.InputBoxLockSwitcher:SetActiveWidgetIndex(0)
      local InputText = self:GetInputString()
      self.LockSeting[self.CurrentTabName][self.BoxLockStat][2] = InputText
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\231\188\147\229\173\152\229\189\147\229\137\141\230\149\176\230\141\174\229\136\176json\230\150\135\228\187\182")
    end
    if self.LockSeting[self.CurrentTabName][self.BoxLockStat][1] then
      self.InputBoxLockSwitcher:SetActiveWidgetIndex(1)
      self.LockSeting[self.CurrentTabName][self.BoxLockStat][2] = ""
      self.InputBox:SetText("")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\135\138\230\148\190\229\189\147\229\137\141\230\149\176\230\141\174")
    end
    self.LockSeting[self.CurrentTabName][self.BoxLockStat][1] = not self.LockSeting[self.CurrentTabName][self.BoxLockStat][1]
  end
end

function UMG_DebugPanel_C:OnInputFrameLockBtn()
  if not string.IsNilOrEmpty(self.SecondTabName) then
    if not self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] then
      self.InputFrameLockSwitcher:SetActiveWidgetIndex(0)
      local InputText = self:GetInputFrameString()
      self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][2] = InputText
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\231\188\147\229\173\152\229\189\147\229\137\141\230\149\176\230\141\174\229\136\176json\230\150\135\228\187\182")
    end
    if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] then
      self.InputFrameLockSwitcher:SetActiveWidgetIndex(1)
      self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][2] = ""
      self.InputFrame:SetText("")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\135\138\230\148\190\229\189\147\229\137\141\230\149\176\230\141\174")
    end
    self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] = not self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1]
  else
    if not self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
      self.InputFrameLockSwitcher:SetActiveWidgetIndex(0)
      local InputText = self:GetInputFrameString()
      self.LockSeting[self.CurrentTabName][self.FrameLockStat][2] = InputText
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\231\188\147\229\173\152\229\189\147\229\137\141\230\149\176\230\141\174\229\136\176json\230\150\135\228\187\182")
    end
    if self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
      self.InputFrameLockSwitcher:SetActiveWidgetIndex(1)
      self.LockSeting[self.CurrentTabName][self.FrameLockStat][2] = ""
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\135\138\230\148\190\229\189\147\229\137\141\230\149\176\230\141\174")
      self.InputFrame:SetText("")
    end
    self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] = not self.LockSeting[self.CurrentTabName][self.FrameLockStat][1]
  end
end

function UMG_DebugPanel_C:OnClickSearchButton()
  local InputText = self:GetInputFrameString()
  if "" == InputText then
    self.SearchStartTime = 0
    _G.UpdateManager:UnRegister(self)
    self:SearchContent()
  else
    self.SearchStartTime = 0
    _G.UpdateManager:Register(self)
  end
end

function UMG_DebugPanel_C:SearchContent()
  local InputText = self:GetInputFrameString()
  local lowerInputText = string.lower(InputText)
  if not string.IsNilOrEmpty(self.SecondTabName) then
    if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] then
      self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][2] = InputText
    end
  elseif self.LockSeting and self.LockSeting[self.CurrentTabName] and self.LockSeting[self.CurrentTabName][self.FrameLockStat] and self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
    self.LockSeting[self.CurrentTabName][self.FrameLockStat][2] = InputText
  end
  local SearchItems
  local UpdateItems = {}
  if "" ~= InputText then
    self.IsSearch = true
    if self.CollectSateText == "\229\133\168\229\177\128\230\144\156\231\180\162" then
      local globalItemList = self.module.data:GetGMItemData()
      for i, v in ipairs(globalItemList) do
        if string.find(string.lower(v[1]), lowerInputText) then
          table.insert(UpdateItems, v)
        end
      end
    else
      for i, v in ipairs(self.Items) do
        if string.find(string.lower(v[1]), lowerInputText) then
          table.insert(UpdateItems, v)
        end
      end
    end
    SearchItems = UpdateItems
  else
    self.IsSearch = false
    if RocoEnv.IS_EDITOR then
      for i, v in ipairs(self.Items) do
        table.insert(UpdateItems, v)
        if i >= 50 then
          break
        end
      end
      SearchItems = UpdateItems
    else
      SearchItems = self.Items
    end
  end
  self:PutSortItem(SearchItems)
  self:UpdateItemInfo(SearchItems)
end

local function CharSize(ch)
  if not ch then
    return 0
  elseif ch >= 252 then
    return 6
  elseif ch >= 248 and ch < 252 then
    return 5
  elseif ch >= 240 and ch < 248 then
    return 4
  elseif ch >= 224 and ch < 240 then
    return 3
  elseif ch >= 192 and ch < 224 then
    return 2
  elseif ch < 192 then
    return 1
  end
end

local function utf8Sub(str)
  local ChChar = {}
  local currentIndex = 1
  local lastIndex = 0
  local StrLen = #str
  while currentIndex <= StrLen do
    local char = string.byte(str, currentIndex)
    local cs = CharSize(char)
    lastIndex = currentIndex
    currentIndex = currentIndex + cs
    if cs >= 3 then
      local ch = string.sub(str, lastIndex, currentIndex - 1)
      if not table.contains(ChChar, ch) then
        table.insert(ChChar, #ChChar + 1, ch)
      end
    end
  end
  return ChChar
end

function UMG_DebugPanel_C:PutSortItem(_item)
  if nil ~= _item then
    self.SearchItem = _item
  end
end

function UMG_DebugPanel_C:OnTick(InDeltaTime)
  self.SearchStartTime = self.SearchStartTime + InDeltaTime
  if self.SearchStartTime >= self.SearchEndTime and #self.CharArray <= 0 then
    self.SearchStartTime = 0
    self:SearchContent()
    _G.UpdateManager:UnRegister(self)
    if not self.StartString then
      return
    end
    if 1 == self.ConfIndex then
      JsonUtils.DumpSaved("DialogueCharSize", self.CharSizeArray)
      Log.Error("DialogueCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if 2 == self.ConfIndex then
      JsonUtils.DumpSaved("LocalizationCharSize", self.CharSizeArray)
      Log.Error("LocalizationCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if 3 == self.ConfIndex then
      JsonUtils.DumpSaved("Loading_tipsCharSize", self.CharSizeArray)
      Log.Error("Loading_tipsCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if 4 == self.ConfIndex then
      JsonUtils.DumpSaved("skillCharSize", self.CharSizeArray)
      Log.Error("skillCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if 5 == self.ConfIndex then
      JsonUtils.DumpSaved("bagitemCharSize", self.CharSizeArray)
      Log.Error("bagitemCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if 6 == self.ConfIndex then
      JsonUtils.DumpSaved("petCharSize", self.CharSizeArray)
      Log.Error("petCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if 7 == self.ConfIndex then
      JsonUtils.DumpSaved("taskCharSize", self.CharSizeArray)
      Log.Error("taskCharSize\229\175\188\229\133\165\229\174\140\230\175\149")
    end
    if self.ConfIndex < 7 then
      self.ConfIndex = self.ConfIndex + 1
      self:GetStringListSize()
    else
      self.StartString = false
    end
  end
  self.CharDeltaTime = self.CharDeltaTime + InDeltaTime
  if self.CharDeltaTime >= 0.01 then
    if self.CanRemove and #self.CharArray > 0 and self.StartString then
      for i = 1, 20 do
        self.CharItem = table.remove(self.CharArray, 1)
        self.CharTextSizeList[i]:SetText(self.CharItem)
      end
      self.CanRemove = false
    end
    if self.CharDeltaTime >= 0.06 and not self.CanRemove and self.StartString then
      for i = 1, 20 do
        local item = self.CharTextSizeList[i]:GetText()
        local font = UE4.UNRCStatics.GetStringHeightSize(item)
        if font <= 0 and item and "" ~= item and " " ~= item then
          Log.Error(item, "\229\175\188\229\133\165")
          table.insert(self.CharSizeArray, #self.CharSizeArray + 1, {
            char = item,
            AbsoluteSizeX = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self.CharTextSizeList[i]:GetCachedGeometry()).x,
            AbsoluteSizeY = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self.CharTextSizeList[i]:GetCachedGeometry()).y,
            FontSize = font
          })
        end
      end
      self.CanRemove = true
      self.CharDeltaTime = 0
    end
  end
end

function UMG_DebugPanel_C:GetStringListSize()
  local TextString = ""
  if not self.StartString then
    self.StartString = true
  end
  if 1 == self.ConfIndex then
    local dialogueConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.DIALOGUE_CONF):GetAllDatas()
    for v, k in pairs(dialogueConf) do
      if k.name then
        TextString = TextString .. k.name
      end
      if k.title then
        TextString = TextString .. k.title
      end
      if k.text then
        TextString = TextString .. k.text
      end
    end
  end
  if 2 == self.ConfIndex then
    local LocalizationConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.LOCALIZATION_CONF):GetAllDatas()
    for v, k in pairs(LocalizationConf) do
      if k.msg then
        TextString = TextString .. k.msg
      end
    end
  end
  if 3 == self.ConfIndex then
    local LoadingConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.LOADING_TIPS_CONF):GetAllDatas()
    for v, k in pairs(LoadingConf) do
      if k.loading_tips_title then
        TextString = TextString .. k.loading_tips_title
      end
      if k.loading_tips_text then
        TextString = TextString .. k.loading_tips_text
      end
    end
  end
  if 4 == self.ConfIndex then
    local SkillConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
    for v, k in pairs(SkillConf) do
      if k.name then
        TextString = TextString .. k.name
      end
      if k.desc then
        TextString = TextString .. k.desc
      end
    end
  end
  if 5 == self.ConfIndex then
    local BagItemConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BAG_ITEM_CONF):GetAllDatas()
    for v, k in pairs(BagItemConf) do
      if k.name then
        TextString = TextString .. k.name
      end
      if k.description then
        TextString = TextString .. k.description
      end
      if k.type_desc then
        TextString = TextString .. k.type_desc
      end
      local acquire_struct = k.acquire_struct
      for i = 1, #acquire_struct do
        if acquire_struct[i].acquire_way_text then
          TextString = TextString .. acquire_struct[i].acquire_way_text
        end
      end
    end
  end
  if 6 == self.ConfIndex then
    local petConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_CONF):GetAllDatas()
    for v, k in pairs(petConf) do
      if k.name then
        TextString = TextString .. k.name
      end
    end
  end
  if 7 == self.ConfIndex then
    local TaskConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.TASK_CONF):GetAllDatas()
    for v, k in pairs(TaskConf) do
      if k.name then
        TextString = TextString .. k.name
      end
      if k.task_des then
        TextString = TextString .. k.task_des
      end
      if k.belong_place then
        TextString = TextString .. k.belong_place
      end
      if k.rewrite then
        TextString = TextString .. k.rewrite
      end
      local task_condition = k.task_condition
      for i = 1, #task_condition do
        if task_condition[i].text then
          TextString = TextString .. task_condition[i].text
        end
      end
    end
  end
  local ChChars = utf8Sub(TextString)
  self.CharArray = ChChars
  self.CanRemove = true
  table.clear(self.CharSizeArray)
  _G.UpdateManager:Register(self)
end

function UMG_DebugPanel_C:OnSearch()
  local InputText = self:GetInputFrameString()
  local SearchItems
  local UpdateItems = {}
  if "" ~= InputText then
    for i, v in ipairs(self.Items) do
      if string.find(v[1], InputText) then
        table.insert(UpdateItems, v)
      end
    end
    SearchItems = UpdateItems
  else
    SearchItems = self.Items
  end
  self:UpdateItemInfo(SearchItems)
end

function UMG_DebugPanel_C:OnClickSearchButtonBox()
  local InputText = self:GetInputString()
  if not string.IsNilOrEmpty(self.SecondTabName) then
    if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][1] then
      self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][2] = InputText
    end
  elseif self.LockSeting[self.CurrentTabName][self.BoxLockStat][1] then
    self.LockSeting[self.CurrentTabName][self.BoxLockStat][2] = InputText
  end
end

function UMG_DebugPanel_C:OnClickTextCommitted()
  local InputText = self:GetInputFrameString()
  self:UpdateSearch(self.InputFrameName)
end

function UMG_DebugPanel_C:SetInputInfo(Text)
  if Text.InputName == self.InputBoxName then
    self.InputBox:SetText(Text.name)
    self.DebugDropDownList:SetScrollVisible(false)
  else
    if not string.IsNilOrEmpty(self.SecondTabName) then
      if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] then
        self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][2] = self:GetInputFrameString()
      end
    elseif self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
      self.LockSeting[self.CurrentTabName][self.FrameLockStat][2] = self:GetInputFrameString()
    end
    if Text.NewInstruction then
      local Instruction = {}
      local Range = Text.NewInstruction
      table.insert(Instruction, Text)
      if "\232\129\140\232\131\189\229\143\130\230\149\176" == Range then
        self.DebugDropDownList_1.ShowSelectedItem:InitGridView(Instruction)
      elseif "\228\189\191\231\148\168\229\143\130\230\149\176" == Range then
        self.DebugDropDownList_2.ShowSelectedItem:InitGridView(Instruction)
      elseif "\230\179\155\231\148\168\230\140\135\228\187\164" == Range then
        self.DebugDropDownList_3.ShowSelectedItem:InitGridView(Instruction)
      end
    else
      self.InputFrame:SetText(Text.name)
    end
    self.DebugDropDownListTest:SetScrollVisible(false)
  end
end

function UMG_DebugPanel_C:SetInstructionInfo(Text)
  local Instruction, UseType, Order
  if Text.NewInstruction == "\232\129\140\232\131\189\229\143\130\230\149\176" then
    Instruction = Text
    self:SearchInstructionTab(Instruction)
  elseif Text.NewInstruction == "\228\189\191\231\148\168\229\143\130\230\149\176" then
    UseType = Text
    self:SearchUseTypeTab(UseType)
  elseif Text.NewInstruction == "\230\179\155\231\148\168\230\140\135\228\187\164" then
    Order = Text
    self:SearchOrder(Order)
  end
  self.DebugDropDownList_1:SetScrollVisible(false)
  self.DebugDropDownList_2:SetScrollVisible(false)
  self.DebugDropDownList_3:SetScrollVisible(false)
end

function UMG_DebugPanel_C:OnDestruct()
  self.NRCGridView_32:Clear()
  self.GridView_CheckBox:Clear()
  for i = 0, self.CategoryList:GetChildrenCount() - 1 do
    local Child = self.CategoryList:GetChildAt(i)
    Child = Child and nil
  end
  self.CategoryList:ClearChildren()
  for i = 0, self.SecondCategoryList:GetChildrenCount() - 1 do
    local Child = self.SecondCategoryList:GetChildAt(i)
    Child = Child and nil
  end
  self.SecondCategoryList:ClearChildren()
  if type(self.UsageInfo) == "table" then
    JsonUtils.DumpSaved("DebugTab", self.UsageInfo)
  else
    Log.Error("\228\191\157\229\173\152UsageInfo\229\164\177\232\180\165,\228\188\160\229\133\165\231\154\132\230\149\176\230\141\174\228\184\141\228\184\186table")
    Log.Dump(self.UsageInfo, 5, "Wrong UsageInfo")
  end
  if "table" == type(self.SearchInfo) then
    JsonUtils.DumpSaved("SearchTab", self.SearchInfo)
  else
    Log.Error("\228\191\157\229\173\152SearchInfo\229\164\177\232\180\165,\228\188\160\229\133\165\231\154\132\230\149\176\230\141\174\228\184\141\228\184\186table")
    Log.Dump(self.SearchInfo, 5, "Wrong SearchInfo")
  end
  if "table" == type(self.LockSeting) then
    JsonUtils.DumpSaved("LockSet", self.LockSeting)
  else
    Log.Error("\228\191\157\229\173\152LockSeting\229\164\177\232\180\165,\228\188\160\229\133\165\231\154\132\230\149\176\230\141\174\228\184\141\228\184\186table")
    Log.Dump(self.LockSeting, 5, "Wrong LockSeting")
  end
  _G.NRCSDKManager:PerfEndExclude("DebugPanel")
  _G.NRCSDKManager:PerfEndMark("DebugPanel")
  _G.UpdateManager:UnRegister(self)
end

function UMG_DebugPanel_C:OnActive(args)
  self.excelRecord = {}
  self.excelRecordMap = {}
  self:SetupTabs()
  self:SortTabs()
  self:SetSearchTabs()
  self:SetlockImage()
  self:RefreshList()
  _G.UpdateManager:UnRegister(self)
  self.args = args
  self:DelayFrames(2, self.FirstSetCategory, self)
  UE4Helper.SetDesiredShowCursor(true, "UMG_DebugPanel_C")
end

function UMG_DebugPanel_C:FirstSetCategory()
  local FirstItem
  if self.MostUse and #self.MostUse > 0 then
    FirstItem = self.MostUse[1][1]
  else
    FirstItem = self.Categories[1][1]
  end
  self:SetCategory(FirstItem)
  if self.args then
    self:FindBindKeyBoard(self.args)
  end
end

function UMG_DebugPanel_C:DeleteFileEvent()
  self:SortTabs()
  self:SetSearchTabs()
  self:SetlockImage()
end

function UMG_DebugPanel_C:SortTabs()
  self.UsageInfo = JsonUtils.LoadSaved("DebugTab", {
    ["\230\148\182\232\151\143\233\161\181\231\173\190"] = 9999
  })
  local Collect = "\230\148\182\232\151\143\233\161\181\231\173\190"
  if type(self.UsageInfo) == "table" then
    if self.UsageInfo then
      self.UsageInfo[Collect] = 9999
    end
  else
    JsonUtils.DeleteFile("DebugTab")
    Log.Error("\230\150\135\228\187\182\229\143\151\230\141\159\239\188\140\229\183\178\232\135\170\229\138\168\229\136\160\233\153\164\239\188\140\233\186\187\231\131\166\233\135\141\230\150\176\229\144\175\229\138\168\229\141\179\229\143\175")
    self.UsageInfo = {
      ["\230\148\182\232\151\143\233\161\181\231\173\190"] = 9999
    }
  end
  for Index, Category in ipairs(self.Categories) do
    local Name = Category[1]
    local Found = self.UsageInfo[Name]
    if not Found then
      self.UsageInfo[Name] = 0
    end
    self.OriginalOrder[Name] = Index
  end
  
  local function Comparator(Cat1, Cat2)
    local Name1 = Cat1[1]
    local Name2 = Cat2[1]
    local Count1 = self.UsageInfo[Name1]
    local Count2 = self.UsageInfo[Name2]
    if Count1 ~= Count2 then
      return Count1 > Count2
    else
      local OriOrder1 = self.OriginalOrder[Name1]
      local OriOrder2 = self.OriginalOrder[Name2]
      return OriOrder1 < OriOrder2
    end
  end
  
  local Duplicated = {}
  for _, v in ipairs(self.Categories) do
    table.insert(Duplicated, v)
  end
  table.sort(Duplicated, Comparator)
  for i = 1, 6 do
    local Sorted = Duplicated[i]
    if 0 == self.UsageInfo[Sorted[1]] then
      break
    end
    table.insert(self.MostUse, i, Sorted)
  end
end

function UMG_DebugPanel_C:SetSearchTabs()
  self.SearchInfo = JsonUtils.LoadSaved("SearchTab", {})
  if type(self.SearchInfo) ~= "table" then
    JsonUtils.DeleteFile("SearchTab")
    Log.Error("\230\150\135\228\187\182\229\143\151\230\141\159\239\188\140\229\183\178\232\135\170\229\138\168\229\136\160\233\153\164\239\188\140\233\186\187\231\131\166\233\135\141\230\150\176\229\144\175\229\138\168\229\141\179\229\143\175")
    self:DoClose()
    return
  end
  for Index, Category in ipairs(self.Categories) do
    local Name = Category[1]
    local Found = self.SearchInfo[Name]
    if not Found then
      self.SearchInfo[Name] = {}
      self.SearchInfo[Name][self.InputBoxName] = {}
      self.SearchInfo[Name][self.InputFrameName] = {}
    end
    if Category.SecondTabInfo and #Category.SecondTabInfo > 0 then
      for SecondIndex, SecondCategory in ipairs(Category.SecondTabInfo) do
        local SecondName = SecondCategory[1]
        local SecondFound = self.SearchInfo[Name][SecondName]
        if not SecondFound then
          self.SearchInfo[Name][SecondName] = {}
          self.SearchInfo[Name][SecondName][self.InputBoxName] = {}
          self.SearchInfo[Name][SecondName][self.InputFrameName] = {}
        end
      end
    end
  end
end

function UMG_DebugPanel_C:SortSearchTabs(InputName)
  if string.IsNilOrEmpty(self.CurrentTabName) then
    return
  end
  local SearchInfo = self.SearchInfo
  local FirstTabInfo = self.SearchInfo[self.CurrentTabName]
  local Duplicated = {}
  local MostUse = {}
  local SortByi = 0
  if string.IsNilOrEmpty(self.SecondTabName) then
    if string.IsNilOrEmpty(FirstTabInfo[InputName]) then
      self.SearchInfo[self.CurrentTabName][InputName] = {}
    end
    for name, v in pairs(FirstTabInfo[InputName]) do
      if v and type(v) == "table" then
        SortByi = SortByi + 1
        table.insert(Duplicated, {
          name = name,
          num = v[1] or 0,
          InputName = InputName,
          SortByi = SortByi,
          time = v[2]
        })
      end
    end
  else
    local SecondTabInfo = self.SearchInfo[self.CurrentTabName][self.SecondTabName]
    if string.IsNilOrEmpty(SecondTabInfo[InputName]) then
      self.SearchInfo[self.CurrentTabName][self.SecondTabName][InputName] = {}
    end
    for name, v in pairs(SecondTabInfo[InputName]) do
      if v and type(v) == "table" then
        SortByi = SortByi + 1
        table.insert(Duplicated, {
          name = name,
          num = v[1] or 0,
          InputName = InputName,
          SortByi = SortByi,
          time = v[2]
        })
      end
    end
  end
  table.sort(Duplicated, function(a, b)
    if a.time > b.time then
      return a.time > b.time
    end
  end)
  for i = 1, 10 do
    local Sorted = Duplicated[i]
    if Sorted then
      table.insert(MostUse, Sorted)
    end
  end
  if InputName == self.InputBoxName then
    self.DebugDropDownList:OnActive(MostUse)
  else
    self.DebugDropDownListTest:OnActive(MostUse)
  end
end

function UMG_DebugPanel_C:CreateLabel(Name)
  local Path = "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugLabel"
  local LabelWidget = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), _G.NRCResourceManager:LoadForDebugOnly(Path))
  LabelWidget.Label:SetText(Name)
  return LabelWidget
end

function UMG_DebugPanel_C:RefreshList()
  local Count = 0
  if #self.MostUse > 0 then
    Count = Count + 1
    local MostUseLabel = self:CreateLabel("\229\184\184\231\148\168\233\161\181\231\173\190")
    self.CategoryList:AddChild(MostUseLabel)
    for _, v in ipairs(self.MostUse) do
      local Child = self.CategoryList:GetChildAt(Count)
      if not Child then
        Child = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), _G.NRCResourceManager:LoadForDebugOnly("/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugButton"))
        self.CategoryList:AddChild(Child)
      end
      Child.Panel = self
      Child:Refresh(v[1], self.SetCategory, self)
      Count = Count + 1
    end
    Count = Count + 1
    local AllLabel = self:CreateLabel("\230\137\128\230\156\137\233\161\181\231\173\190")
    self.CategoryList:AddChild(AllLabel)
  end
  for _, v in ipairs(self.Categories) do
    local Child = self.CategoryList:GetChildAt(Count)
    if not Child then
      Child = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), _G.NRCResourceManager:LoadForDebugOnly("/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugButton"))
      self.CategoryList:AddChild(Child)
    end
    Child.Panel = self
    Child:Refresh(v[1], self.SetCategory, self)
    Count = Count + 1
  end
end

function UMG_DebugPanel_C:RefreshSecondList()
  self.SecondCategoryList:ClearChildren()
  local Count = 0
  for _, v in ipairs(self.SecondTabCategories) do
    local Child = self.SecondCategoryList:GetChildAt(Count)
    if not Child then
      Child = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), _G.NRCResourceManager:LoadForDebugOnly("/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugButton"))
      self.SecondCategoryList:AddChild(Child)
    end
    Child.Panel = self
    Child:Refresh(v[1], self.SetSecondCategory, self)
    Count = Count + 1
  end
end

function UMG_DebugPanel_C:SetSecondCategory(name)
  self:SetInputFrameString()
  self.SecondTabCategoriesInfo = nil
  if self.SecondTabName == name then
    return
  end
  self.SecondTabName = name
  local Cat = self:GetCategoryPath(name, self.SecondTabCategories)
  if not Cat then
    return
  end
  local TabBase = self.module.data:GetTabDataFromCache(Cat)
  self.Items = TabBase.items
  self.Options = TabBase.options
  TabBase.Panel = self
  if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][1] then
    self.InputBoxLockSwitcher:SetActiveWidgetIndex(0)
    self.InputBox:SetText(self.LockSeting[self.CurrentTabName][self.SecondTabName][self.BoxLockStat][2])
  else
    self.InputBoxLockSwitcher:SetActiveWidgetIndex(1)
    self.InputBox:SetText("")
  end
  if self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] then
    self.InputFrameLockSwitcher:SetActiveWidgetIndex(0)
    self.InputFrame:SetText(self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][2])
  else
    self.InputFrameLockSwitcher:SetActiveWidgetIndex(1)
    self.InputFrame:SetText("")
  end
  self:OnSearch()
end

function UMG_DebugPanel_C:GetCategoryPath(name, _TabType)
  local TabType = _TabType
  for _, v in ipairs(TabType) do
    if not name then
      return v[2]
    end
    if v[1] == name then
      if v.SecondTabInfo and #v.SecondTabInfo > 0 then
        return v.SecondTabInfo[1][2]
      end
      return v[2]
    end
  end
  return nil
end

function UMG_DebugPanel_C:GetCategoryPathOptimization(name, Categories, subTabName)
  local FirstTabIndex = self.CategoriesMap[name]
  if FirstTabIndex then
    local FirstTabInfo = self.Categories[FirstTabIndex]
    if FirstTabInfo.SecondTabInfo and #FirstTabInfo.SecondTabInfo > 0 then
      if subTabName then
        for _, v in ipairs(FirstTabInfo.SecondTabInfo) do
          if v[1] == subTabName then
            return v[2]
          end
        end
      else
        return FirstTabInfo.SecondTabInfo[1][2]
      end
    end
    return FirstTabInfo[2]
  end
  return nil
end

function UMG_DebugPanel_C:IsHasSecondTab(name)
  local FirstTabIndex = self.CategoriesMap[name]
  if FirstTabIndex then
    local FirstTabInfo = self.Categories[FirstTabIndex]
    if FirstTabInfo.SecondTabInfo and #FirstTabInfo.SecondTabInfo > 0 then
      return FirstTabInfo.SecondTabInfo
    end
  end
  return nil
end

function UMG_DebugPanel_C:SetCategory(name)
  if "\230\148\182\232\151\143\233\161\181\231\173\190" == name then
    self.SecondCategoryList:ClearChildren()
    self.SecondTabName = nil
    self.Button_Collect.Caption:SetText("\231\167\187\233\153\164\230\148\182\232\151\143")
    self.CollectSateText = name
    self.NRCGridView_32:SetStandCol1280(8)
    self.NRCGridView_32:SetStandCol(8)
  else
    self.Button_Collect.Caption:SetText("\230\183\187\229\138\160\230\148\182\232\151\143")
    self.CollectSateText = name
  end
  if "\229\133\168\229\177\128\230\144\156\231\180\162" == name and not self.isFirstOpenSearch then
    self.isOpenExcelRecordFlag = true
    self:SetupTabs()
    self.isOpenExcelRecordFlag = false
    self.isFirstOpenSearch = true
  end
  if "\229\142\134\229\143\178" == name then
    self.SecondCategoryList:ClearChildren()
    self.SecondTabName = nil
    self.Button_ClearHistory.Caption:SetText("\229\188\128\229\144\175\230\184\133\233\153\164\229\142\134\229\143\178")
    self.CollectSateText = name
    self.Button_ClearHistory:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CollectSateText = name
    self.Button_ClearHistory:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self:SetInputFrameString()
  local Cat = self:GetCategoryPathOptimization(name, self.Categories)
  if not Cat then
    return
  end
  if self.CurrentTabName == name then
    return
  end
  self.CurrentTabName = name
  if "NewRoco.Modules.System.Debug.Tabs.DebugTabCollect" == Cat then
    self.ButtonInfo = JsonUtils.LoadSaved("DebugTabCollect", {})
    local ButtonInfos = self.ButtonInfo
    local ButtonMode = {}
    for i = 1, #ButtonInfos do
      local InnerButtonInfos = ButtonInfos[i]
      local TabBase = self.module.data:GetTabDataFromCache(InnerButtonInfos[1])
      if self:CheckGMCommandIfIsPath(InnerButtonInfos[1]) then
        for j = 2, #InnerButtonInfos do
          table.insert(ButtonMode, {
            InnerButtonInfos[j]
          })
          local item = TabBase.itemsMap[InnerButtonInfos[j]]
          TabBase.Panel = self
          if item then
            table.insert(ButtonMode[#ButtonMode], item[2])
          end
          table.insert(ButtonMode[#ButtonMode], TabBase)
        end
        if ButtonInfos[i][1] then
          ButtonMode[#ButtonMode].LuaFilePath = ButtonInfos[i][1]
        end
      else
        local function CommandFunc()
          NRCModuleManager:DoCmd(_G.DebugModuleCmd.ExecGMGroup, InnerButtonInfos[1])
        end
        
        table.insert(ButtonMode, {
          InnerButtonInfos[2]
        })
        table.insert(ButtonMode[#ButtonMode], CommandFunc)
        table.insert(ButtonMode[#ButtonMode], self)
        ButtonMode[#ButtonMode].GMCommandGroupName = InnerButtonInfos[1]
      end
    end
    self.Items = ButtonMode
    self.NRCGridView_32:InitGridView(ButtonMode)
    if self.LockSeting[self.CurrentTabName][self.BoxLockStat][1] then
      self.InputBoxLockSwitcher:SetActiveWidgetIndex(0)
      self.InputBox:SetText(self.LockSeting[self.CurrentTabName][self.BoxLockStat][2])
    else
      self.InputBoxLockSwitcher:SetActiveWidgetIndex(1)
      self.InputBox:SetText("")
    end
    if self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
      self.InputFrameLockSwitcher:SetActiveWidgetIndex(0)
      self.InputFrame:SetText(self.LockSeting[self.CurrentTabName][self.FrameLockStat][2])
    else
      self.InputFrameLockSwitcher:SetActiveWidgetIndex(1)
      self.InputFrame:SetText("")
    end
    return
  end
  local SecondCat = self:IsHasSecondTab(name)
  if SecondCat then
    Cat = SecondCat[1][2]
    self.SecondTabName = SecondCat[1][1]
    self.SecondTabCategories = SecondCat
  else
    self.SecondTabName = nil
    self.SecondTabCategories = {}
  end
  self:RefreshSecondList()
  self:FirstSetSecondCategory()
  local TabBase = self.module.data:GetTabDataFromCache(Cat)
  self.Items = TabBase.items
  self.Options = TabBase.options
  TabBase.Panel = self
  if self.LockSeting[self.CurrentTabName][self.BoxLockStat][1] then
    self.InputBoxLockSwitcher:SetActiveWidgetIndex(0)
    self.InputBox:SetText(self.LockSeting[self.CurrentTabName][self.BoxLockStat][2])
  else
    self.InputBoxLockSwitcher:SetActiveWidgetIndex(1)
    self.InputBox:SetText("")
  end
  if self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
    self.InputFrameLockSwitcher:SetActiveWidgetIndex(0)
    self.InputFrame:SetText(self.LockSeting[self.CurrentTabName][self.FrameLockStat][2])
  else
    self.InputFrameLockSwitcher:SetActiveWidgetIndex(1)
    self.InputFrame:SetText("")
  end
  self:OnSearch()
end

function UMG_DebugPanel_C:CheckGMCommandIfIsPath(command)
  local commandParts = {}
  for part in string.gmatch(command, "%S+") do
    table.insert(commandParts, part)
  end
  if "gm" == commandParts[1] then
    return false
  else
    return true
  end
end

function UMG_DebugPanel_C:UpdateItemInfo(_Items, _MaxButtonNum)
  self.ButtonInfo = nil
  local Items = _Items
  local ItemPerRow
  local CategoryListSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self.CategoryList:GetCachedGeometry())
  local ViewportSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(self.DarkPlane:GetCachedGeometry())
  local ViewportScale = UE4.UWidgetLayoutLibrary.GetViewportScale(_G.UE4Helper.GetCurrentWorld())
  local ButtonNum
  if self.SecondTabName then
    if self.CurrentSecondTabName then
      ItemPerRow = math.ceil((ViewportSize.X - CategoryListSize.X) / (152 * ViewportScale))
    else
      ItemPerRow = math.ceil((ViewportSize.X - CategoryListSize.X - CategoryListSize.X) / (152 * ViewportScale))
    end
  elseif self.CurrentSecondTabName then
    ItemPerRow = math.ceil(ViewportSize.X / (152 * ViewportScale))
  else
    ItemPerRow = math.ceil((ViewportSize.X - CategoryListSize.X) / (152 * ViewportScale))
  end
  self.CurrentSecondTabName = self.SecondTabName
  local GridChildren = {}
  self.NRCGridView_32:Clear()
  Log.Warning("CurrentTabName:", self.CurrentTabName)
  if Items then
    local GridItems = {}
    if #Items > 75 and self.CurrentTabName ~= "\230\156\141\229\138\161\229\153\168GM" then
      Log.Error("\233\161\181\231\173\190\230\149\176\230\141\174\233\135\143\229\164\170\229\164\167\239\188\140\229\176\134\228\188\154\232\191\155\232\161\140\233\153\144\229\136\182", self.CurrentTabName, self.SecondTabName, #Items)
      Log.Error("\230\144\156\231\180\162\229\138\159\232\131\189\229\143\175\228\187\165\230\173\163\229\184\184\228\189\191\231\148\168\239\188\140\232\175\183\228\189\191\231\148\168\230\144\156\231\180\162\229\138\159\232\131\189")
    end
    if nil ~= self.CurrentSecondTabName then
      ButtonNum = 70
      self.NRCGridView_32:SetStandCol1280(7)
      self.NRCGridView_32:SetStandCol(7)
    else
      ButtonNum = 72
      self.NRCGridView_32:SetStandCol1280(8)
      self.NRCGridView_32:SetStandCol(8)
    end
    if nil ~= _MaxButtonNum and _MaxButtonNum > 0 then
      ButtonNum = _MaxButtonNum
    elseif nil == _MaxButtonNum and self.CurrentTabName == "\230\156\141\229\138\161\229\153\168GM" then
      ButtonNum = 200
    end
    for i = 1, math.min(#Items, ButtonNum) do
      local Data = Items[i]
      table.insert(GridItems, #GridItems + 1, {
        Data[1],
        function(_, ...)
          Data[2](Data[3], ...)
          self:UpdateUsage()
          self:UpdateSearch(self.InputBoxName)
        end,
        self,
        self:JudgeCollectState(),
        Data[5],
        Data[6],
        Data[7],
        Data[8]
      })
      if Data.LuaFileName then
        GridItems[i].LuaFileName = Data.LuaFileName
      end
      if Data.LuaFilePath then
        GridItems[i].LuaFilePath = Data.LuaFilePath
      end
      if Data.GMCommandGroupName then
        GridItems[i].GMCommandGroupName = Data.GMCommandGroupName
      end
    end
    if self.CurrentTabName ~= "\230\148\182\232\151\143" and (nil ~= self.Instruction or nil ~= self.Order or nil ~= self.UseType) then
      GridItems = self:SortTabInfo(self.Instruction, self.UseType, self.Order)
    end
    self.NRCGridView_32:InitGridView(GridItems)
    table.clear(GridItems)
    self:SortSearchTabs(self.InputBoxName)
    self:SortSearchTabs(self.InputFrameName)
  end
  self.GridView_CheckBox:Clear()
  if self.Options and self.Options.optionData then
    self.GridView_CheckBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local GridItems = {}
    for k, v in pairs(self.Options.optionData) do
      table.insert(GridItems, #GridItems + 1, {
        k,
        v,
        self.Options.callbackOwner,
        self.Options.onCheckStateChangedCallback
      })
    end
    self.GridView_CheckBox:InitGridView(GridItems)
  else
    self.GridView_CheckBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  table.clear(GridChildren)
end

function UMG_DebugPanel_C:FirstSetSecondCategory()
  local FirstItem
  if self.SecondTabCategories and #self.SecondTabCategories > 0 then
    FirstItem = self.SecondTabCategories[1][1]
  end
  self:SetSecondCategory(FirstItem)
end

function UMG_DebugPanel_C:UpdateUsage()
  if string.IsNilOrEmpty(self.CurrentTabName) then
    return
  end
  local Count = self.UsageInfo[self.CurrentTabName] or 0
  self.UsageInfo[self.CurrentTabName] = Count + 1
end

function UMG_DebugPanel_C:UpdateSearch(InputName)
  local time = os.time()
  if string.IsNilOrEmpty(self.CurrentTabName) then
    return
  end
  local InputString
  if InputName == self.InputBoxName then
    InputString = self:GetInputString()
  else
    InputString = self:GetInputFrameString()
  end
  if string.IsNilOrEmpty(InputString) then
    return
  end
  local FirstTabInfo = self.SearchInfo[self.CurrentTabName]
  if string.IsNilOrEmpty(self.SecondTabName) then
    if string.IsNilOrEmpty(FirstTabInfo[InputName]) then
      self.SearchInfo[self.CurrentTabName][InputName] = {}
    end
    local Found = FirstTabInfo[InputName][InputString]
    if not Found then
      self.SearchInfo[self.CurrentTabName][InputName][InputString] = {1, time}
    elseif type(self.SearchInfo[self.CurrentTabName][InputName][InputString]) == "number" then
      self.SearchInfo[self.CurrentTabName][InputName][InputString] = {1, time}
    else
      local Count = self.SearchInfo[self.CurrentTabName][InputName][InputString][1] or 1
      self.SearchInfo[self.CurrentTabName][InputName][InputString][1] = Count + 1
      self.SearchInfo[self.CurrentTabName][InputName][InputString][2] = time
    end
  else
    local SecondTabInfo = self.SearchInfo[self.CurrentTabName][self.SecondTabName]
    if string.IsNilOrEmpty(SecondTabInfo[InputName]) then
      self.SearchInfo[self.CurrentTabName][self.SecondTabName][InputName] = {}
    end
    local Found = SecondTabInfo[InputName][InputString]
    if not Found then
      self.SearchInfo[self.CurrentTabName][self.SecondTabName][InputName][InputString] = {1, time}
    else
      local Count = self.SearchInfo[self.CurrentTabName][self.SecondTabName][InputName][InputString][1] or 1
      self.SearchInfo[self.CurrentTabName][self.SecondTabName][InputName][InputString][1] = Count + 1
      self.SearchInfo[self.CurrentTabName][self.SecondTabName][InputName][InputString][2] = time
    end
  end
end

function UMG_DebugPanel_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_DebugPanel_C")
end

function UMG_DebugPanel_C:GetInputNumber(Default, BTonumber)
  Default = Default or 0
  if self.isshowabbrevia then
    if BTonumber then
      return self.AbbreInputBox:GetText() or Default
    else
      return tonumber(self.AbbreInputBox:GetText()) or Default
    end
  elseif BTonumber then
    return self.InputBox:GetText() or Default
  else
    return tonumber(self.InputBox:GetText()) or Default
  end
end

function UMG_DebugPanel_C:GetInputNumbers()
  local Raw = self:GetInputString()
  if string.IsNilOrEmpty(Raw) then
    return {}
  end
  local Texts = string.split(Raw, ",")
  for i = 1, #Texts do
    Texts[i] = tonumber(Texts[i])
  end
  return Texts
end

function UMG_DebugPanel_C:GetInputString()
  if self.isshowabbrevia then
    return self.AbbreInputBox:GetText()
  else
    return self.InputBox:GetText()
  end
end

function UMG_DebugPanel_C:GetInputFrameNumber(Default)
  Default = Default or 0
  return tonumber(self.InputFrame:GetText()) or Default
end

function UMG_DebugPanel_C:GetInputFrameString()
  return self.InputFrame:GetText()
end

function UMG_DebugPanel_C:SetInputFrameString()
  if string.IsNilOrEmpty(self.CurrentTabName) then
    self.InputFrame:SetText("")
    return
  end
  if not string.IsNilOrEmpty(self.SecondTabName) then
    if not self.LockSeting[self.CurrentTabName][self.SecondTabName][self.FrameLockStat][1] then
      self.InputFrame:SetText("")
    end
  elseif not self.LockSeting[self.CurrentTabName][self.FrameLockStat][1] then
    self.InputFrame:SetText("")
  end
end

function UMG_DebugPanel_C:AddCategory(name, path, SecondTabName, writeIntoConfig)
  if self.isOpenExcelRecordFlag then
    local TabBase = reload(path)()
    TabBase.Panel = self
    if #TabBase.items > 0 then
      local nameFindFlag = false
      local index = 0
      if false ~= writeIntoConfig then
        if self.excelRecordMap[name] then
          index = self.excelRecordMap[name]
          nameFindFlag = true
        else
          table.insert(self.excelRecord, {name = name})
          index = #self.excelRecord
          self.excelRecordMap[name] = index
        end
      end
      local LuaFileName = path
      TabBase.items.LuaFileName = LuaFileName
      if false ~= writeIntoConfig then
        if SecondTabName then
          table.insert(self.excelRecord[index], {
            SecondTabName = SecondTabName,
            tabItem = TabBase.items
          })
          table.insert(self.AllLabel, {
            path,
            name .. "-" .. SecondTabName,
            TabBase.items
          })
          self.excelRecord[index].hasSecondTab = true
        else
          self.excelRecord[index].tabItem = TabBase.items
          table.insert(self.AllLabel, {
            path,
            name,
            TabBase.items
          })
          self.excelRecord[index].hasSecondTab = false
        end
      end
    end
  elseif SecondTabName then
    local index = self.CategoriesMap[name]
    if index then
      local categories = self.Categories[index]
      table.insert(categories.SecondTabInfo, {SecondTabName, path})
    else
      table.insert(self.Categories, {
        name,
        path,
        SecondTabInfo = {
          {SecondTabName, path}
        }
      })
      self.CategoriesMap[name] = #self.Categories
    end
  else
    table.insert(self.Categories, {name, path})
    self.CategoriesMap[name] = #self.Categories
  end
end

function UMG_DebugPanel_C:FindBindKeyBoard(args)
  local ShortcutKeyName = args
  local CategoriesType = self.Categories
  local IsGoFidSecondTab, IsGoFid
  for i, CategoriesPath in ipairs(CategoriesType) do
    local SecondTabPath
    if CategoriesPath.SecondTabInfo then
      for _, SecondTab in ipairs(CategoriesPath.SecondTabInfo) do
        SecondTabPath = SecondTab[2]
        if SecondTabPath then
          IsGoFidSecondTab = self:IsHasBindKey(ShortcutKeyName, SecondTabPath)
          if IsGoFidSecondTab then
            goto lbl_46
          end
        end
      end
    end
    local LoadPath = CategoriesPath[2]
    if nil == SecondTabPath and LoadPath then
      IsGoFid = self:IsHasBindKey(ShortcutKeyName, LoadPath)
      if IsGoFid then
        goto lbl_46
      end
    end
  end
  ::lbl_46::
end

function UMG_DebugPanel_C:IsHasBindKey(_ShortcutKeyName, _LoadPath)
  local ShortcutKeyName = _ShortcutKeyName
  local LoadPath = _LoadPath
  local TabBase = self.module.data:GetTabDataFromCache(LoadPath)
  TabBase.Panel = self
  for j, BaseList in ipairs(TabBase.items) do
    local BaseListShortcutKeyName = BaseList[4]
    if BaseListShortcutKeyName and ShortcutKeyName and BaseListShortcutKeyName == ShortcutKeyName then
      BaseList[2](BaseList[3], BaseList[1], self)
      return true
    end
  end
  return false
end

function UMG_DebugPanel_C:AddCollect()
  local Items = self.Items
  local SearchItem = self.SearchItem
  if self.CollectSateText ~= "\230\148\182\232\151\143\233\161\181\231\173\190" then
    self.CancelCollect = false
    if self.IsCollect then
      if self.CollectSateText == "\229\142\134\229\143\178" then
        self.Button_ClearHistory:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        Items = self:UpdateHistoryInfo()
      end
      self.Button_Collect.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("000000FF"))
      self.IsCollect = false
      if self.IsSearch and SearchItem then
        self:UpdateItemInfo(SearchItem)
      else
        self:UpdateItemInfo(Items)
      end
    else
      if self.CollectSateText == "\229\142\134\229\143\178" then
        self.Button_ClearHistory:SetVisibility(UE4.ESlateVisibility.Hidden)
        Items = self:UpdateHistoryInfo()
      end
      self.Button_Collect.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
      self.IsCollect = true
      if self.IsSearch and SearchItem then
        self:UpdateItemInfo(SearchItem)
      else
        self:UpdateItemInfo(Items)
      end
    end
  else
    self.IsCollect = false
    if self.CancelCollect then
      self.Button_Collect.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("000000FF"))
      self.CancelCollect = false
      Items = self:UpdateCollectInfo()
      self:UpdateItemInfo(Items)
    else
      self.Button_Collect.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
      self.CancelCollect = true
      Items = self:UpdateCollectInfo()
      self:UpdateItemInfo(Items)
    end
  end
end

function UMG_DebugPanel_C:ClearSelectedHistory()
  local Items = self.Items
  self.IsHistory = false
  if self.CancelHistory then
    self.Button_ClearHistory.Caption:SetText("\229\188\128\229\144\175\230\184\133\233\153\164\229\142\134\229\143\178")
    self.Button_Collect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Button_ClearHistory.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("000000FF"))
    self.CancelHistory = false
    Items = self:UpdateHistoryInfo()
    self:UpdateItemInfo(Items)
  else
    self.Button_ClearHistory.Caption:SetText("\230\184\133\233\153\164\233\128\137\228\184\173\229\142\134\229\143\178")
    self.Button_Collect:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Button_ClearHistory.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
    self.CancelHistory = true
    Items = self:UpdateHistoryInfo()
    self:UpdateItemInfo(Items)
  end
end

function UMG_DebugPanel_C:RefreshHistory()
  local Items = self.Items
  local ButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
  local ButtonMode = {}
  for i = 1, #ButtonInfos do
    local InnerButtonInfos = ButtonInfos[i]
    if self:CheckGMCommandIfIsPath(InnerButtonInfos[1]) then
      for j = 2, #InnerButtonInfos do
        table.insert(ButtonMode, {
          InnerButtonInfos[j]
        })
        local TabBase = self.module.data:GetTabDataFromCache(InnerButtonInfos[1])
        self.Items = TabBase.items
        self.Options = TabBase.options
        TabBase.Panel = self
        local item = TabBase.itemsMap[InnerButtonInfos[j]]
        if item then
          table.insert(ButtonMode[#ButtonMode], item[2])
        end
        table.insert(ButtonMode[#ButtonMode], TabBase)
        ButtonMode[#ButtonMode].LuaFilePath = InnerButtonInfos[1]
      end
    else
      local function CommandFunc()
        NRCModuleManager:DoCmd(_G.DebugModuleCmd.ExecGMGroup, InnerButtonInfos[1])
      end
      
      table.insert(ButtonMode, {
        InnerButtonInfos[2]
      })
      table.insert(ButtonMode[#ButtonMode], CommandFunc)
      table.insert(ButtonMode[#ButtonMode], self)
      ButtonMode[#ButtonMode].GMCommandGroupName = InnerButtonInfos[1]
    end
  end
  self.NRCGridView_32:InitGridView(ButtonMode)
  Items = ButtonMode
  self:UpdateItemInfo(Items)
end

function UMG_DebugPanel_C:UpdateCollectInfo()
  local ButtonInfos = JsonUtils.LoadSaved("DebugTabCollect", {})
  local ButtonMode = {}
  for i = 1, #ButtonInfos do
    local InnerButtonInfos = ButtonInfos[i]
    if self:CheckGMCommandIfIsPath(InnerButtonInfos[1]) then
      for j = 2, #InnerButtonInfos do
        table.insert(ButtonMode, {
          InnerButtonInfos[j]
        })
        local TabBase = self.module.data:GetTabDataFromCache(InnerButtonInfos[1])
        self.Items = TabBase.items
        self.Options = TabBase.options
        TabBase.Panel = self
        local item = TabBase.itemsMap[InnerButtonInfos[j]]
        if item then
          table.insert(ButtonMode[#ButtonMode], item[2])
        end
        table.insert(ButtonMode[#ButtonMode], self)
      end
    else
      local function CommandFunc()
        NRCModuleManager:DoCmd(_G.DebugModuleCmd.ExecGMGroup, InnerButtonInfos[1])
      end
      
      table.insert(ButtonMode, {
        InnerButtonInfos[2]
      })
      table.insert(ButtonMode[#ButtonMode], CommandFunc)
      table.insert(ButtonMode[#ButtonMode], self)
    end
    self.NRCGridView_32:InitGridView(ButtonMode)
  end
  return ButtonMode
end

function UMG_DebugPanel_C:UpdateHistoryInfo()
  local ButtonInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
  local ButtonMode = {}
  for i = 1, #ButtonInfos do
    local InnerButtonInfos = ButtonInfos[i]
    if self:CheckGMCommandIfIsPath(InnerButtonInfos[1]) then
      for j = 2, #InnerButtonInfos do
        table.insert(ButtonMode, {
          InnerButtonInfos[j]
        })
        local TabBase = self.module.data:GetTabDataFromCache(InnerButtonInfos[1])
        self.Items = TabBase.items
        self.Options = TabBase.options
        TabBase.Panel = self
        local item = TabBase.itemsMap[InnerButtonInfos[j]]
        if item then
          table.insert(ButtonMode[#ButtonMode], item[2])
        end
        table.insert(ButtonMode[#ButtonMode], self)
      end
    else
      local function CommandFunc()
        NRCModuleManager:DoCmd(_G.DebugModuleCmd.ExecGMGroup, InnerButtonInfos[1])
      end
      
      table.insert(ButtonMode, {
        InnerButtonInfos[2]
      })
      table.insert(ButtonMode[#ButtonMode], CommandFunc)
      table.insert(ButtonMode[#ButtonMode], self)
    end
    self.NRCGridView_32:InitGridView(ButtonMode)
  end
  return ButtonMode
end

function UMG_DebugPanel_C:OutPutExcel()
  local SaveButtonInfos = JsonUtils.LoadSaved("DebugTabAllButtonInfos", {})
  local AllLabel = self.AllLabel
  local AllCategoriesInfos = {}
  local Dynamics = {}
  table.insert(AllCategoriesInfos, {
    "\232\183\175\229\190\132\229\144\141",
    "\232\183\175\229\190\132",
    "\230\140\135\228\187\164\229\144\141",
    "\229\191\171\230\141\183\233\148\174",
    "\232\129\140\232\131\189",
    "\230\140\135\228\187\164\231\177\187\229\158\139",
    "\231\173\155\233\128\137\230\160\135\231\173\190",
    "\229\164\135\230\179\168",
    "\229\190\170\231\142\175\230\140\135\228\187\164"
  })
  for i, v in ipairs(AllLabel) do
    local TabItems = v[3]
    for j = 1, #TabItems do
      local Dynamic = TabItems[j][9]
      if not string.IsNilOrEmpty(Dynamic) then
        if Dynamics[Dynamic] then
          goto lbl_93
        else
          Dynamics[Dynamic] = true
          TabItems[j][1] = Dynamic
        end
      end
      local OutPath = string.gsub(v[1], "NewRoco.Modules.System.Debug.Tabs.", "")
      for k = 1, #TabItems[j] do
        if nil == TabItems[j][k] then
          TabItems[j][k] = ""
        end
      end
      table.insert(AllCategoriesInfos, {
        v[2],
        OutPath,
        TabItems[j][1],
        TabItems[j][4],
        TabItems[j][5],
        TabItems[j][6],
        TabItems[j][7],
        TabItems[j][8],
        TabItems[j][9]
      })
      ::lbl_93::
    end
  end
  JsonUtils.DumpSaved("DebugTabAllButtonInfos", AllCategoriesInfos)
  Log.Warning("\229\183\178\229\175\188\229\135\186\230\137\128\230\156\137\230\140\137\233\146\174\230\149\176\230\141\174")
  self:DoClose()
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\229\183\178\229\175\188\229\135\186\230\137\128\230\156\137\230\140\137\233\146\174\230\149\176\230\141\174")
end

function UMG_DebugPanel_C:IsNotSameTabBase(_Path)
  self.FirstPath = _Path
  if self.FirstPath ~= self.SecondPath then
    self.SecondPath = self.FirstPath
    return true
  else
    return false
  end
end

function UMG_DebugPanel_C:JudgeCollectState()
  local SateCollect = {}
  if self.IsCollect and not self.CancelCollect then
    table.insert(SateCollect, "IsCollect")
  elseif self.CancelCollect then
    table.insert(SateCollect, "Collected")
  else
    table.insert(SateCollect, "")
  end
  if self.IsHistory and not self.CancelHistory then
    table.insert(SateCollect, "IsHistory")
  elseif self.CancelHistory then
    table.insert(SateCollect, "Cleared")
  else
    table.insert(SateCollect, "")
  end
  return SateCollect
end

function UMG_DebugPanel_C:RecoverItems()
  self.Instruction = nil
  self.UseType = nil
  self.Order = nil
  self:UpdateItemInfo(self.Items)
end

function UMG_DebugPanel_C:SearchInstructionTab(_NewInstruction)
  local InputText = _NewInstruction
  if nil ~= InputText then
    if InputText.name == "\229\133\168\233\131\168" then
      self.Instruction = nil
    else
      self.Instruction = InputText
    end
  end
  self:UpdateItemInfo(self.Items)
end

function UMG_DebugPanel_C:SearchUseTypeTab(_UseType)
  local InputText_1 = _UseType
  if nil ~= InputText_1 then
    if InputText_1.name == "\229\133\168\233\131\168" then
      self.UseType = nil
    else
      self.UseType = InputText_1
    end
  end
  self:UpdateItemInfo(self.Items)
end

function UMG_DebugPanel_C:SearchOrder(_Order)
  local InputText_2 = _Order
  if nil ~= InputText_2 then
    if InputText_2.name == "\229\133\168\233\131\168" then
      self.Order = nil
    else
      self.Order = InputText_2
    end
  end
  self:UpdateItemInfo(self.Items)
end

function UMG_DebugPanel_C:SortTabInfo(_NewInstruction, _UseType, _Order)
  local Instruction = _NewInstruction
  local UseType = _UseType
  local Order = _Order
  local UpdateItems = {}
  local CurDebugData = self.Items
  if nil ~= Instruction then
    self.Instruction = Instruction
  elseif nil ~= UseType then
    self.UseType = UseType
  elseif nil ~= Order then
    self.Order = Order
  end
  for i, v in ipairs(CurDebugData) do
    if nil == self.Instruction or nil ~= v[5] and string.find(v[5], self.Instruction.name) then
      goto lbl_38
      goto lbl_83
      ::lbl_38::
      if nil == self.UseType or self.UseType.name == "\229\133\172\231\148\168" and "\230\179\155\231\148\168" == v[6] or self.UseType.name == "\229\133\172\231\148\168" and "\231\137\185\233\156\128" == v[6] then
      elseif "\228\184\180\230\151\182" == v[6] and self.UseType.name == "\228\184\180\230\151\182" then
        goto lbl_65
        goto lbl_83
        ::lbl_65::
        if nil == self.Order or nil ~= v[7] and v[7] == self.Order.name then
          goto lbl_78
          goto lbl_83
          ::lbl_78::
          table.insert(UpdateItems, v)
        end
      end
    end
    ::lbl_83::
  end
  return UpdateItems
end

function UMG_DebugPanel_C:ObjectIsUserData(obj)
  if type(obj) == "userdata" then
    return true
  else
    return false
  end
end

function UMG_DebugPanel_C:SwitchPanelState()
  local isPCMode = UE4Helper.IsPCMode()
  if isPCMode then
    self.Button_SwitchPCState:SetVisibility(UE4.ESlateVisibility.visible)
    self.Button_SwitchPCState_1:SetVisibility(UE4.ESlateVisibility.visible)
  end
  self.InputBox:SetText("")
  self.AbbreInputBox:SetText("")
  self.isshowabbrevia = not self.isshowabbrevia
  if self.isshowabbrevia then
    UE4Helper.ReleaseDesiredShowCursor("UMG_DebugPanel_C")
    self.NRCSwitcher:SetActiveWidgetIndex(1)
    self:SetCollectInfo()
  else
    UE4Helper.SetDesiredShowCursor(true, "UMG_DebugPanel_C")
    self.NRCSwitcher:SetActiveWidgetIndex(0)
  end
end

function UMG_DebugPanel_C:SwitchPCState()
  self.IsPCState = not self.IsPCState
  if self.IsPCState then
    self.Button_SwitchPCState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Button_SwitchPCState_1:SetVisibility(UE4.ESlateVisibility.visible)
  else
    self.Button_SwitchPCState_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Button_SwitchPCState:SetVisibility(UE4.ESlateVisibility.visible)
  end
end

function UMG_DebugPanel_C:OnCloseAbbrePanel()
  self:DoClose()
end

function UMG_DebugPanel_C:SetCollectInfo()
  self.ButtonInfo = JsonUtils.LoadSaved("DebugTabCollect", {})
  local ButtonInfos = self.ButtonInfo
  local ButtonMode = {}
  for i = 1, #ButtonInfos do
    local InnerButtonInfos = ButtonInfos[i]
    local TabBase = self.module.data:GetTabDataFromCache(InnerButtonInfos[1])
    for j = 2, #InnerButtonInfos do
      table.insert(ButtonMode, {
        InnerButtonInfos[j]
      })
      local item = TabBase.itemsMap[InnerButtonInfos[j]]
      TabBase.Panel = self
      if item then
        table.insert(ButtonMode[#ButtonMode], item[2])
      end
      table.insert(ButtonMode[#ButtonMode], TabBase)
    end
  end
  self.Items = ButtonMode
  self.Abbre_NRCGridView:InitGridView(ButtonMode)
end

function UMG_DebugPanel_C:OnInputBoxTextCommitted(text, type)
  if type == UE4.ETextCommit.OnEnter then
    local ExecResult = NRCModuleManager:DoCmd(_G.DebugModuleCmd.ExecGMGroup, text)
    if ExecResult then
      if string.find(ExecResult, "\230\136\144\229\138\159") then
        DebugTabHistory:SaveBtnInfo(text, text)
      end
      NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetHistory, ExecResult)
    end
  end
end

function UMG_DebugPanel_C:LoadDataFromExcel()
  local GMCommandDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_COMMAND_CONF):GetAllDatas()
end

function UMG_DebugPanel_C:GetMaxTableIndex(table)
  local maxIndex = 1
  for i, val in pairs(table) do
    if type(i) == "number" and i > maxIndex then
      maxIndex = i
    end
  end
  return maxIndex
end

function UMG_DebugPanel_C:AddCategoryFromExcel()
  local GMMainTabDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_MAINTAB_CONF):GetAllDatas()
  local maxMainTabIndex = self:GetMaxTableIndex(GMMainTabDataConf)
  local SubTabMap = self:GetSubTabMap()
  for i = 1, maxMainTabIndex do
    local GMMainTabData = GMMainTabDataConf[i]
    if GMMainTabData then
      if GMMainTabData.lua_filename then
        local tabName = GMMainTabData.maintab_name
        local path = GMMainTabData.lua_filename
        self:AddCategory(tabName, path)
      else
        local SubTabDataTable = SubTabMap[GMMainTabData.id]
        if SubTabDataTable then
          local mainTabName = GMMainTabData.maintab_name
          for _, SubTabData in ipairs(SubTabDataTable) do
            local subTabName = SubTabData.subtab_name
            if SubTabData.lua_filename then
              local path = SubTabData.lua_filename
              self:AddCategory(mainTabName, path, subTabName)
            end
          end
        end
      end
    end
  end
end

function UMG_DebugPanel_C:GetSubTabMap()
  local SubTabMap = {}
  local GMSubTabDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_SUBTAB_CONF):GetAllDatas()
  for _, conf in pairs(GMSubTabDataConf) do
    if conf then
      if not SubTabMap[conf.maintab_id] then
        SubTabMap[conf.maintab_id] = {}
      end
      table.insert(SubTabMap[conf.maintab_id], conf)
    end
  end
  return SubTabMap
end

function UMG_DebugPanel_C:GetSubTabByMainTabID(MainTabID)
  local GMSubTabDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_SUBTAB_CONF):GetAllDatas()
  local SubDataTable = {}
  local maxSubTabIndex = self:GetMaxTableIndex(GMSubTabDataConf)
  for i = 1, maxSubTabIndex do
    local SubTabConf = GMSubTabDataConf[i]
    if SubTabConf and MainTabID == SubTabConf.maintab_id then
      table.insert(SubDataTable, SubTabConf)
    end
  end
  return SubDataTable
end

function UMG_DebugPanel_C:LuaWriteGMDataToConfig()
  self.isOpenExcelRecordFlag = true
  self:SetupTabs()
  self.isOpenExcelRecordFlag = false
  UE4.UNRCStatics.LuaWriteGMDataToConfig(self.excelRecord)
end

function UMG_DebugPanel_C:AddServerGm()
  self.DebugTabServerGmCmds = JsonUtils.LoadSaved("DebugTabServerGmCmds", {})
  if self.DebugTabServerGmCmds and self.DebugTabServerGmCmds.cmds then
    for k, v in pairs(self.DebugTabServerGmCmds.cmds) do
      if v.cmd_belong and v.cmd_belong ~= "" then
        local gmMainTabName, gmSubTabName = string.match(v.cmd_belong, "^(.-)%-(.-)$")
        if gmMainTabName and gmSubTabName then
          for i = 1, #self.Categories do
            if self.Categories[i][1] == gmMainTabName then
              if gmSubTabName and self.Categories[i].SecondTabInfo then
                for j = 1, #self.Categories[i].SecondTabInfo do
                  if self.Categories[i].SecondTabInfo[j][1] == gmSubTabName then
                    local Cat = self:GetCategoryPathOptimization(self.Categories[i][1], self.Categories, gmSubTabName)
                    local TabBase = self.module.data:GetTabDataFromCache(Cat)
                    local hasAlreadyAdd = false
                    for l = 1, #TabBase.items do
                      if TabBase.items[l][1] == v.cmd_name then
                        hasAlreadyAdd = true
                        break
                      end
                    end
                    if not hasAlreadyAdd then
                      TabBase:Add(v.cmd_name, self.OpenGmCmdsTips, self)
                    end
                    break
                  end
                end
              end
              break
            end
          end
        else
          for i = 1, #self.Categories do
            if self.Categories[i][1] == v.cmd_belong then
              local Cat = self:GetCategoryPathOptimization(self.Categories[i][1], self.Categories)
              local TabBase = self.module.data:GetTabDataFromCache(Cat)
              local hasAlreadyAdd = false
              for l = 1, #TabBase.items do
                if TabBase.items[l][1] == v.cmd_name then
                  hasAlreadyAdd = true
                  break
                end
              end
              if not hasAlreadyAdd then
                TabBase:Add(v.cmd_name, self.OpenGmCmdsTips, self)
              end
              break
            end
          end
        end
      end
    end
  end
end

function UMG_DebugPanel_C:OpenGmCmdsTips(name)
  if not self.DebugTabServerGmCmds then
    self.DebugTabServerGmCmds = JsonUtils.LoadSaved("DebugTabServerGmCmds", {})
  end
  for i, CommGm in ipairs(self.DebugTabServerGmCmds.cmds) do
    if name == CommGm.cmd_name then
      _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugGmTips, CommGm)
      break
    end
  end
end

return UMG_DebugPanel_C
