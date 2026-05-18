local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_BattlePlayerComponents_C = NRCClass:Extend("BP_BattlePlayerComponents_C")

function BP_BattlePlayerComponents_C:Initialize(Initializer)
  self:Reset()
  self.player = Initializer and Initializer.player
end

function BP_BattlePlayerComponents_C:ReceiveBeginPlay()
  if not self.player or not UE4.UObject.IsValid(self.player.model) then
    Log.Error("zgx player is destroyed!!!")
    return
  end
  self.ClickTipUIActor = self.ClickTipUI:GetUserWidgetObject()
  self.ClickTipUIActor:SetRenderOpacity(0)
  self.SkillPredictionUIActor = self.SkillPredictionUI:GetUserWidgetObject()
  self.SkillPredictionUIActor:SetRenderOpacity(0)
  self.DialogBoxUIActor = self.DialogBoxUI:GetUserWidgetObject()
  self.DialogBoxUIActor:SetRenderOpacity(0)
  local halfHeight = self.player.model:GetHalfHeight() or 0
  
  local function PutToBottom(target)
    local transform = target:GetRelativeTransform()
    local translation = transform.Translation
    translation.Z = translation.Z - halfHeight + 1
    transform.Translation = translation
    target:K2_SetRelativeTransform(transform, false, nil, false)
  end
  
  PutToBottom(self.SelectedOffset)
  PutToBottom(self.SelectMarkerOffset)
  self:HideMark()
end

function BP_BattlePlayerComponents_C:HideMark()
  self:ShowSelectMarker(false)
  self:ShowActiveState(false)
  self:ShowSelectMarker3d(false)
end

function BP_BattlePlayerComponents_C:SetClickTip()
  local MeshComp = self.player.model:GetComponentByClass(UE4.USkeletalMeshComponent)
  local SkeletalMesh = MeshComp and MeshComp.SkeletalMesh
  if SkeletalMesh then
    local Bounds = SkeletalMesh:GetImportedBounds()
    local Origin = -Bounds.Origin
    Origin.X = 0
    Origin.Y = 0
    self.ClickTipUIOffset:K2_SetRelativeLocation(UE4.FVector(0, 0, 0), false, nil, false)
  else
    Log.ErrorFormat("player %s has no skeletal mesh!!", self.player.roleInfo.base.name)
  end
end

function BP_BattlePlayerComponents_C:ShowActiveState(bShow)
  if not self.ActiveFlag then
    Log.Error("BP_BattlePlayerComponents_C:ShowActiveState ActiveFlag is nil!!!")
    return
  end
  self.ActiveFlag:SetVisibility(bShow)
  self.ActiveFlag:SetHiddenInGame(not bShow)
end

function BP_BattlePlayerComponents_C:ShowSelectMarker(bShow)
end

function BP_BattlePlayerComponents_C:ShowSelectMarker3d(bShow)
end

function BP_BattlePlayerComponents_C:ShowClickTipUI(data)
  self.ClickTipUIActor:SetRenderOpacity(1)
  Log.Dump(self.ClickTipUI, 3)
  self.ClickTipUIActor:SetData(data)
end

function BP_BattlePlayerComponents_C:HideClickTipUI()
  self.ClickTipUIActor:SetRenderOpacity(0)
end

function BP_BattlePlayerComponents_C:ShowSkillPredictionUI()
  if self.SkillPredictionUIActor and self.DialogBoxUIActor:IsHide() then
    self.SkillPredictionUIActor:Show()
  end
end

function BP_BattlePlayerComponents_C:HideSkillPredictionUI()
  if self.SkillPredictionUIActor then
    self.SkillPredictionUIActor:Hide()
  end
end

function BP_BattlePlayerComponents_C:UpdateSkillPredictionUI(info)
  if self.SkillPredictionUIActor then
    local pet = _G.BattleManager.battlePawnManager:GetInFieldPet(self.player.teamEnm)
    local data = {}
    data.info = info
    data.pet = pet
    self.SkillPredictionUIActor:SetData(data)
  end
end

function BP_BattlePlayerComponents_C:ShowDialogBoxUI()
  if self.DialogBoxUIActor then
    self.DialogBoxUIActor:Show()
  end
end

function BP_BattlePlayerComponents_C:HideDialogBoxUI()
  if self.DialogBoxUIActor then
    self.DialogBoxUIActor:Hide()
  end
end

function BP_BattlePlayerComponents_C:UpdateDialogBoxUI(text, type)
  if self.DialogBoxUIActor then
    self.DialogBoxUIActor:SetData(text, type)
  end
end

function BP_BattlePlayerComponents_C:GetDialogBoxUIType()
  if self.DialogBoxUIActor then
    return self.DialogBoxUIActor:GetType()
  end
end

function BP_BattlePlayerComponents_C:IsShowClickUI()
  if self.ClickTipUIActor then
    return self.ClickTipUIActor:IsVisible()
  else
    return false
  end
end

function BP_BattlePlayerComponents_C:PlayClickTipUI(Caller, CallBack)
  self.ClickTipUIActor:PlayClickAnim(Caller, CallBack)
end

function BP_BattlePlayerComponents_C:Reset()
  self.ClickTipUIActor = nil
  self.SkillPredictionUIActor = nil
  self.DialogBoxUIActor = nil
  self.marker = nil
end

return BP_BattlePlayerComponents_C
