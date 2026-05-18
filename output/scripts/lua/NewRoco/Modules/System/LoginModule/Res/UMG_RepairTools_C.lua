local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local UMG_RepairTools_C = _G.NRCPanelBase:Extend("UMG_RepairTools_C")
local RepairToolsUtils = require("NewRoco/Modules/System/LoginModule/RepairToolsUtils")

function UMG_RepairTools_C:OnConstruct()
  self._FuncList = self.NRCScrollView_99
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
  if self.Title1 then
    self:SetCommonTitle()
  end
  self._FuncList:InitList({
    self:OnCreateRepairData(),
    self:OnCreateCleanCache(),
    self:OnCreateAdjustLogLevel()
  })
end

function UMG_RepairTools_C:OnActive()
end

function UMG_RepairTools_C:OnAnimFinished(Anim)
  if Anim == self.In then
    self:PlayAnimation(self.Loop, 0, 268435455)
  elseif Anim == self.Out then
    _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetSelectTabIndex, 0)
  end
end

function UMG_RepairTools_C:OnCreateRepairData()
  return {
    ContentStr = LuaText.repairtools_repair,
    ButtonStr = LuaText.repairtools_repair_title,
    OnClickDelegate = function()
      _G.NRCAudioManager:PlaySound2DAuto(1064, "UMG_RepairTools_C:OnCreateRepairData")
      if self:IsValid() then
        self:OnClickRepair()
      end
    end
  }
end

function UMG_RepairTools_C:OnCreateCleanCache()
  return {
    ContentStr = LuaText.repairtools_clean,
    ButtonStr = LuaText.repairtools_clean_title,
    OnClickDelegate = function()
      _G.NRCAudioManager:PlaySound2DAuto(1064, "UMG_RepairTools_C:OnCreateCleanCache")
      local bSuccess = RepairToolsUtils.CleanPlatformCache()
      if bSuccess then
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_clean_finish)
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.repairtools_clean_empty)
      end
    end
  }
end

function UMG_RepairTools_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_RepairTools_C:OnCreateCustomerService()
  return {
    ContentStr = LuaText.repairtools_contact,
    ButtonStr = LuaText.repairtools_contact_title,
    OnClickDelegate = function()
      _G.NRCAudioManager:PlaySound2DAuto(1064, "UMG_RepairTools_C:OnCreateCustomerService")
      self:DelaySeconds(0.1, function()
        _G.NRCSDKManager:CustomerService(1)
      end)
    end
  }
end

function UMG_RepairTools_C:OnCreateUploadLogs()
  return {
    ContentStr = LuaText.repairtools_upload,
    ButtonStr = LuaText.repairtools_upload_title,
    OnClickDelegate = function()
      _G.NRCAudioManager:PlaySound2DAuto(1064, "UMG_RepairTools_C:OnCreateUploadLogs")
      NRCModuleManager:DoCmd(CosUploadModuleCmd.StartupUploadLogs)
    end
  }
end

function UMG_RepairTools_C:OnCreateAdjustLogLevel()
  return {
    ContentStr = LuaText.repairtools_upload_1,
    OnClickDelegate = function()
      _G.NRCAudioManager:PlaySound2DAuto(1064, "UMG_RepairTools_C:OnCreateUploadLogs")
      NRCModuleManager:DoCmd(CosUploadModuleCmd.StartupUploadLogs)
    end,
    EnableLogLevel = true
  }
end

function UMG_RepairTools_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  self:StopAnimation(self.In)
  self:StopAnimation(self.Loop)
end

function UMG_RepairTools_C:OnAddEventListener()
end

function UMG_RepairTools_C:OnClickRepair()
  local Ctx = DialogContext()
  Ctx:SetTitle(LuaText.TIPS):SetContent(LuaText.repairtools_clean_tips):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(obj, bOK)
    if bOK and AppMain then
      AppMain.RepairCleanup()
      UE4.UNRCStatics.QuitGame()
    end
  end):SetCloseOnCancel(true):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_RepairTools_C:OnClickCloseBtn()
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetSelectTabIndex, 0)
  self:OnClose()
end

return UMG_RepairTools_C
