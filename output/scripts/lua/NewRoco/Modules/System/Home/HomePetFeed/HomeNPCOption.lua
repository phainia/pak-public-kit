local Class = _G.MakeSimpleClass
local HomeNPCOption = Class("HomeNPCOption")
local HomeNPCActionFac = require("NewRoco.Modules.System.Home.HomeActions.HomeNPCActionFac")

function HomeNPCOption:Ctor(owner, option_id)
  self.optionInfo = nil
  self.optionId = option_id
  self.owner = owner
  self.InteractiveTarget = nil
  self.config = _G.DataConfigManager:GetNpcOptionConf(self.optionId)
  local show_option_rotation = math.clamp(self.config.show_option_rotation, 0, 360)
  self.configRotationCos = math.cos(math.rad(show_option_rotation / 2 or 0))
  local PlayerViewRotation = math.clamp(self.config.vision_range, 0, 360)
  self.PlayerViewRotationCos = math.cos(math.rad(PlayerViewRotation / 2 or 0))
  self.inActionArea = false
  self.bIsHomeNPCOption = true
  self._isShowInterUI = false
  self.optionDistanceLeaveSquared = -1
  self.optionDistance = -1
  self.optionDistanceSquared = -1
  self.CurrentAction = HomeNPCActionFac:Get(self, self.config and self.config.action.action_type, self.owner)
  local PlayerViewRotation = math.clamp(self.config.vision_range, 0, 360)
  self.PlayerViewRotationCos = math.cos(math.rad(PlayerViewRotation / 2 or 0))
end

function HomeNPCOption:GetSquaredDistance()
  if self.optionDistanceLeaveSquared >= 0 then
    return self.optionDistanceSquared, self.optionDistance
  end
  local dist = self.config.option_radius
  if dist > 0 then
    self.optionDistance = dist
    self.optionDistanceSquared = dist * dist
    return self.optionDistanceSquared, self.optionDistance
  end
  local owner = self.owner
  local ownerView = owner and owner.viewObj
  if not ownerView or not UE.UObject.IsValid(ownerView) then
    return 1
  end
  local root = ownerView:K2_GetRootComponent()
  if not root or not UE.UObject.IsValid(root) then
    return 1
  end
  if not root:IsA(UE.UCapsuleComponent) then
    self.optionDistance = dist
    self.optionDistanceSquared = dist * dist
    return self.optionDistanceSquared, self.optionDistance
  else
    local radius = root:GetScaledCapsuleRadius()
    local extraDistConf = _G.DataConfigManager:GetNpcGlobalConfig("auto_cal_option_distance")
    radius = radius + (extraDistConf and extraDistConf.num or 50)
    self.optionDistance = radius
    self.optionDistanceLeaveSquared = radius * radius
    return self.optionDistanceLeaveSquared, self.optionDistance
  end
end

function HomeNPCOption:GetPriority()
  return self.config.option_priority
end

function HomeNPCOption:IsAuto()
  local Type = self.config.npc_interact_type
  if Type == Enum.InteractType.IT_AUTO then
    return true
  elseif Type == Enum.InteractType.IT_AUTOMANUAL then
    return 0 == self:GetExecuteTimes()
  end
  return false
end

function HomeNPCOption:IsManual()
  local Type = self.config.npc_interact_type
  if Type == Enum.InteractType.IT_MANUAL then
    return true
  elseif Type == Enum.InteractType.IT_AUTOMANUAL then
    return self:GetExecuteTimes() > 0
  end
  return false
end

function HomeNPCOption:IsOptionEnable()
  if HomeIndoorSandbox:InOtherHomeIndoor() then
    return false
  end
  return true
end

function HomeNPCOption:OnSetViewObj()
  if self.owner.luaObj and self.owner.luaObj.InitActStatus then
    self.owner.luaObj:InitActStatus(self.optionInfo)
  end
end

function HomeNPCOption:GetSquareDistance()
  if self.optionDistanceSquared >= 0 then
    return self.optionDistanceSquared, self.OptionDistance
  end
  local Dist = self.config.option_radius
  if Dist > 0 then
    self.OptionDistance = Dist
    self.optionDistanceSquared = Dist * Dist
    return self.optionDistanceSquared, self.OptionDistance
  end
  local Owner = self.owner
  local OwnerView = Owner and Owner.viewObj
  if not OwnerView or not UE.UObject.IsValid(OwnerView) then
    return 1
  end
  local Root = OwnerView:K2_GetRootComponent()
  if not Root or not UE.UObject.IsValid(Root) then
    return 1
  end
  if not Root:IsA(UE.UCapsuleComponent) then
    self.OptionDistance = Dist
    self.optionDistanceSquared = Dist * Dist
    return self.optionDistanceSquared, self.OptionDistance
  end
  local Radius = Root:GetScaledCapsuleRadius()
  local ExtraDistConf = _G.DataConfigManager:GetNpcGlobalConfig("auto_cal_option_distance")
  Radius = Radius + (ExtraDistConf and ExtraDistConf.num or 50)
  self.OptionDistance = Radius
  self.optionDistanceSquared = Radius * Radius
  return self.optionDistanceSquared, self.OptionDistance
end

function HomeNPCOption:GetSquaredLeaveDistance()
  if self.optionDistanceLeaveSquared >= 0 then
    return self.optionDistanceLeaveSquared
  end
  local dist = self.config.cancel_option_radius
  if nil ~= dist and dist > 0 then
    self.optionDistanceLeaveSquared = dist * dist
    return self.optionDistanceLeaveSquared
  end
  self.optionDistanceLeaveSquared = self:GetSquareDistance()
  return self.optionDistanceLeaveSquared
end

function HomeNPCOption:OnOptionChanged()
end

function HomeNPCOption:ShouldShowOnUI()
  if not self.owner then
    return false
  end
  return true
end

function HomeNPCOption:ShowUI()
end

function HomeNPCOption:UpdateData(svrData, isReconnect)
end

function HomeNPCOption:OnPlayerEnterActionArea()
  if not self:IsOptionEnable() then
    return
  end
  if not self.CurrentAction then
    Log.Error("self.CurrentAction nil")
    return
  end
  if not self._isShowInterUI then
    self._isShowInterUI = true
    self:AddToInteractUI()
  end
end

function HomeNPCOption:OnPlayerLeaveActionArea()
  if not self:IsOptionEnable() then
    return
  end
  if self.CurrentAction and self.CurrentAction.OnPlayerLeaveArea then
    self.CurrentAction:OnPlayerLeaveArea()
  end
  if self._isShowInterUI then
    self._isShowInterUI = false
    self:RemoveFromInteractUI()
  end
  self.inActionArea = false
end

function HomeNPCOption:AddToInteractUI()
  if not self:ShouldShowOnUI() then
    return
  end
  if self.CurrentAction then
    self.interActionArea = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.AddNPCInteract, self)
  end
end

function HomeNPCOption:RemoveFromInteractUI()
  if self.CurrentAction then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.RemoveNPCInteract, self)
  end
end

function HomeNPCOption:OnOptionAction()
  if not self.owner then
    Log.Error("homeNpc owner nil")
    return
  end
  if _G.NRCPanelManager:GetLoadingPanelCount() > 0 then
    Log.Error("some panel loading now")
    return
  end
  if self.CurrentAction and self.CurrentAction.Execute then
    self.CurrentAction:Execute()
  end
  self:RemoveFromInteractUI()
  self.inActionArea = false
end

function HomeNPCOption:needStatusNotify()
  return false
end

function HomeNPCOption:Destroy()
  self:RemoveFromInteractUI()
  if self.CurrentAction then
    self.CurrentAction = false
  end
end

return HomeNPCOption
