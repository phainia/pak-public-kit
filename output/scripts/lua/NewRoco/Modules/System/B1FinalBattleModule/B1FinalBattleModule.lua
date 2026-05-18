local B1FinalBattleModule = NRCModuleBase:Extend("B1FinalBattleModule")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local JsonUtils = require("Common.JsonUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BeastPlayEnterPerform = require("NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPlayEnterPerform")

function B1FinalBattleModule:OnConstruct()
  _G.B1FinalBattleModuleCmd = require("NewRoco.Modules.System.B1FinalBattleModule.B1FinalBattleModuleCmd")
  self.data = self:SetData("B1FinalBattleModuleData", "NewRoco.Modules.System.B1FinalBattleModule.B1FinalBattleModuleData")
  self:RegPanel("TwoScreenDialogue", "UMG_TwoScreenDialogue", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:AddEventListener()
end

function B1FinalBattleModule:RegPanel(name, path, layer, OpenAnimName, CloseAnimName, isSingleTouchPanel, customDisableRendering, enablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/B1FinalBattleModule/Res/%s", path)
  registerData.panelLayer = layer
  registerData.openAnimName = OpenAnimName
  registerData.closeAnimName = CloseAnimName
  registerData.isSingleTouchPanel = isSingleTouchPanel
  registerData.customDisableRendering = customDisableRendering or false
  if nil == enablePcEsc then
    enablePcEsc = false
  end
  registerData.enablePcEsc = enablePcEsc
  self:RegisterPanel(registerData)
end

function B1FinalBattleModule:AddEventListener()
end

function B1FinalBattleModule:OnOpenTwoScreenDialogue(...)
  self:OpenPanel("TwoScreenDialogue", ...)
end

function B1FinalBattleModule:OnCloseTwoScreenDialogue()
  local hasPanel = self:HasPanel("TwoScreenDialogue")
  if hasPanel then
    self:ClosePanel("TwoScreenDialogue")
  end
end

function B1FinalBattleModule:OnOpenTwoPetDialogueCamera()
  self:LoadTwoPetG6()
end

function B1FinalBattleModule:LoadTwoPetG6()
  local class = _G.BattleSkillManager:GetLoadedClass(_G.BattleConst.B1P3TwoPetCamG6)
  if class then
    self:LoadTwoPetG6Over(nil, class)
  else
    Log.Error("\233\162\132\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165 path=", _G.BattleConst.B1P3TwoPetCamG6, "\230\163\128\230\159\165\230\152\175\229\144\166\230\152\175\228\187\142p2\232\191\155\229\133\165p3\230\181\129\231\168\139")
  end
end

function B1FinalBattleModule:LoadTwoPetG6Over(resRequest, asset)
  self.TwoPetSkillClass = asset
  self.TwoPetSkillClassRef = asset and UnLua.Ref(asset)
  self:OnOpenTwoScreenDialogue(function(widget)
    self.PetDialogueHud = widget
    self:LoadTwoPetHudOver()
  end)
end

function B1FinalBattleModule:LoadTwoPetHudOver()
  local IsBattle = _G.NRCModuleManager:DoCmd(BattleModuleCmd.IsInBattle)
  if not IsBattle then
    self:OnCloseTwoScreenDialogue()
    return
  end
  if not _G.BattleManager.vBattleField then
    self:OnCloseTwoScreenDialogue()
    return
  end
  self.SkillComponent = _G.BattleManager.vBattleField.battleFieldActor.Skill
  if not self.SkillComponent then
    Log.Error("B1FinalBattleModule:LoadTwoPetHudOver self.SkillComponent is nil")
    self:OnCloseTwoScreenDialogue()
    return
  end
  self.Skill = self.SkillComponent:FindOrAddSkillObj(self.TwoPetSkillClass)
  local Characters = _G.BattleManager.battlePawnManager:GetAllPawnActorForSkill()
  self.Skill:SetCharacters(Characters)
  self.Skill:RegisterEventCallback("PostStart", self, self.TwoPetCameraStart)
  self.Skill:RegisterEventCallback("End", self, self.TwoPetCameraEnd)
  self.SkillComponent:LoadAndPlaySkill(self.Skill)
end

function B1FinalBattleModule:AdaptFourScreen(skill)
  local actions = skill:GetAllActions()
  local index = 1
  for i = 1, actions:Length() do
    local action = actions:Get(i)
    if action:IsA(UE4.URocoCameraCurveAction) and action.SceneCaptureSetting.bUseSceneCapture and action.SceneCaptureSetting.bUseViewportSize then
      action.SceneCaptureSetting.ViewportRTSize.X = self.PlayerWidthRatio[index] or 0.25
      index = index + 1
    end
  end
end

function B1FinalBattleModule:InitEnterHud()
  local FourImage = {
    self.PetDialogueHud.Pet1,
    self.PetDialogueHud.Pet2
  }
  local ImageWidth
  self.PlayerWidthRatio = {}
  if self.FourEnterHud then
    for _, v in ipairs(FourImage) do
      ImageWidth = v.Slot.LayoutData.Offsets.Right
      local rtSizeX = BeastPlayEnterPerform.DoGetViewportRTSize(ImageWidth)
      table.insert(self.PlayerWidthRatio, rtSizeX)
    end
  else
    self.PlayerWidthRatio = {0.5, 0.5}
  end
end

function B1FinalBattleModule:OnClearDialogueCamera()
  self:OnCloseTwoScreenDialogue()
  if self.SkillComponent then
    self.SkillComponent:StopCurrentSkill()
  end
end

function B1FinalBattleModule:SaveDialogueCamera(Skill)
end

function B1FinalBattleModule:TwoPetCameraStart(Event, Skill)
  if self.PetDialogueHud then
    self.PetDialogueHud:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function B1FinalBattleModule:TwoPetCameraEnd(Event, Skill)
  self:SaveDialogueCamera(Skill)
  self.g6Request = nil
  self.Skill = nil
  self.SkillComponent = nil
  self.TwoPetSkillClass = nil
  if self.TwoPetSkillClassRef and UE.UObject.IsValid(self.TwoPetSkillClassRef) then
    UnLua.Unref(self.TwoPetSkillClassRef)
  end
  self.TwoPetSkillClassRef = nil
end

function B1FinalBattleModule:OnSetFirstEnterP2Battle(State)
  self.isFirstEnterB1FinalBattleP2 = State
end

function B1FinalBattleModule:OnGetFirstEnterP2Battle()
  return self.isFirstEnterB1FinalBattleP2
end

function B1FinalBattleModule:OnSetIsFirstDialogue(State)
  self.isFirstDialogue = State
end

function B1FinalBattleModule:OnGetIsFirstDialogue()
  return self.isFirstDialogue
end

return B1FinalBattleModule
