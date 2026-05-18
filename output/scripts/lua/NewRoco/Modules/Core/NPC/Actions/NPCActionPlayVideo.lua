local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionPlayVideo = Base:Extend("NPCActionPlayVideo")

function NPCActionPlayVideo:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionPlayVideo:GetConfFromString(Param)
  local Raw = tonumber(Param)
  if nil == Raw then
    local Conf = {}
    Conf.id = 1
    Conf.movie_path = Param
    Conf.begin_black_fade_in = 1
    Conf.begin_black = 1
    Conf.end_black = 5000
    Conf.subtitle_track_id = 0
    Conf.sound_id = 0
    return Conf
  else
    return _G.DataConfigManager:GetMovieConf(Raw)
  end
end

function NPCActionPlayVideo:GetParam()
  local param = {}
  param.Action = self
  if self:IsMale() then
    param.Conf = self:GetConfFromString(self.Config.action_param1)
  else
    param.Conf = self:GetConfFromString(self.Config.action_param2)
  end
  return param
end

function NPCActionPlayVideo:Execute(playerId, needSendReq)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.PlayVideo, self:GetParam())
  Base.Execute(self, playerId, needSendReq)
end

function NPCActionPlayVideo:EndAction()
  if not self.SkipSubmit then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.VideoOnlyDialogueOver)
  end
  self:Finish(true)
end

function NPCActionPlayVideo:Lock(bLocked)
  self.Locked = bLocked
end

function NPCActionPlayVideo:OnNpcAction()
  if self.Locked then
    self:Log("action\229\183\178\232\162\171\233\148\129\229\174\154")
    return
  end
  if _G.DialogueModuleCmd and _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) then
    self:Log("\229\183\178\231\187\143\229\156\168\229\175\185\232\175\157\228\184\173\239\188\140\231\166\129\230\173\162\229\188\128\229\144\175\230\150\176\231\154\132\229\175\185\232\175\157")
    return false
  end
  local HasLoading = self:HasLoading()
  if HasLoading then
    self:Log("loading\231\149\140\233\157\162\229\183\178\231\187\143\229\188\128\229\144\175")
    return false
  end
  return Base.OnNpcAction(self)
end

function NPCActionPlayVideo:HasLoading()
  local LayerCenter = _G.NRCPanelManager.layerCenter
  local LoadingLayer = LayerCenter.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_LEVEL_LOADING]
  if not LoadingLayer then
    return false
  end
  local Windows = LoadingLayer:GetAllWindow()
  for _, Window in ipairs(Windows) do
    if Window and UE4.UObject.IsValid(Window) and Window.enableView then
      self:Log("Loading\231\149\140\233\157\162\229\188\128\229\144\175\228\184\173", Window.panelName)
      return true
    end
  end
  return false
end

function NPCActionPlayVideo:IsMale()
  return DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex == ProtoEnum.ESexValue.SEX_MALE
end

return NPCActionPlayVideo
