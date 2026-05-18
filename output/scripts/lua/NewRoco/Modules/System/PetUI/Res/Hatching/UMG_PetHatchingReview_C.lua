local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_PetHatchingReview_C = Base:Extend("UMG_PetHatchingReview_C")

function UMG_PetHatchingReview_C:BindUIElements()
  local uiElements = {}
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "Change"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_PetHatchingReview_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_PetHatchingReview_C:OnEnable()
end

function UMG_PetHatchingReview_C:OnActive(activityInst)
  self.NRCScrollView_93:InitList({})
  local TempTitle = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_title").msg
  local TempMagicName = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_nickname").msg
  local TempMagicStr = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_des2").msg
  if TempTitle and TempMagicName and TempMagicStr then
    self.Title_1:SetText(TempTitle)
    self.Magician:SetText(TempMagicName)
    self.Prompt:SetText(TempMagicStr)
  end
  if self.In then
    self:PlayAnimation(self.In)
  else
    self:OnAnimationFinished(self.In)
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008044, "UMG_Activity_PetHatchingReview_C")
  self:AddButtonListener(self.BtnClose, self.ClosePanel)
  self.activityInst = activityInst
  self:InitActivity()
  self:BindInputAction()
end

function UMG_PetHatchingReview_C:OnDeactive()
  self:UnBindInputAction()
end

function UMG_PetHatchingReview_C:InitActivity()
  self.Magician_1:SetText(_G.DataModelMgr.PlayerDataModel:GetPlayerName())
  local PerStr = "HatchWeekend_review_percent_"
  local HatchNum = #self.activityInst.svrActivityData.up_data.hatch_up_stats
  local MaxNumConf = _G.DataConfigManager:GetActivityGlobalConfig("HatchWeekend_review_percent_maxnum")
  local MaxNum = 100
  if MaxNumConf and MaxNumConf.num then
    MaxNum = MaxNumConf.num
  end
  local SetFlag = false
  for i = 1, MaxNum do
    local IndexStr = string.format("%s%d", PerStr, i)
    local PreList = ActivityUtils.GetActivityGlobalConfig(IndexStr)
    if PreList then
      local List = PreList.numList
      if List then
        if HatchNum >= List[1] and HatchNum <= List[2] then
          self.Number_1:SetText(string.format("%d%%", List[3]))
          SetFlag = true
          break
        end
      else
        self.Number_1:SetText("100%")
        SetFlag = true
      end
    else
      self.Number_1:SetText("100%")
      SetFlag = true
    end
  end
  if not SetFlag then
    self.Number_1:SetText("100%")
  end
  self:UpdateActivityData(self.activityInst.svrActivityData)
end

function UMG_PetHatchingReview_C:UpdateActivityData(_activityData)
  local activityInst = self.activityInst
  if not _activityData or _activityData.first_open == nil then
    self:PlayActivityVideo()
    local req = _G.ProtoMessage:newZonePlayerOpenActivityReq()
    req.activity_id = activityInst:GetActivityId()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_OPEN_ACTIVITY_REQ, req, self, self.FirstPlayActivityVideoRsp)
  end
  local TempStr = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_des").msg
  local up_data = _activityData.up_data
  if not up_data or not up_data.hatch_up_stats then
    self.NRCScrollView_93:InitList({})
    if TempStr then
      self.Prompt_1:SetText(string.format(TempStr, 0))
    end
    return
  end
  local hatch_up_stats = up_data.hatch_up_stats
  local HatchNum = #hatch_up_stats
  if TempStr then
    self.Prompt_1:SetText(string.format(TempStr, HatchNum))
  end
  local Icons = {}
  for i = 1, HatchNum do
    self.PetBaseId = _G.DataConfigManager:GetPetConf(hatch_up_stats[i].pet_id).base_id
    self.EggConfID = _G.DataConfigManager:GetPetbaseConf(self.PetBaseId).pet_egg
    if nil == self.EggConfID or 0 == self.EggConfID then
      self.EggConfID = 107001
    end
    self.HatchFinishTime = self:SetTime(hatch_up_stats[i].hatch_finish_time)
    self.weekday, self.time = self.HatchFinishTime:match("^(.-)%s(.*)$")
    local Icon = {
      base_conf_id = self.PetBaseId,
      mutation_type = hatch_up_stats[i].mutation_type,
      glass_info = hatch_up_stats[i].glass_info,
      BgCol = _G.DataConfigManager:GetTypeDictionary(_G.DataConfigManager:GetPetbaseConf(self.PetBaseId).unit_type[1]).rolecard_favorite_pets_colour,
      EggIconPath = _G.DataConfigManager:GetBagItemConf(self.EggConfID).icon,
      Week = self.weekday,
      Time = self.time
    }
    table.insert(Icons, Icon)
  end
  self.NRCScrollView_93:InitList(Icons)
end

function UMG_PetHatchingReview_C:SetTime(UnixTime)
  local formatted_time = os.date("%A %H:%M", UnixTime)
  local TempMON = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_MON").msg
  local TempTUE = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_TUE").msg
  local TempWED = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_WED").msg
  local TempTHU = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_THU").msg
  local TempFRI = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_FRI").msg
  local TempSAT = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_SAT").msg
  local TempSUN = _G.DataConfigManager:GetLocalizationConf("hatch_review_tips_SUN").msg
  if TempMON and TempTUE and TempWED and TempTHU and TempFRI and TempSAT and TempSUN then
    formatted_time = formatted_time:gsub("Monday", TempMON)
    formatted_time = formatted_time:gsub("Tuesday", TempTUE)
    formatted_time = formatted_time:gsub("Wednesday", TempWED)
    formatted_time = formatted_time:gsub("Thursday", TempTHU)
    formatted_time = formatted_time:gsub("Friday", TempFRI)
    formatted_time = formatted_time:gsub("Saturday", TempSAT)
    formatted_time = formatted_time:gsub("Sunday", TempSUN)
  end
  return formatted_time
end

function UMG_PetHatchingReview_C:PlayActivityVideo()
end

function UMG_PetHatchingReview_C:FirstPlayActivityVideoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local activityInst = self.activityInst
    activityInst.svrActivityData.first_open = false
  end
end

function UMG_PetHatchingReview_C:ClosePanel()
  self:StopAllAnimations()
  _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_Activity_PetHatchingReview_C:ClosePanel")
  if self.Out then
    self:PlayAnimation(self.Out)
  else
    self:OnAnimationFinished(self.Out)
  end
end

function UMG_PetHatchingReview_C:OnAnimationFinished(anim)
  if anim == self.In then
    self:PlayAnimation(self.Change)
  elseif anim == self.Out then
    self:OnClose()
  end
end

function UMG_PetHatchingReview_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.itemInfo = self.uiData.data
end

function UMG_PetHatchingReview_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_CommonCloseUI")
  if mappingContext then
    mappingContext:BindAction("IA_CloseUI", self, "OnPcClose2")
  end
end

function UMG_PetHatchingReview_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_CommonCloseUI")
  if mappingContext then
    mappingContext:UnBindAction("IA_CloseUI")
  end
  self:RemoveInputMappingContext("IMC_CommonCloseUI")
end

function UMG_PetHatchingReview_C:OnPcClose2()
  self:ClosePanel()
end

return UMG_PetHatchingReview_C
