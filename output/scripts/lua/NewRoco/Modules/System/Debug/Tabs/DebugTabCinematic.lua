local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabCinematic = Base:Extend("DebugTabCinematic")

function DebugTabCinematic:Ctor()
  Base.Ctor(self)
  self.bCinematic = true
  self.bHideDebug = true
end

function DebugTabCinematic:SetupTabs()
  local SEQUENCE_CONFS = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SEQUENCE_CONF):GetAllDatas()
  for k, v in pairs(SEQUENCE_CONFS) do
    local X = v.act_x
    local Y = v.act_y
    local Z = v.act_z
    if math.abs(X) + math.abs(Y) + math.abs(Z) > 103 then
      self:Add(string.format([[
%d
%s]], v.id, v.editor_name), function(caller, Name, Panel)
        Log.Error("\229\133\136\232\183\179\232\189\172\229\136\176", v.act_x, v.act_y, v.act_z, "\229\134\141\232\191\155\232\161\140\230\146\173\231\137\135")
        self:ClosePanel()
        self:SetPlayerLocation(v.act_x, v.act_y, v.act_z)
        _G.DelayManager:DelaySeconds(2, self.PlaySequence, self, v.id)
      end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\231\156\139\229\138\168\231\148\187")
    end
  end
end

function DebugTabCinematic:PlaySequence(ID)
  NRCModuleManager:DoCmd(CinematicModuleCmd.StartCinematic, ID)
end

function DebugTabCinematic:ReportActorLocation(name, panel, InputText)
  local Text
  if panel then
    Text = panel.InputBox:GetText()
  else
    Text = InputText
  end
  local world = _G.UE4Helper.GetCurrentWorld()
  local foundActors = UE4.UGameplayStatics.GetAllActorsOfClass(world, UE4.AActor):ToTable()
  Log.Error(Text)
  for i = 1, #foundActors do
    local curActor = foundActors[i]
    local name = curActor:GetName()
    local Found = string.find(name, Text)
    if Found and Found >= 0 then
      Log.Error(curActor:GetName(), curActor:Abs_K2_GetActorLocation())
      if curActor.GetActorLabel then
        Log.Error(curActor:GetActorLabel())
      end
    end
  end
end

function DebugTabCinematic:AutoSkip()
  local mod = NRCModuleManager:GetModule("CinematicModule")
  local Skip = GlobalConfig.SkipCG
  if not Skip then
    GlobalConfig.SkipCG = true
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "Cinematic Auto Skip On")
  else
    GlobalConfig.SkipCG = false
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "Cinematic Auto Skip Off")
  end
end

function DebugTabCinematic:DumpAutoSkip()
  UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), string.format("Cinematic Auto Skip %s", GlobalConfig.SkipCG and "On" or "Off"))
end

function DebugTabCinematic:FreezeWhenPlaying()
  local Skip = GlobalConfig.FreezeWhenCG
  if not Skip then
    GlobalConfig.FreezeWhenCG = true
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "Cinematic FreezeWhenPlaying On")
  else
    GlobalConfig.FreezeWhenCG = false
    UE4.UKismetSystemLibrary.PrintString(UE4Helper.GetCurrentWorld(), "Cinematic FreezeWhenPlaying Off")
  end
end

function DebugTabCinematic:Who()
  UE4.UKismetSystemLibrary:PrintString(DataModelMgr.PlayerDataModel.playerInfo.brief_info.name)
end

function DebugTabCinematic:Pause()
  local Cinema = NRCModuleManager:GetModule("CinematicModule")
  Cinema.CinematicPlayer:Pause()
end

function DebugTabCinematic:Resume()
  local Cinema = NRCModuleManager:GetModule("CinematicModule")
  Cinema.CinematicPlayer:Resume()
end

function DebugTabCinematic:Stop()
  local Cinema = NRCModuleManager:GetModule("CinematicModule")
  Cinema.CinematicPlayer:Stop()
end

function DebugTabCinematic:CinematicMode()
  local module = NRCModuleManager:GetModule("DebugModule")
  local widget = module:GetPanel("DebugEntry")
  local world = UE4Helper.GetCurrentWorld()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Controller = _G.UE4Helper.GetPlayerCharacter(0):GetController()
  if self.bCinematic then
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    widget.OpenButton:SetRenderOpacity(0)
    player.viewObj:SetActorHiddenInGame(true)
    player.viewObj.Mesh.bSimGravityDisabled = false
    self.bCinematic = false
  else
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_DIALOGUE)
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_TOP)
    widget.OpenButton:SetRenderOpacity(0.01)
    player.viewObj:SetActorHiddenInGame(false)
    player.viewObj.Mesh.bSimGravityDisabled = true
    self.bCinematic = true
  end
end

function DebugTabCinematic:HideDebugButton()
  local module = NRCModuleManager:GetModule("DebugModule")
  local widget = module:GetPanel("DebugEntry")
  if self.bHideDebug then
    widget.OpenButton:SetRenderOpacity(0)
    self.bHideDebug = false
  else
    widget.OpenButton:SetRenderOpacity(0.01)
    self.bHideDebug = true
  end
end

function DebugTabCinematic:PlayByPath(Name, Panel)
  local Conf = {
    id = 1600001,
    sequence_path = self:GetInputString(),
    begin_black = 1,
    end_black = 1,
    act_x = 0,
    act_y = 0,
    act_z = 0,
    is_hide_npc = 1,
    npc_refresh = {},
    keep_light = 0,
    yaw = 0
  }
  NRCModuleManager:DoCmd(CinematicModuleCmd.StartCinematic, Conf)
  self:ClosePanel()
end

function DebugTabCinematic:ShowBar(Name, Panel)
  local Module = _G.NRCModuleManager:GetModule("CinematicModule")
  Module:OpenPanel("CinematicBar")
end

return DebugTabCinematic
