require("UnLuaEx")
local TextReplaceContext = require("NewRoco.Modules.System.TextReplaceContext")
local DialogueTextReplacer = require("NewRoco.Modules.System.Dialogue.DialogueTextReplacer")
local DialogueModuleEvent = reload("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialoguePanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialoguePanelBase")
local UMG_DialoguePicBlack_C = DialoguePanelBase:Extend("UMG_DialoguePicBlack_C")
return UMG_DialoguePicBlack_C
