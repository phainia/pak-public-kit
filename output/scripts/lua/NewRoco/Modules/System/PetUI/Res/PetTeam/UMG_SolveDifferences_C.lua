local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_SolveDifferences_C = _G.NRCPanelBase:Extend("UMG_SolveDifferences_C")

function UMG_SolveDifferences_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_SolveDifferences_C:OnActive(openType, DiffList, ItemList)
  self.openType = openType
  local ContentDiffListText = LuaText.lineup_code_use_item .. "\n"
  if 1 == self.openType then
    self:SetCommonPopUpInfo(self.PopUp3, LuaText.lineup_code_fix_difference)
    local AllDiffNum = 0
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent] > 0 then
      AllDiffNum = DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent]
      local Text = string.format(LuaText.lineup_code_individual_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Talent])
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature] > 0 then
      AllDiffNum = AllDiffNum + DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature]
      local Text = string.format(LuaText.lineup_code_nature_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Nature])
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood] > 0 then
      AllDiffNum = AllDiffNum + DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood]
      local Text = string.format(LuaText.lineup_code_blood_difference, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Blood])
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    self.AllDiffNum = AllDiffNum
    self.ContentText:SetText(ContentDiffListText)
    self:SetNeedItemIcon(ItemList)
  elseif 2 == self.openType then
    self:SetCommonPopUpInfo(self.PopUp3, LuaText.lineup_code_fix_lack)
    self.lostSkillNum = DiffList[PetUIModuleEnum.PetTeamShareReviseType.Skill]
    if DiffList[PetUIModuleEnum.PetTeamShareReviseType.Skill] and DiffList[PetUIModuleEnum.PetTeamShareReviseType.Skill] > 0 then
      local Text = string.format(LuaText.lineup_code_skill_lack, DiffList[PetUIModuleEnum.PetTeamShareReviseType.Skill])
      ContentDiffListText = string.format("%s%s", ContentDiffListText, Text)
    end
    self:SetNeedItemIcon(ItemList)
    self.ContentText:SetText(ContentDiffListText)
  end
  self:AddButtonListener(self.QuestionMark.btnLevelUp, self.OnOpenDetailsDifferencesPanel)
  self:LoadAnimation(0)
end

function UMG_SolveDifferences_C:SetNeedItemIcon(ItemList)
  local rewardsTable = {}
  for k, v in pairs(ItemList) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = _G.Enum.GoodsType.GT_BAGITEM
    rewards.itemId = k
    rewards.itemNum = v.NeedNum
    rewards.bShowNum = true
    rewards.bShowTip = false
    table.insert(rewardsTable, rewards)
  end
  if #rewardsTable > 6 then
    self.ScrollBox_0.Slot:SetAutoSize(false)
  else
    self.ScrollBox_0.Slot:SetAutoSize(true)
  end
  self.Gridview:InitGridView(rewardsTable)
end

function UMG_SolveDifferences_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnOk
  CommonPopUpData.ClosePanelHandler = self.OnClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_SolveDifferences_C:OnOpenDetailsDifferencesPanel()
  self:DispatchEvent(PetUIModuleEvent.OpenShareTeamDetailsDifferencesPanel, self.openType)
end

function UMG_SolveDifferences_C:OnClosePanel()
  self:LoadAnimation(2)
end

function UMG_SolveDifferences_C:OnCancel()
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_SolveDifferences_C:OnCancel")
end

function UMG_SolveDifferences_C:OnOk()
  if 1 == self.openType then
    self:DispatchEvent(PetUIModuleEvent.SolveAllDiffType)
  elseif 2 == self.openType then
    self:DispatchEvent(PetUIModuleEvent.SolveAllLostType)
  end
end

function UMG_SolveDifferences_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_SolveDifferences_C:OnDeactive()
end

function UMG_SolveDifferences_C:OnAddEventListener()
end

return UMG_SolveDifferences_C
