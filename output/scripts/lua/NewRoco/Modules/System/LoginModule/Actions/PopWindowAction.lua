local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = NRCModeAction
local PopWindowAction = Base:Extend("PopWindowAction")

function PopWindowAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function PopWindowAction:OnEnter()
  Log.Debug("PopWindowAction OnEnter:", self.name)
  local CurLevelName = LevelHelper:GetLevelName()
  local Title = self.properties.Title
  local Content = self.properties.Content
  local ConfirmEvent = self.properties.ConfirmEvent or LoginModuleEvent.PopUpWindowConfirm
  local CancelEvent = self.properties.CancelEvent or LoginModuleEvent.PopUpWindowCancel
  local ConfigName = self.properties.ConfigName
  local SmallWindow = self.properties.SmallWindow or false
  local OnlyConfirm = self.properties.OnlyConfirm or false
  local BtnRight = self.properties.BtnRight
  local BtnLeft = self.properties.BtnLeft
  if "UpdateLevel" == CurLevelName then
    NRCModuleManager:DoCmd(UpdateUIModuleCmd.ShowPopUpWindow, OnlyConfirm, Title, Content, BtnRight, BtnLeft)
  elseif "Login" == CurLevelName or "Plot_A1_LearnMagic_New_Release" == CurLevelName then
    if OnlyConfirm then
      NRCModuleManager:DoCmd(LoginModuleCmd.PopConfirmWindow, Title, Content, ConfirmEvent, ConfigName, SmallWindow)
    else
      NRCModuleManager:DoCmd(LoginModuleCmd.PopUpWindow, Title, Content, ConfirmEvent, CancelEvent, ConfigName, SmallWindow)
    end
  end
end

function PopWindowAction:OnPanelOpened()
  Log.Debug("PopWindowAction OnPanelOpened:", self.name)
  self:Finish()
end

function PopWindowAction:OnExit()
  Log.Debug("PopWindowAction OnExit:", self.name)
end

return PopWindowAction
