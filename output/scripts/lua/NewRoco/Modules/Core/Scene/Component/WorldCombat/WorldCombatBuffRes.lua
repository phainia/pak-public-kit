local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local WorldCombatResLoadComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatResLoadComponent")
local WorldCombatBuffRes = Class("WorldCombatBuffRes")

function WorldCombatBuffRes:Ctor(Parent, Index, Conf)
  self.Parent = Parent
  self.Index = Index
  self.Conf = Conf
  self.FXRes = -1
  self.NPCRes = nil
  self.bIsRawFX = 0 == self.Conf.particle_npc_id
end

function WorldCombatBuffRes:OnInit()
end

function WorldCombatBuffRes:CreateRes()
  local RawPoint = self.Conf.shifting_xyz
  local Offset = UE.FVector(RawPoint[1] or 0, RawPoint[2] or 0, RawPoint[3] or 0)
  local bIsAttach = self.Conf.is_follow
  local Owner = self.Parent:GetBuffOwner()
  if not Owner then
    return
  end
  if self.bIsRawFX then
    if string.IsNilOrEmpty(self.Conf.particle_name) then
      return
    end
    local Comp = self:GetFXComp()
    if not Comp then
      return
    end
    local LocatorName = self.Conf.link_point
    if string.IsNilOrEmpty(LocatorName) then
      LocatorName = "Root"
    end
    local AttachSetting = UE.FAttachmentSetting()
    AttachSetting.IgnoreRotation = false
    AttachSetting.AttachmentType = bIsAttach and UE.EFXAttachmentType.AttachToSocket or UE.EFXAttachmentType.DontAttach
    AttachSetting.RelativeTransform = UE.FTransform(UE.FQuat(), Offset)
    local FxTemplate
    local IsInWorldCombat = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInWorldCombat)
    if IsInWorldCombat then
      local BossID = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetBossID)
      local Boss = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, BossID)
      if Boss then
        FxTemplate = Boss:EnsureComponent(WorldCombatResLoadComponent):GetResAssetByPath(self.Conf.particle_name)
      end
    end
    if not FxTemplate then
      Log.Debug("WorldCombatBuffRes:CreateRes, cannot find loaded HitFx!!!", self.Conf.particle_name)
      self.resRequest = NRCResourceManager:LoadResAsync(self, self.Conf.particle_name, 1, 10, self.FxLoadSuccess, self.FxLoadFailed)
    else
      self.FXRes = Comp:PlayFx_Name_Setting(FxTemplate, LocatorName, AttachSetting, true, 1)
      if self.FXRes < 0 then
        Log.Error("buff\230\146\173\230\148\190\231\137\185\230\149\136\229\164\177\232\180\165", self.Parent.ID, self.Conf.particle_name, "\232\175\183\232\129\148\231\179\187\231\173\150\229\136\146\230\163\128\230\159\165\233\133\141\231\189\174")
      end
    end
  else
    local Owner = self.Parent:GetBuffOwner()
    local Location = Owner:GetActorLocation()
    local FinalLocation = Location + Offset
    local FinalPosition = {
      x = FinalLocation.X,
      y = FinalLocation.Y,
      z = FinalLocation.z
    }
    local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, self.Conf.particle_npc_id, FinalPosition, nil, PriorityEnum.Passive_World_NPC_Close_BP)
    if NPC then
      self.NPCRes = NPC
    else
      Log.Error("buff\229\136\155\229\187\186NPC\229\164\177\232\180\165", self.Parent.ID, self.Conf.particle_npc_id, "\232\175\183\232\129\148\231\179\187\231\173\150\229\136\146\230\163\128\230\159\165\233\133\141\231\189\174")
    end
  end
end

function WorldCombatBuffRes:FxLoadSuccess(req, asset)
  if not self:GetFXComp() then
    Log.Error("WorldCombatBuffRes:FxLoadSuccess: GetFXComp failed!")
    return
  end
  local LocatorName = self.Conf.link_point or "Root"
  local RawPoint = self.Conf.shifting_xyz
  local Offset = UE.FVector(RawPoint[1] or 0, RawPoint[2] or 0, RawPoint[3] or 0)
  local bIsAttach = self.Conf.is_follow
  local AttachSetting = UE.FAttachmentSetting()
  AttachSetting.IgnoreRotation = false
  AttachSetting.AttachmentType = bIsAttach and UE.EFXAttachmentType.AttachToSocket or UE.EFXAttachmentType.DontAttach
  AttachSetting.RelativeTransform = UE.FTransform(UE.FQuat(), Offset)
  self.FXRes = self:GetFXComp():PlayFx_Name_Setting(asset, LocatorName, AttachSetting, true, 1)
  if self.FXRes < 0 then
    Log.Error("buff\230\146\173\230\148\190\231\137\185\230\149\136\229\164\177\232\180\165", self.Parent.ID, self.Conf.particle_name, "\232\175\183\232\129\148\231\179\187\231\173\150\229\136\146\230\163\128\230\159\165\233\133\141\231\189\174")
  end
  Log.Debug("WorldCombatBuffRes:FxLoadSuccess", self.bIsRawFX, self:GetFXComp(), self.FXRes)
end

function WorldCombatBuffRes:FxLoadFailed(req, msg)
  Log.Error("WorldCombatBuffRes:FxLoadFailed: ", msg, req.assetPath)
end

function WorldCombatBuffRes:OnAdd()
  if not self.Parent then
    return
  end
  local Owner = self.Parent:GetBuffOwner()
  local View = Owner and Owner.viewObj
  if View then
    self:CreateRes()
  else
    Owner:AddEventListener(self, NPCModuleEvent.OnViewVisible, self.OnOwnerVisible)
  end
end

function WorldCombatBuffRes:OnOwnerVisible()
  local Owner = self.Parent:GetBuffOwner()
  if not Owner then
    return
  end
  Owner:RemoveEventListener(self, NPCModuleEvent.OnViewVisible, self.OnOwnerVisible)
  self:CreateRes()
end

function WorldCombatBuffRes:OnUpdate()
end

function WorldCombatBuffRes:OnRemove()
  local Owner = self.Parent:GetBuffOwner()
  if Owner then
    Owner:RemoveEventListener(self, NPCModuleEvent.OnViewVisible, self.OnOwnerVisible)
  end
  Log.Debug("WorldCombatBuffRes:OnRemove", self.bIsRawFX, self:GetFXComp(), self.FXRes)
  if self.resRequest then
    NRCResourceManager:UnLoadRes(self.resRequest)
  end
  if self.bIsRawFX then
    local Comp = self:GetFXComp()
    if not Comp then
      return
    end
    if self.FXRes > 0 then
      Comp:StopFx(self.FXRes)
    end
    self.FXRes = -1
  else
    if self.NPCRes then
      _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, self.NPCRes:GetServerId())
    else
      Log.Error("\231\167\187\233\153\164Buff\231\154\132\230\151\182\229\128\153\230\137\190\228\184\141\229\136\176NPC\228\186\134")
    end
    self.NPCRes = nil
  end
end

function WorldCombatBuffRes:GetFXComp()
  local View = self.Parent and self.Parent:GetBuffOwnerView()
  if not View or not UE.UObject.IsValid(View) then
    return
  end
  local FXComp = View.RocoFX or View.FxComponent
  if not FXComp then
    Log.Warning(UE.UObject.GetName(View), "\230\178\161\230\156\137\231\137\185\230\149\136\231\187\132\228\187\182\239\188\140\230\151\160\230\179\149\229\156\168\230\173\164Actor\228\184\138\230\140\130\232\189\189Buff\231\137\185\230\149\136")
  end
  return FXComp
end

return WorldCombatBuffRes
