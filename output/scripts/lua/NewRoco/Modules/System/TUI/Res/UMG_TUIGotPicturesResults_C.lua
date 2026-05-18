require("UnLuaEx")
local TUIModuleEvent = require("NewRoco.Modules.System.TUI.TUIModuleEvent")
local UMG_TUIGotPicturesResults_C = _G.NRCViewBase:Extend("UMG_TUIGotPicturesResults_C")

function UMG_TUIGotPicturesResults_C:OnConstruct()
end

function UMG_TUIGotPicturesResults_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_TUIGotPicturesResults_C:Init(PicturesListPanel)
  Log.Warning("PicturesResults Init!")
  self.PicturesListPanel = PicturesListPanel
  self.RunAtlas = PicturesListPanel.RunAtlas
  self:OnAddEventListener()
end

function UMG_TUIGotPicturesResults_C:OnAddEventListener()
  Log.Warning("UMG_TUIGotPicturesResults_C:OnAddEventListener")
  self:AddButtonListener(self.GotPicturesListButton, self.GetRuntimeLoadAtlas)
end

function UMG_TUIGotPicturesResults_C:GetRuntimeLoadAtlas()
  local results = self.RunAtlas
  self.ResultList:InitList(results)
  Log.Dump(results, 5, "UMG_TUIGotPicturesResults_C:GetRuntimeLoadAtlas")
end

function UMG_TUIGotPicturesResults_C:OnActive()
end

function UMG_TUIGotPicturesResults_C:OnDeactive()
end

return UMG_TUIGotPicturesResults_C
