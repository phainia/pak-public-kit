local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RepairTools_Entry_C = Base:Extend("UMG_RepairTools_Entry_C")
local EnmUILogLevelTag = {Low = 0, High = 5}
local EnmUILogLevelTag2Name = {
  Low = LuaText.repairtools_upload_2,
  High = LuaText.repairtools_upload_3
}

function UMG_RepairTools_Entry_C:OnConstruct()
  self:AddButtonListener(self.UMG_Btn2.btnLevelUp, self.OnClickRepair)
  self:AddButtonListener(self.UMG_Btn.btnLevelUp, self.OnClickRepair)
  local Tag2Buttons = {
    Low = self.UMG_CheckButton_3,
    High = self.UMG_CheckButton_4
  }
  for Tag, Button in pairs(Tag2Buttons) do
    self:AddButtonListener(Button.Button, function()
      self:OnClickChangeLogLevel(Tag)
    end)
  end
  self.LogLevelButtons = Tag2Buttons
end

function UMG_RepairTools_Entry_C:OnItemUpdate(Data)
  self._Data = Data
  self:InternalRefreshContent()
  self:PlayAnimation(self.In)
end

function UMG_RepairTools_Entry_C:SafeCheck()
  return self.viewbuttonEventDict
end

function UMG_RepairTools_Entry_C:InternalRefreshContent()
  local ContentStr = self._Data and self._Data.ContentStr or ""
  self.Title:SetText(ContentStr)
  local ButtonStr = self._Data and self._Data.ButtonStr or ""
  self.UMG_Btn2:SetBtnText(ButtonStr)
  self:SwitchAdjustLogLevelMode(self._Data.EnableLogLevel)
end

function UMG_RepairTools_Entry_C:SwitchAdjustLogLevelMode(bEnableLogLevel)
  if bEnableLogLevel then
    self:RefreshLogLevels()
    self.WidgetSwitcher_0:SetActiveWidgetIndex(2)
  else
    self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end

function UMG_RepairTools_Entry_C:RefreshLogLevels()
  local TargetTag = GameSetting:GetUploadLogTag()
  for Tag, Button in pairs(self.LogLevelButtons) do
    local bSelected = Tag == TargetTag
    local bOldSelected = Button.bSelected
    local bChanged = bOldSelected ~= bSelected
    Button.bSelected = bSelected
    Button.text:SetText(EnmUILogLevelTag2Name[Tag])
    if bChanged then
      Button:OnItemSelected(bSelected)
    end
  end
end

function UMG_RepairTools_Entry_C:OnClickChangeLogLevel(Tag)
  local function DoChangeLogLevel()
    local Level = EnmUILogLevelTag[Tag] or 0
    
    GameSetting:SetLogLevel(Level)
    GameSetting:SyncUploadLogTag(Tag)
    GameSetting:Save()
    self:RefreshLogLevels()
  end
  
  local TargetTag = GameSetting:GetUploadLogTag()
  if "High" == Tag and TargetTag ~= Tag then
    local Text = LuaText.repairtools_upload_6
    local Ctx = DialogContext()
    Ctx:SetTitle(LuaText.TIPS)
    Ctx:SetContent(Text)
    Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
    Ctx:SetButtonText(LuaText.umg_dialog_2, LuaText.umg_dialog_1)
    Ctx:SetCloseOnCancel(true)
    Ctx:SetCallbackOkOnly(nil, DoChangeLogLevel)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  else
    DoChangeLogLevel()
  end
end

function UMG_RepairTools_Entry_C:OnClickRepair()
  if self._Data then
    local Delegate = self._Data.OnClickDelegate
    if Delegate then
      Delegate()
    end
  end
end

return UMG_RepairTools_Entry_C
