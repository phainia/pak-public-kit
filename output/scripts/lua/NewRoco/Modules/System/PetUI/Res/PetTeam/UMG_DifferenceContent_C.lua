local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_DifferenceContent_C = _G.NRCPanelBase:Extend("UMG_DifferenceContent_C")

function UMG_DifferenceContent_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_DifferenceContent_C:OnActive(openType, DiffNum, DiffList, LostNum, LostList)
  self.AllLostNum = LostNum
  self.openType = openType
  if 1 == self.openType then
    self.ContentText:SetText(string.format(LuaText.lineup_code_difference_tips, DiffNum))
    local ContentDiffListText = ""
    local AllNum = #DiffList
    local num = 0
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent] > 0 then
      num = num + 1
      local Text = ""
      if AllNum > num then
        Text = string.format(LuaText.lineup_code_individual_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent]) .. "\n"
      else
        Text = string.format(LuaText.lineup_code_individual_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent])
      end
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature] > 0 then
      num = num + 1
      local Text = ""
      if AllNum > num then
        Text = string.format(LuaText.lineup_code_nature_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature]) .. "\n"
      else
        Text = string.format(LuaText.lineup_code_nature_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature])
      end
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood] > 0 then
      num = num + 1
      local Text = ""
      if AllNum > num then
        Text = string.format(LuaText.lineup_code_blood_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood]) .. "\n"
      else
        Text = string.format(LuaText.lineup_code_blood_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood])
      end
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    self.ContentText_1:SetText(ContentDiffListText)
    self:SetCommonPopUpInfo(self.PopUp3, LuaText.lineup_code_all_difference)
  elseif 2 == self.openType then
    local LostDataTypeNum = 0
    for _, data in pairs(LostList) do
      LostDataTypeNum = LostDataTypeNum + 1
    end
    self.ContentText:SetText(string.format(LuaText.lineup_code_lack_tips, LostNum))
    local ContentDiffListText = ""
    local num = 0
    if LostList[PetUIModuleEnum.PetTeamShareReviseType.Magic] and LostList[PetUIModuleEnum.PetTeamShareReviseType.Magic] > 0 then
      num = num + 1
      local Text = ""
      if LostDataTypeNum > num then
        Text = string.format(LuaText.lineup_code_magic_lack, LostList[PetUIModuleEnum.PetTeamShareReviseType.Magic]) .. "\n"
      else
        Text = string.format(LuaText.lineup_code_magic_lack, LostList[PetUIModuleEnum.PetTeamShareReviseType.Magic])
      end
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    if LostList[PetUIModuleEnum.PetTeamShareReviseType.Pet] and LostList[PetUIModuleEnum.PetTeamShareReviseType.Pet] > 0 then
      num = num + 1
      local Text = ""
      if LostDataTypeNum > num then
        Text = string.format(LuaText.lineup_code_pet_lack, LostList[PetUIModuleEnum.PetTeamShareReviseType.Pet]) .. "\n"
      else
        Text = string.format(LuaText.lineup_code_pet_lack, LostList[PetUIModuleEnum.PetTeamShareReviseType.Pet])
      end
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    if LostList[PetUIModuleEnum.PetTeamShareReviseType.Skill] and LostList[PetUIModuleEnum.PetTeamShareReviseType.Skill] > 0 then
      num = num + 1
      local Text = ""
      self.lostSkillNum = LostList[PetUIModuleEnum.PetTeamShareReviseType.Skill]
      if LostDataTypeNum > num then
        Text = string.format(LuaText.lineup_code_skill_lack, LostList[PetUIModuleEnum.PetTeamShareReviseType.Skill]) .. "\n"
      else
        Text = string.format(LuaText.lineup_code_skill_lack, LostList[PetUIModuleEnum.PetTeamShareReviseType.Skill])
      end
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    self.ContentText_1:SetText(ContentDiffListText)
    self:SetCommonPopUpInfo(self.PopUp3, LuaText.lineup_code_all_lack)
  end
  self:LoadAnimation(0)
end

function UMG_DifferenceContent_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  if 1 == self.openType then
    CommonPopUpData.Btn_LeftHandler = self.OnIgnoreAll
    CommonPopUpData.Btn_RightHandler = self.OnTrySolveAll
  elseif 2 == self.openType then
    CommonPopUpData.Btn_LeftHandler = self.AutoSolveLostData
    CommonPopUpData.Btn_RightHandler = self.OpenQuickLearnAllLostSkillPanel
  end
  if 1 == self.openType then
    CommonPopUpData.Btn_RightText = LuaText.lineup_code_fix_difference
    CommonPopUpData.Btn_LeftText = LuaText.lineup_code_ignore_all
  elseif 2 == self.openType then
    CommonPopUpData.Btn_RightText = LuaText.lineup_code_fix_lack
    CommonPopUpData.Btn_LeftText = LuaText.lineup_code_auto_complete
  end
  CommonPopUpData.ClosePanelHandler = self.OnClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_DifferenceContent_C:OnClosePanel()
  self:LoadAnimation(2)
end

function UMG_DifferenceContent_C:OnIgnoreAll()
  if 1 == self.openType then
    self:DispatchEvent(PetUIModuleEvent.PetShareTeamIgnoreAllDiffType)
  end
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.lineup_code_auto_ignore_difference)
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_DifferenceContent_C:OnIgnoreAll")
end

function UMG_DifferenceContent_C:OnTrySolveAll()
  if 1 == self.openType then
    self:DispatchEvent(PetUIModuleEvent.OpenPetShareTeamSolveAllTypePanel)
  end
end

function UMG_DifferenceContent_C:AutoSolveLostData()
  self:DispatchEvent(PetUIModuleEvent.AutoSolveLostData)
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_DifferenceContent_C:AutoSolveLostData")
end

function UMG_DifferenceContent_C:OpenQuickLearnAllLostSkillPanel()
  self:DispatchEvent(PetUIModuleEvent.OpenQuickLearnAllLostSkillPanel)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_DifferenceContent_C:OpenQuickLearnAllLostSkillPanel")
end

function UMG_DifferenceContent_C:OnDeactive()
end

function UMG_DifferenceContent_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_DifferenceContent_C:OnAddEventListener()
end

return UMG_DifferenceContent_C
