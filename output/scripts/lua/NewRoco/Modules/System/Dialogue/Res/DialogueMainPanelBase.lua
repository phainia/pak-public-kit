require("UnLuaEx")
local DialogueConst = require("NewRoco.Modules.System.Dialogue.DialogueConst")
local DialoguePanelBase = require("NewRoco.Modules.System.Dialogue.Res.DialoguePanelBase")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BuffUtils = require("NewRoco.Modules.Core.Battle.Entity.Components.Buff.BuffUtils")
local PetTeamUtils = require("NewRoco.Modules.System.PetUI.Res.PetTeam.PetTeamUtils")
local DialogueMainPanelBase = DialoguePanelBase:Extend("DialogueMainPanelBase")

function DialogueMainPanelBase:OnConstruct()
  self:SetChildViews(self.DialogueSelector)
  DialoguePanelBase.OnConstruct(self)
end

function DialogueMainPanelBase:OnDestruct()
  DialoguePanelBase.OnDestruct(self)
end

function DialogueMainPanelBase:RegisterPropertyMapping()
  self.TypeWritter = self.UMG_DialogueText.TypeWritter
  self.NPC_Name = self.UMG_DialogueText.NPC_Name
  self.NPC_Title = self.UMG_DialogueText.NPC_Title
  self.NameBackground = self.UMG_DialogueText.NameBackground_1 or self.UMG_DialogueText.NameBackground
end

function DialogueMainPanelBase:SetNamePanelVisibility(bVisible)
  if not self.NameBackground then
    return
  end
  if bVisible then
    self.NameBackground:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NameBackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function DialogueMainPanelBase:OnActive(DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
  self:RegisterPropertyMapping()
  DialoguePanelBase.OnActive(self, DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
end

function DialogueMainPanelBase:RefreshView(DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
  local TypeWriter = self:GetTypeWritter()
  if TypeWriter then
    TypeWriter:SetTextStyles()
  end
  self.TriggerEndAnimOnPageEnd = true
  self.DialogueSelector:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self:ShouldStopDialogueTextAnimationDuringRefreshView() then
    self.UMG_DialogueText:StopAllAnimations()
  end
  if self.UMG_DialogueItem then
    self.UMG_DialogueItem:PlayLoopAnimation()
  else
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150UMG_DialogueItem", DialogueConf.id)
  end
  local dialogueEndAnimation = self:GetDialogueTextAnimationEnd()
  if nil ~= dialogueEndAnimation then
    self.UMG_DialogueText:StopAllAnimations()
    self.UMG_DialogueText:PlayAnimation(dialogueEndAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
  end
  DialoguePanelBase.RefreshView(self, DialogueConf, ContextOption, bBlockEnterAnimation, ExtraConf, EnterCallback, EnterCaller)
end

function DialogueMainPanelBase:ShowPvpPetTeamList(DialogueConf)
  if not self.UMG_DialogueText or not self.UMG_DialogueText.PetList then
    return
  end
  if DialogueConf.ui_source_type == Enum.UIsourceType.UIT_PVP_TEAM then
    if DialogueConf.ui_source_type_param1 then
      self.UMG_DialogueText.PetList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local teamType = DialogueConf.ui_source_type_param1
      local canInTeamNum = PetTeamUtils.GetCanInPetNum(teamType)
      local teamInfo = _G.NRCModuleManager:GetModule("PetUIModule"):GetPetTeamUITeamInfo(teamType)
      local mainIdx = teamInfo.main_team_idx
      local team = teamInfo.teams[mainIdx + 1]
      local PetGidList = {}
      if team.pet_infos then
        for _, petGid in pairs(team.pet_infos) do
          table.insert(PetGidList, {
            petGid = petGid.pet_gid
          })
        end
      end
      local count = #PetGidList
      for index = count + 1, canInTeamNum do
        table.insert(PetGidList, {petGid = 0})
      end
      self.UMG_DialogueText.PetList:InitGridView(PetGidList)
    else
      self.UMG_DialogueText.PetList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.UMG_DialogueText.PetList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function DialogueMainPanelBase:ShowName(DialogueConf)
  local DialogueModule = self.module
  local DisplayName = DialogueConf.name
  self:CheckFinalBattleShouldNameMask(DisplayName)
  if DialogueModule then
    local NewName = DialogueModule:GetOverrides("Name", DialogueConf.id)
    if not string.IsNilOrEmpty(NewName) then
      DisplayName = NewName
    end
  end
  if not DisplayName or self.hasNameMask == true then
    self.NPC_Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return false
  else
    self.NPC_Name:SetVisibility(UE4.ESlateVisibility.Visible)
    if "${name}" == DisplayName then
      self.NPC_Name:SetText(DataModelMgr.PlayerDataModel:GetPlayerName())
    else
      self.NPC_Name:SetText(DisplayName)
    end
    return true
  end
end

function DialogueMainPanelBase:ShowTitle(DialogueConf)
  local DialogueModule = self.module
  local DisplayTitle = DialogueConf.title
  if DialogueModule then
    local NewTitle = DialogueModule:GetOverrides("Title", DialogueConf.id)
    if not string.IsNilOrEmpty(NewTitle) then
      DisplayTitle = NewTitle
    end
  end
  if DisplayTitle and "" ~= DisplayTitle then
    self.NPC_Title:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NPC_Title:SetText(DisplayTitle)
    return true
  else
    self.NPC_Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return false
  end
end

function DialogueMainPanelBase:ShowOptions(selectConfs, Option)
  if not self.DialogueSelector then
    Log.Error("\229\175\185\232\175\157\228\184\173\230\151\160\230\179\149\232\142\183\229\143\150\233\128\137\233\161\185\231\187\132\228\187\182,nil")
    return
  end
  if not UE.UObject.IsValid(self.DialogueSelector) then
    Log.Error("\229\175\185\232\175\157\228\184\173\230\151\160\230\179\149\232\142\183\229\143\150\233\128\137\233\161\185\231\187\132\228\187\182,invalid")
    return
  end
  self.DialogueSelector:SetVisibility(UE4.ESlateVisibility.Visible)
  self.DialogueSelector:ShowOptions(selectConfs, Option)
end

function DialogueMainPanelBase:ShowExtraImage(DialogueConf)
  local Pic = DialogueConf.ui_source_type == Enum.UIsourceType.UIT_PIC and DialogueConf.source_param
  if string.IsNilOrEmpty(Pic) then
    if self.BackgroundCapture then
      self.BackgroundCapture:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.ExtraImage_bg then
      self.ExtraImage_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.ExtraImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    if self.BackgroundCapture then
      self.BackgroundCapture:StartCapture()
      self.BackgroundCapture:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.ExtraImage_bg then
      if DialogueConf.show_baseboard then
        self.ExtraImage_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.ExtraImage_bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    self.ExtraImage:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ExtraImage:SetRenderOpacity(1)
    self.ExtraImage:SetPath(Pic)
    if self.PicIn then
      self:PlayAnimation(self.PicIn)
    end
  end
end

function DialogueMainPanelBase:HideNamePanel()
  self:SetNamePanelVisibility(false)
end

function DialogueMainPanelBase:ShowShrinkedNamePanel()
  self:SetNamePanelVisibility(true)
  if self.UMG_DialogueText and self.UMG_DialogueText.NameBackground then
    self.UMG_DialogueText.NameBackground:SetBrushSize(UE4.FVector2D(361, 106))
  end
end

function DialogueMainPanelBase:ShowFullSizeNamePanel()
  self:SetNamePanelVisibility(true)
  if self.UMG_DialogueText and self.UMG_DialogueText.NameBackground then
    self.UMG_DialogueText.NameBackground:SetBrushSize(UE4.FVector2D(361, 115))
  end
end

function DialogueMainPanelBase:ApplyNamePanelChange(DialogueConf)
  if not DialogueConf.title and not DialogueConf.name then
    self:HideNamePanel()
  elseif not DialogueConf.title or not DialogueConf.name then
    self:ShowShrinkedNamePanel()
  else
    self:ShowFullSizeNamePanel()
  end
end

function DialogueMainPanelBase:OnSkipEnterAnimation()
  local dialogueEnterAnimation, rate = self:GetDialogueTextAnimationEnter(true)
  if nil ~= dialogueEnterAnimation then
    self.UMG_DialogueText:StopAllAnimations()
    self.UMG_DialogueText:PlayAnimation(dialogueEnterAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, rate, false)
  end
  local dialogueLoopAnimation = self:GetDialogueTextAnimationLoop(true)
  if nil ~= dialogueLoopAnimation then
    self.UMG_DialogueText:PlayAnimation(dialogueLoopAnimation, 0, 0)
  end
  DialoguePanelBase.OnSkipEnterAnimation(self)
end

function DialogueMainPanelBase:OnPlayEnterAnimation()
  if not DialogueConst.BlockDialogueAnimation then
    local dialogueEnterAnimation, rate = self:GetDialogueTextAnimationEnter(false)
    if nil ~= dialogueEnterAnimation then
      self.UMG_DialogueText:StopAllAnimations()
      self.UMG_DialogueText:PlayAnimation(dialogueEnterAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, rate, false)
    end
    self:PlayAnimation(self.Start_in)
    local dialogueLoopAnimation = self:GetDialogueTextAnimationLoop(false)
    if nil ~= dialogueLoopAnimation then
      self.UMG_DialogueText:PlayAnimation(dialogueLoopAnimation, 0, 0)
    end
  end
  DialoguePanelBase.OnPlayEnterAnimation(self)
end

function DialogueMainPanelBase:OnPlayEndAnimation()
  if not DialogueConst.BlockDialogueAnimation then
    local dialogueEndAnimation = self:GetDialogueTextAnimationEnd(false)
    if nil ~= dialogueEndAnimation then
      self.UMG_DialogueText:StopAllAnimations()
      self.UMG_DialogueText:PlayAnimation(dialogueEndAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
    end
    self:PlayAnimation(self.Start_out)
  end
  DialoguePanelBase.OnPlayEndAnimation(self)
end

function DialogueMainPanelBase:OnDisable()
  self:StopAllAnimations()
  local dialogueEndAnimation = self:GetDialogueTextAnimationEnd(true)
  if nil ~= dialogueEndAnimation then
    self.UMG_DialogueText:StopAllAnimations()
    self.UMG_DialogueText:PlayAnimation(dialogueEndAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
  else
    self.UMG_DialogueText:StopAllAnimations()
  end
  DialoguePanelBase.OnDisable(self)
end

function DialogueMainPanelBase:PlaySelectAnim()
  self:PlayAnimation(self.Select_up)
end

function DialogueMainPanelBase:CheckFinalBattleShouldNameMask(name)
  if BattleUtils.IsFinalBattleP1() then
    local petList
    local petAllTeam = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)
    if petAllTeam and petAllTeam[1] then
      petList = petAllTeam[1].pets
    else
      return
    end
    local hasNameMask = false
    for _, pet in pairs(petList) do
      local buffComponent = pet.buffComponent
      if pet.card.name == name and buffComponent then
        local buffs = buffComponent.buffs
        if buffs then
          for i, buff in ipairs(buffs) do
            if BuffUtils.IsNameInvisibleBuff(buff.id) and buff.stack > 0 and self.UMG_DialogueText.NameMask then
              self.UMG_DialogueText.NameMask:LoadPanel(nil, name, false)
              hasNameMask = true
            end
          end
        end
      end
    end
    if self.UMG_DialogueText.NameMask and false == hasNameMask then
      self.UMG_DialogueText.NameMask:UnLoadPanel(false)
    end
    self.hasNameMask = hasNameMask
  end
end

function DialogueMainPanelBase:ShouldStopDialogueTextAnimationDuringRefreshView()
  return true
end

function DialogueMainPanelBase:GetDialogueTextAnimationEnter(bIsSkip)
  if self.UMG_DialogueText then
    if bIsSkip then
      return self.UMG_DialogueText.In, 999
    end
    return self.UMG_DialogueText.In, 1
  end
  return nil, nil
end

function DialogueMainPanelBase:GetDialogueTextAnimationLoop(bIsSkip)
  if self.UMG_DialogueText then
    return self.UMG_DialogueText.Loop
  end
  return nil
end

function DialogueMainPanelBase:GetDialogueTextAnimationEnd(bIsOnDisable)
  if self.UMG_DialogueText then
    return self.UMG_DialogueText.Out
  end
  return nil
end

return DialogueMainPanelBase
