local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local MainUIModuleCmd = require("NewRoco.Modules.System.MainUI.MainUIModuleCmd")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local mcw = require("Debug.MemoryCheckWrapper")
local Base = DebugTabBase
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local NRCAutoDDC = require("Test.NRCAutoDDC")
local DebugTabScene = require("NewRoco.Modules.System.Debug.Tabs.DebugTabScene")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local DEBUG_HIDE = true
local DebugTabCE = Base:Extend("DebugTabCE")

function DebugTabCE:Ctor()
  Base.Ctor(self)
end

function DebugTabCE:SetupTabs()
  self:Add("\232\174\190\231\189\174HUD\233\128\143\230\152\142\229\186\166(0~1)", self.SetHUDRenderOpacity, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "SetHUDRenderOpacity")
  self:Add("\228\184\128\233\148\174\230\187\161\231\186\167(\230\187\161\229\174\160\227\128\129\229\156\176\229\155\190\229\133\168\229\188\128\227\128\129\230\180\187\229\138\168\229\133\168\229\188\128)", self.OnCheat, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "OnCheat")
  self:Add("\232\135\170\229\174\154\228\185\137\230\184\160\233\129\147\229\143\183", self.CustomizedChannel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\232\191\144\232\144\165\230\151\182\232\163\133\229\140\133\228\189\147\229\189\149\229\136\182", self.FashionRecording, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\233\154\144\229\164\180\233\161\182\229\144\141\229\173\151\231\137\140\229\146\140\229\144\141\231\137\135", self.SetHUDComponentDisabled, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "SetHUDComponentDisabled")
end

function DebugTabCE:Resolution(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("sg.NRCMobileResolutionQuality 0")
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenPercentage 100")
  UE4.UNRCQualityLibrary.SetFrameQuality(UE4.ENRCFrameQuality.Epic)
end

function DebugTabCE:CE(name, panel)
  DebugTabScene:OneKeyCE()
end

function DebugTabCE:CleanLog(name, panel)
  UE4.UNRCStatics.ExecConsoleCommand("DisableAllScreenMessages")
end

local bHideAllHUD = false

function DebugTabCE:HideAllHUD(Name, Panel)
  local ExceptUITable = {}
  local ExceptUI = ""
  if Panel then
    ExceptUI = Panel.InputBox:GetText()
    ExceptUITable[ExceptUI] = true
  end
  local CurrentMode = NRCModeManager:GetCurMode()
  if bHideAllHUD then
    UE4Helper.ReleaseDesiredShowCursor("DebugTabCE:HideAllHUD")
    CurrentMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    CurrentMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    CurrentMode:RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    bHideAllHUD = false
  else
    UE4Helper.SetDesiredShowCursor(false, "DebugTabCE:HideAllHUD", true)
    local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
    local MainView = mainUIModule and mainUIModule:HasPanel("LobbyMain") and mainUIModule:GetPanel("LobbyMain") or {}
    MainView.isGmDisable = true
    CurrentMode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    CurrentMode:DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    CurrentMode:GMDisablePanelByLayerExcept(_G.Enum.UILayerType.UI_LAYER_MAIN, ExceptUITable)
    MainView.isGmDisable = nil
    bHideAllHUD = true
  end
end

local bHidePlayer = false

function DebugTabCE:HidePlayer(name, panel)
  bHidePlayer = not bHidePlayer
  NRCModuleManager:DoCmd(PlayerModuleCmd.HIDE_ALL, bHidePlayer)
end

function DebugTabCE:SendEmailRandom(name, panel, emailNum)
  local EmailNum
  if panel then
    EmailNum = panel.InputBox:GetText()
  else
    EmailNum = emailNum
  end
  local req = _G.ProtoMessage:newZoneGmAddMailReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.rand_mail = true
  req.mail_num = tonumber(EmailNum)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_ADD_MAIL_REQ, req, self, self.OnEmailGMRsp, false, false)
end

function DebugTabCE:SendEmailByID(name, panel, emailId)
  local EmailId
  if panel then
    EmailId = panel.InputBox:GetText()
  else
    EmailId = emailId
  end
  local req = _G.ProtoMessage:newZoneGmAddMailReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.rand_mail = false
  req.mail_id = tonumber(EmailId)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_ADD_MAIL_REQ, req, self, self.OnEmailGMRsp, false, false)
end

function DebugTabCE:OnEmailGMRsp(_rsp)
  Log.Error("DebugTabCE:OnEmailGMRsp")
end

function DebugTabCE:OpenEmailPanel(name, panel)
  _G.NRCModuleManager:DoCmd(_G.EmailModuleCmd.OpenMainPanel)
end

function DebugTabCE:OnCheat()
  local RoleExpConfS = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ROLE_EXP_CONF):GetAllDatas()
  local Req = ProtoMessage:newZoneGmSetPlayerLevelReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.level = RoleExpConfS[#RoleExpConfS].id
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PLAYER_LEVEL_REQ, Req, self, self.SetWorldLevel, true, false)
  local Req_1 = ProtoMessage:newZoneGmClientAddRewardReq()
  Req_1.reward_id = 17037
  Req_1.num = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_REWARD_REQ, Req_1, self, self.ClientAddRewardRsp, true, false)
  local Req_2 = ProtoMessage:newZoneGmClientUnlockAllCampReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_UNLOCK_ALL_CAMP_REQ, Req_2, self, self.ClientUnlockAllCampRsp, true, false)
  local Req_3 = ProtoMessage:newZoneGmUnlockAllActivityReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_ALL_ACTIVITY_REQ, Req_3, self, self.UnlockAllActivityRsp, true, false)
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = 1130011
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self.SetPlayerInitPet, true, false)
end

function DebugTabCE:CustomizedChannel(name, panel, inputNumber)
  local channel
  if panel then
    channel = panel:GetInputNumber(nil, true)
  else
    channel = tonumber(inputNumber)
  end
  UE.ULoginStatics.SetConfigChannel(channel)
end

function DebugTabCE:FashionRecording()
  _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenClothingScreenRecordingTips)
end

function DebugTabCE:SetWorldLevel(Rsp)
end

function DebugTabCE:ClientAddRewardRsp(Rsp)
end

function DebugTabCE:ClientUnlockAllCampRsp(Rsp)
end

function DebugTabCE:UnlockAllActivityRsp(Rsp)
end

function DebugTabCE:SetPlayerInitPet(Rsp)
end

function DebugTabCE:SetHUDRenderOpacity(name, panel, InputText)
  local Text
  if panel then
    Text = panel.InputBox:GetText()
  else
    Text = InputText
  end
  local num = tonumber(Text)
  if not (type(num) == "number" and num >= 0) or not (num <= 1) then
    Log.Error("\232\175\183\232\190\147\229\133\1650\229\136\1761\228\185\139\233\151\180\231\154\132\230\149\176")
    return
  end
  local module = NRCModuleManager:GetModule("DebugModule")
  local widget = module:GetPanel("DebugEntry")
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local updateUIModule = _G.NRCModuleManager:GetModule("UpdateUIModule")
  local Account = updateUIModule and updateUIModule:GetPanel("AccountInfo")
  local MainView = mainUIModule and mainUIModule:HasPanel("LobbyMain") and mainUIModule:GetPanel("LobbyMain") or nil
  widget.OpenButton:SetRenderOpacity(num)
  widget.TimeText:SetRenderOpacity(num)
  if Account then
    Account.HorizontalBox_58:SetRenderOpacity(num)
    Account.Canvas_Info:SetRenderOpacity(num)
  end
  if MainView then
    MainView:SetRenderOpacity(num)
  end
  self:SetBattleUIRenderOpacity(num)
  if _G.GlobalConfig.IsShowPlayer == true then
    _G.GlobalConfig.IsShowPlayer = false
  else
    _G.GlobalConfig.IsShowPlayer = true
  end
end

function DebugTabCE:SetBattleUIRenderOpacity(num)
  local BattleUIModule = _G.NRCModuleManager:GetModule("BattleUIModule")
  local BattleMainView = BattleUIModule and BattleUIModule:HasPanel("BattleMain") and BattleUIModule:GetPanel("BattleMain") or nil
  local BattleProcessView = BattleUIModule and BattleUIModule:HasPanel("BattleProcess_Visible") and BattleUIModule:GetPanel("BattleProcess_Visible") or nil
  local BattlePopUpTips = BattleUIModule and BattleUIModule:HasPanel("BattlePopUpTips") and BattleUIModule:GetPanel("BattlePopUpTips") or nil
  local TeamPet, EnemyPet
  if _G.BattleManager.isInBattle then
    TeamPet = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM, true)
    EnemyPet = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY, true)
  else
    _G.IsSetRenderOpacity = true
    _G.RenderOpacity = num
  end
  if BattleMainView then
    BattleMainView:SetRenderOpacity(num)
    if TeamPet then
      for i = 1, #TeamPet do
        TeamPet[i].battlePetComponents:SetBuffsRenderOpacity(num)
        if 0 == num then
          TeamPet[i].battlePetComponents:SetActorHiddenInGame(true)
        else
          TeamPet[i].battlePetComponents:SetActorHiddenInGame(false)
        end
      end
    end
    if EnemyPet then
      for i = 1, #EnemyPet do
        EnemyPet[i].battlePetComponents:SetBuffsRenderOpacity(num)
        if 0 == num then
          EnemyPet[i].battlePetComponents:SetActorHiddenInGame(true)
        else
          EnemyPet[i].battlePetComponents:SetActorHiddenInGame(false)
        end
      end
    end
  end
  if BattleProcessView then
    BattleProcessView:SetRenderOpacity(num)
  end
  if BattlePopUpTips then
    BattlePopUpTips:SetRenderOpacity(num)
  end
end

function DebugTabCE:SetHUDComponentDisabled()
  _G.HUDComponentDisabled = not _G.HUDComponentDisabled
  Log.Error("\229\189\147\229\137\141\229\164\180\233\161\182\229\144\141\229\173\151\231\137\140\230\152\190\233\154\144\231\138\182\230\128\129\228\184\186=======", _G.HUDComponentDisabled and "\233\154\144\232\151\143" or "\230\152\190\231\164\186")
end

return DebugTabCE
