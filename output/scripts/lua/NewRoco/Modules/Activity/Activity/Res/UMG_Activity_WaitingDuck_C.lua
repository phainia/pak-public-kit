local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_Activity_WaitingDuck_C = Base:Extend("UMG_Activity_WaitingDuck_C")

function UMG_Activity_WaitingDuck_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.BtnParticulars.btnLevelUp
  return uiElements
end

function UMG_Activity_WaitingDuck_C:OnConstruct()
  Base.OnConstruct(self)
  self:InitActivity()
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.PlayActivityVideo)
  self:AddButtonListener(self.ExamineBtn, self.JumpToPetDesc)
end

function UMG_Activity_WaitingDuck_C:InitActivity()
  local activityInst = self.activityInst
  local activityConf = activityInst.activityConf
  self.Text_Title:SetText(activityConf.activity_name)
  self.Text_Title_1:SetText(activityConf.prompt_text)
  local confs = _G.DataConfigManager:GetAllByName("ACTIVITY_CONDITION_REWARD_CONF")
  local datas = {}
  for i, id in ipairs(activityConf.base_id) do
    table.insert(datas, confs[id])
  end
  self.List:InitGridView(ActivityUtils.CreateActivityItemBaseDataForList(self, datas))
  if activityInst.svrActivityData then
    self:OnSvrUpdateActivityData(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP, activityInst.svrActivityData, true)
  end
end

function UMG_Activity_WaitingDuck_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
  _G.NRCAudioManager:SetStateByName("Story_Movie", "None")
end

function UMG_Activity_WaitingDuck_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  local bHasTimeLeft = self.activityInst:GetActivityTimeLeft() ~= math.maxinteger
  self.CanvasPanel_Time:SetVisibility(bHasTimeLeft and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  self:PlayAnimationByName("In")
end

function UMG_Activity_WaitingDuck_C:PlayActivityVideo()
  local conf = _G.DataConfigManager:GetMovieConf(10)
  local param = {}
  param.caller = self
  param.callback = self.ActivityVideoEnd
  param.file_path = conf.movie_path
  param.bSkip = true
  param.soundID = 9001
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.PlayVideo, param)
end

function UMG_Activity_WaitingDuck_C:ActivityVideoEnd()
  self:StopAllAnimations()
  self:PlayAnimationByName("In")
end

function UMG_Activity_WaitingDuck_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    self:PlayAnimation(self.Loop, 0, 0)
  end
end

function UMG_Activity_WaitingDuck_C:OnSvrUpdateActivityData(_cmdId, _activityData, _initUpdate)
  if not _activityData.part_data then
    return
  end
  local activityInst = self.activityInst
  if _activityData.first_open == nil then
    self:PlayActivityVideo()
    local req = _G.ProtoMessage:newZonePlayerOpenActivityReq()
    req.activity_id = activityInst:GetActivityId()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_OPEN_ACTIVITY_REQ, req, self, self.FirstPlayActivityVideoRsp)
  end
  for i = 0, self.List:GetItemCount() - 1 do
    local Item = self.List:GetItemByIndex(i)
    Item:RefreshState(_activityData.part_data)
  end
end

function UMG_Activity_WaitingDuck_C:FirstPlayActivityVideoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local activityInst = self.activityInst
    activityInst.svrActivityData.first_open = false
  end
end

function UMG_Activity_WaitingDuck_C:JumpToPetDesc()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_WaitingDuck_C:JumpToPetDesc")
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, 3453, true)
end

return UMG_Activity_WaitingDuck_C
