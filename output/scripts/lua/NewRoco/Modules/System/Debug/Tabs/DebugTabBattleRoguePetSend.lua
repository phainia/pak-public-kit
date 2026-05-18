local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabBattleRoguePetSend = Base:Extend("DebugTabBattleRoguePetSend")

function DebugTabBattleRoguePetSend:Ctor(...)
  Base.Ctor(self, ...)
  self.needRefresh = true
end

function DebugTabBattleRoguePetSend:SetupTabs()
  if not _G.NRCModuleManager:IsModuleActive("BattleRogueModule") then
    return
  end
  if not _G.DataModelMgr.PlayerDataModel then
    return
  end
  local BtnTopic = ""
  local TeamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  if not (TeamInfo and TeamInfo.backpack_info and TeamInfo.backpack_info.pet_gid) or not TeamInfo.pet_data then
    return
  end
  if not next(TeamInfo.backpack_info) then
    return
  end
  local BackPackPetgids = TeamInfo.backpack_info.pet_gid
  local PetDatas = TeamInfo.pet_data
  for _, BackPackPetgid in ipairs(BackPackPetgids) do
    local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(BackPackPetgid)
    if PetData then
      local name = PetData.name
      BtnTopic = string.format("%s-%s", BackPackPetgid, name)
      
      local function callback()
        local req = _G.ProtoMessage:newZonePetDeleteReq()
        req.gid = BackPackPetgid
        _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_PET_DELETE_REQ, req, self, self.OnPetFreeRsp, false, false)
      end
      
      self:Add(BtnTopic, callback, self)
    end
  end
end

function DebugTabBattleRoguePetSend:OnPetFreeRsp(Rsp)
  if 0 ~= Rsp.ret_info.ret_code then
    Log.Error("\229\136\160\233\153\164\229\164\177\232\180\165\228\186\134\239\188\140\230\178\161\229\133\179\231\179\187\229\176\177\232\191\153\230\160\183\229\144\167\239\188\140\229\141\143\232\174\174\230\152\175\229\129\183\230\157\165\231\148\168\231\154\132")
  end
  Log.Warning("\229\133\171\229\164\167\229\139\139\231\171\160\228\188\170\233\128\160\231\154\132\230\148\190\231\148\159\231\178\190\231\129\181\230\147\141\228\189\156\230\136\144\229\138\159")
end

return DebugTabBattleRoguePetSend
