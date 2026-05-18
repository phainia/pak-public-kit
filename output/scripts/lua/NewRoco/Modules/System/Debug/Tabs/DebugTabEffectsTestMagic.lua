local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabEffectsTestMagic = Base:Extend("DebugTabEffects")

function DebugTabEffectsTestMagic:SetupTabs()
  self:Add("\232\191\152\229\142\159\233\187\152\232\174\164", self.ResetWand, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\159\230\152\159\233\173\148\230\179\149", self.OverrideStar, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\163\142\229\156\186\233\173\148\230\179\149", self.OverrideWind, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\136\155\233\128\160\233\173\148\230\179\149", self.OverrideCreate, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\182\178\229\140\150\230\156\175", self.OverrideLiquefy, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\133\137\233\173\148\230\179\149", self.OverrideLight, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\149\153\232\168\128\233\173\148\230\179\149", self.OverrideMessage, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabEffectsTestMagic:ResetWand()
  if _G.PlayerModuleCmd then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      localPlayer._OverrideMagic = nil
      Log.Error("\230\137\128\230\156\137\233\173\148\230\179\149\230\129\162\229\164\141\228\184\186\233\187\152\232\174\164")
    end
  end
end

function DebugTabEffectsTestMagic:SetOverrideMagic(MagicType, MagicId)
  if _G.PlayerModuleCmd then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      if not localPlayer._OverrideMagic then
        localPlayer._OverrideMagic = {}
      end
      localPlayer._OverrideMagic[MagicType] = MagicId
      return true
    end
  end
end

function DebugTabEffectsTestMagic:OverrideStar(Name, Panel, InputNumber)
  local Type = ProtoEnum.SceneMagicType.SMT_STAR
  local Id
  if Panel then
    Id = Panel:GetInputNumber(1)
  end
  if self:SetOverrideMagic(Type, Id) then
    Log.Error("\230\152\159\230\152\159\233\173\148\230\179\149\232\174\190\231\189\174\228\184\186", Id)
  end
end

function DebugTabEffectsTestMagic:OverrideWind(Name, Panel, InputNumber)
  local Type = ProtoEnum.SceneMagicType.SMT_WIND
  local Id
  if Panel then
    Id = Panel:GetInputNumber(1)
  end
  if self:SetOverrideMagic(Type, Id) then
    Log.Error("\233\163\142\229\156\186\233\173\148\230\179\149\232\174\190\231\189\174\228\184\186", Id)
  end
end

function DebugTabEffectsTestMagic:OverrideCreate(Name, Panel, InputNumber)
  local Type = ProtoEnum.SceneMagicType.SMT_CREATE
  local Id
  if Panel then
    Id = Panel:GetInputNumber(1)
  end
  if self:SetOverrideMagic(Type, Id) then
    Log.Error("\229\136\155\233\128\160\233\173\148\230\179\149\232\174\190\231\189\174\228\184\186", Id)
  end
end

function DebugTabEffectsTestMagic:OverrideLiquefy(Name, Panel, InputNumber)
  local Type = ProtoEnum.SceneMagicType.SMT_LIQUEFY
  local Id
  if Panel then
    Id = Panel:GetInputNumber(1)
  end
  if self:SetOverrideMagic(Type, Id) then
    Log.Error("\230\182\178\229\140\150\230\156\175\232\174\190\231\189\174\228\184\186", Id)
  end
end

function DebugTabEffectsTestMagic:OverrideLight(Name, Panel, InputNumber)
  local Type = ProtoEnum.SceneMagicType.SMT_LIGHT
  local Id
  if Panel then
    Id = Panel:GetInputNumber(1)
  end
  if self:SetOverrideMagic(Type, Id) then
    Log.Error("\229\133\137\233\173\148\230\179\149\232\174\190\231\189\174\228\184\186", Id)
  end
end

function DebugTabEffectsTestMagic:OverrideMessage(Name, Panel, InputNumber)
  local Type = ProtoEnum.SceneMagicType.SMT_CREATE_MAGIC_MASSAGE
  local Id
  if Panel then
    Id = Panel:GetInputNumber(1)
  end
  if self:SetOverrideMagic(Type, Id) then
    Log.Error("\231\149\153\232\168\128\233\173\148\230\179\149\232\174\190\231\189\174\228\184\186", Id)
  end
end

return DebugTabEffectsTestMagic
