local ModuleEvent = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_CultivationResetTips_C = _G.NRCPanelBase:Extend("UMG_CultivationResetTips_C")

function UMG_CultivationResetTips_C:OnActive(bIsWeeklyMax, resetGrow, resetLevel, resetWorkHard)
  self:PlayAnimation(self.Appear)
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_CultivationResetTips_C:OnActive")
  self.bIsWeeklyMax = bIsWeeklyMax
  self.resetGrow = resetGrow
  self.resetLevel = resetLevel
  self.resetWorkHard = resetWorkHard
  if bIsWeeklyMax then
    self.SeedDetails:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImage_119:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.GrowthText1_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.GrowthText1_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Type:SetText(_G.LuaText.weekly_challenge_text_14)
  else
    self.SeedDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_119:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.GrowthText1_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.GrowthText1_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Type:SetText(_G.LuaText.weekly_challenge_text_17)
  end
  self.TitleText:SetText(_G.LuaText.weekly_challenge_text_13)
  self.GrowthText1:SetText(string.format(_G.LuaText.weekly_challenge_text_15, resetLevel))
  self.GrowthText1_2:SetText(_G.LuaText.weekly_challenge_text_32)
  local growStarList = {}
  for i = 1, 5 do
    if resetGrow >= i then
      table.insert(growStarList, {
        i,
        IsShow = 1,
        IsBreakThrough = false
      })
    else
      table.insert(growStarList, {
        i,
        IsShow = -1,
        IsBreakThrough = false
      })
    end
  end
  self.CatchHardLv:InitGridView(growStarList)
  self.GrowthText1_3:SetText(_G.LuaText.weekly_challenge_text_32)
  self.EffortValueText:SetText(string.format("x%s", resetWorkHard))
  self.GrowthText1_4:SetText(_G.LuaText.weekly_challenge_text_25)
  self.EffortValueText1_1:SetText(_G.LuaText.weekly_challenge_text_32)
  self:_InitJumpInfo()
  self:OnAddEventListener()
end

function UMG_CultivationResetTips_C:OnPcClose()
  self:PlayAnimation(self.Disappear)
end

function UMG_CultivationResetTips_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_CultivationResetTips_C:OnAddEventListener()
  if not self.bInit then
    self.bInit = true
    self:AddButtonListener(self.Btn_ShutDown, self.OnShutdownButtonClick)
    self:AddButtonListener(self.GoButton1, self.OnGoCultivateHighestLevelButtonClicked)
    self:AddButtonListener(self.GoButton2, self.OnGoCultivateHighestGrowButtonClicked)
    self:AddButtonListener(self.GoButton3, self.OnGoCultivateHighestGrowButtonClicked)
    self:RegisterEvent(self, ModuleEvent.OnResetDataChangedEvent, self.OnResetDataChangedEvent)
  end
end

function UMG_CultivationResetTips_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, ModuleEvent.OnResetDataChangedEvent)
end

function UMG_CultivationResetTips_C:OnShutdownButtonClick()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_CultivationResetTips_C:OnShutdownButtonClick")
  self:PlayAnimation(self.Disappear)
end

function UMG_CultivationResetTips_C:OnAnimationFinished(Anim)
  if Anim == self.Disappear then
    self:DoClose()
  end
end

function UMG_CultivationResetTips_C:_InitJumpInfo()
  self.WeeklyChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  if not self.WeeklyChallengeEventActivityObject or not self.WeeklyChallengeEventActivityObject[1] then
    Log.Error("UMG_CultivationResetTips_C:InitJumpInfo \232\142\183\229\143\150\230\180\187\229\138\168\229\164\177\232\180\165")
    return
  end
  local weekly_challenge_data = self.WeeklyChallengeEventActivityObject[1]:GetWeeklyChallengeData()
  if weekly_challenge_data then
    self.eventConf = _G.DataConfigManager:GetWeeklyChallengeEventConf(weekly_challenge_data.event_id)
  end
  if not self.eventConf then
    self.eventConf = nil
    Log.Error("UMG_CultivationResetTips_C:InitJumpInfo \232\142\183\229\143\150eventConf\229\164\177\232\180\165")
    return
  end
  local petList = _G.DataModelMgr.PlayerDataModel:GetPetData()
  local candidatesLevels = {}
  local candidatesGrow = {}
  if petList then
    for k, v in ipairs(petList) do
      if v.level == self.resetLevel then
        table.insert(candidatesLevels, v)
      end
      local _, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(v)
      if (v.grow_times == self.resetWorkHard or nil == v.grow_times and 0 == self.resetWorkHard) and GrowOrder - 1 == self.resetGrow then
        table.insert(candidatesGrow, v)
      end
    end
  end
  table.sort(candidatesLevels, function(a, b)
    return (a.add_time or 0) > (b.add_time or 0)
  end)
  table.sort(candidatesGrow, function(a, b)
    return (a.add_time or 0) > (b.add_time or 0)
  end)
  self.HeadPortrait1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.HeadPortrait2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.HeadPortrait3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if 0 == #candidatesLevels then
    Log.Warning("\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\231\173\137\231\186\167\231\154\132\231\178\190\231\129\181\239\188\140\229\143\175\232\131\189\230\152\175\229\189\147\229\137\141\230\178\161\230\156\137\228\187\187\228\189\149\228\184\128\229\143\170\231\172\166\229\144\136\230\157\161\228\187\182\231\154\132\231\178\190\231\129\181")
    self.HeadPortrait1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 0 == #candidatesGrow then
    Log.Warning("\230\178\161\230\137\190\229\136\176\229\175\185\229\186\148\229\133\187\230\136\144\231\154\132\231\178\190\231\129\181\239\188\140\229\143\175\232\131\189\230\152\175\229\189\147\229\137\141\230\178\161\230\156\137\228\187\187\228\189\149\228\184\128\229\143\170\231\172\166\229\144\136\230\157\161\228\187\182\231\154\132\231\178\190\231\129\181")
    self.HeadPortrait2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadPortrait3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if #candidatesLevels > 0 then
    self.levelPetData = candidatesLevels[1]
    if self.levelPetData then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.levelPetData.base_conf_id)
      if petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        if modelConf then
          self.HeadPortrait1:SetPath(modelConf.icon)
        end
      end
    end
  end
  if #candidatesGrow > 0 then
    self.growPetData = candidatesGrow[1]
    if self.growPetData then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.growPetData.base_conf_id)
      if petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        if modelConf then
          self.HeadPortrait2:SetPath(modelConf.icon)
          self.HeadPortrait3:SetPath(modelConf.icon)
        end
      end
    end
  end
end

function UMG_CultivationResetTips_C:OnGoCultivateHighestLevelButtonClicked()
  if not self.levelPetData then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\154\130\230\151\160\230\156\172\229\145\168\230\141\149\230\141\137\231\178\190\231\129\181")
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_CultivationResetTips_C:OnGoCultivateButtonClicked")
  _G.NRCModuleManager:DoCmd(CampingModuleCmd.SetIsCultivatePet, true)
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.levelPetData.gid)
  if petData then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetDataRedPoint)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_LobbyMain_C:OnBtnPetHeadClick")
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPetAttribute, true)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {subPanelIndex = 4, bHideSkill = true})
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\154\130\230\151\160\230\156\172\229\145\168\230\141\149\230\141\137\231\178\190\231\129\181")
  end
end

function UMG_CultivationResetTips_C:OnGoCultivateHighestGrowButtonClicked()
  if not self.growPetData then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\154\130\230\151\160\230\156\172\229\145\168\230\141\149\230\141\137\231\178\190\231\129\181")
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_CultivationResetTips_C:OnGoCultivateButtonClicked")
  _G.NRCModuleManager:DoCmd(CampingModuleCmd.SetIsCultivatePet, true)
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.growPetData.gid)
  if petData then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetDataRedPoint)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_LobbyMain_C:OnBtnPetHeadClick")
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPetAttribute, true)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {subPanelIndex = 4, bHideSkill = true})
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\154\130\230\151\160\230\156\172\229\145\168\230\141\149\230\141\137\231\178\190\231\129\181")
  end
end

function UMG_CultivationResetTips_C:OnResetDataChangedEvent(newPetList, newResetLevel, newResetGrow, newResetWorkHard)
  self:OnActive(self.bIsWeeklyMax, newResetGrow, newResetLevel, newResetWorkHard)
end

return UMG_CultivationResetTips_C
