require("UnLuaEx")
local UIWindowCtrlBase = require("NewRoco.Modules.UI.UIWindowCtrlBase")
local UMG_Battle_Skill_Item_Ctrl = UIWindowCtrlBase:Extend("UMG_Battle_Skill_Item_Ctrl")

function UMG_Battle_Skill_Item_Ctrl:OnGenerateCtrl()
  self.SubCtrlTable = {}
end

function UMG_Battle_Skill_Item_Ctrl:OnAddEventListener()
end

function UMG_Battle_Skill_Item_Ctrl:OnRemoveEventListener()
end

function UMG_Battle_Skill_Item_Ctrl:OnBeforeOpen()
end

function UMG_Battle_Skill_Item_Ctrl:OnBeforeClose()
end

return UMG_Battle_Skill_Item_Ctrl
