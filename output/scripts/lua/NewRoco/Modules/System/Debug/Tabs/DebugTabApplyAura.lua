local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local debugAuraIdInc = 10000
local DebugTabApplyAura = DebugTabBase:Extend("DebugTabApplyAura")

function DebugTabApplyAura:SetupTabs()
  local AuraConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NPC_AURA_CONF):GetAllDatas()
  for Key, Value in pairs(AuraConf) do
    if Value.aura_type == Enum.AuraType.AT_HARM then
      self:Add("+ " .. Key, function(ButtonName, Panel)
        local AuraComp = self:GetPlayer().AuraComponent
        if AuraComp:GetAuraByID(Key) then
          Log.Warning("\229\183\178\230\183\187\229\138\1601\228\184\170\239\188\140\232\175\183\231\167\187\233\153\164\229\144\142\229\134\141\230\183\187\229\138\160")
          return
        end
        local PlayerLoc = self:GetPlayer():GetActorLocation()
        local info = ProtoMessage.newAuraInfo()
        info.pos.x = PlayerLoc.X
        info.pos.y = PlayerLoc.Y
        info.pos.z = PlayerLoc.Z
        info.id = Key
        info.aura_conf_id = Key
        info.enabled = true
        info.belong_actor_id = self:GetNearestNpc().serverData.base.actor_id
        info.create_actor_id = self:GetNearestNpc().serverData.base.actor_id
        AuraComp:AddAura(info)
        UE4Helper.PrintScreenMsg("\230\183\187\229\138\160\229\133\137\231\142\175 " .. Key)
      end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
      self:Add("- " .. Key, function(ButtonName, Panel)
        local AuraComp = self:GetPlayer().AuraComponent
        if not AuraComp:GetAuraByID(Key) then
          Log.Warning("\230\156\170\230\155\190\230\183\187\229\138\160\239\188\140\231\167\187\233\153\164\229\164\177\232\180\165")
          return
        end
        local info = ProtoMessage.newRemoveAuraInfo()
        info.aura_id = Key
        info.reason = ProtoEnum.RemoveAuraReason.DAR_TIMEOUT
        AuraComp:RemoveAura(info)
        UE4Helper.PrintScreenMsg("\231\167\187\233\153\164\229\133\137\231\142\175 " .. Key)
      end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
    end
  end
end

return DebugTabApplyAura
