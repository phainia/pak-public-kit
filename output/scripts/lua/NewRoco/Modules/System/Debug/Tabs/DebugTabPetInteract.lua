local PetSensingComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetSensingComponent")
local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BubbleType = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleType")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local PetSensingActivelyComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetSensingActivelyComponent")
local Base = DebugTabBase
local DebugTabPetInteract = Base:Extend("DebugTabPetInteract")

function DebugTabPetInteract:Ctor()
  Base.Ctor(self)
  self.PetPanelTable = {}
end

function DebugTabPetInteract:SetupTabs()
  self:Add("\228\184\139\230\172\161\228\186\164\228\186\146\231\187\147\230\158\156-\231\178\190\231\129\181\231\164\188\231\137\169", self.SetNextResultTypePetGift, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\152\190\231\164\186\228\186\178\229\175\134\229\186\166\231\173\137\231\186\167\229\146\140\231\187\143\233\170\140\229\128\188", self.ShowIntimacyLevel, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\162\158\229\138\160\228\186\178\229\175\134\229\186\166\231\187\143\233\170\140\229\128\188", self.AddIntimacyLevel, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\174\182\229\155\173\231\178\190\231\129\181\228\186\178\229\175\134\229\186\166\229\146\140\228\186\178\230\152\181\229\186\166", self.ShowIntimacyAndCloseness, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\146\140\229\189\147\229\137\141\231\178\190\231\129\181\228\186\146\229\138\168", self.SelectCurrentPet, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabPetInteract:ShowInteractQuantityWhenChange()
  _G.GlobalConfig.bShowHintWhenInteractQuantityChange = not _G.GlobalConfig.bShowHintWhenInteractQuantityChange
  local statusText = _G.GlobalConfig.bShowHintWhenInteractQuantityChange and "\229\188\128\229\144\175" or "\229\133\179\233\151\173"
  local Info = string.format("\228\186\164\228\186\146\233\135\143\229\143\152\229\140\150\230\152\190\231\164\186\229\183\178%s", statusText)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
end

function DebugTabPetInteract:CheckFinishedInteractNumForAllPet()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:EnsurePetInfoMap()
  local Info = ""
  for id, petInfo in pairs(localPlayer.petInfoMap) do
    local pet = _G.DataModelMgr.PlayerDataModel:GetPetByGid(petInfo.gid)
    Info = string.format("%s\n\231\178\190\231\129\181%s\231\154\132\228\186\178\229\175\134\229\186\166\228\184\186: %d/%d \229\183\178\231\180\175\232\174\161\229\174\140\230\136\144%d\230\172\161\228\186\178\230\152\181\228\186\146\229\138\168", Info, pet.config.name, petInfo.interact_quantity or 0, petInfo.interact_quantity_threshold or 0, petInfo.interact_count or 0)
  end
  Info = string.format("%s\n\228\187\165\228\184\139\230\152\175\228\189\160\232\186\171\228\184\138\231\154\132\231\178\190\231\129\181\228\186\178\229\175\134\229\186\166\228\191\161\230\129\175", Info)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, {Info}, "DebugInfos")
end

function DebugTabPetInteract:CheckFinishedInteractNumForSelectedPet()
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  self:CheckFinishedInteractNumForPet(gid)
end

function DebugTabPetInteract:CheckFinishedInteractNumForPet(gid)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:EnsurePetInfoMap()
  local petInfo = localPlayer.petInfoMap[gid]
  if petInfo then
    local pet = _G.DataModelMgr.PlayerDataModel:GetPetByGid(petInfo.gid)
    local Info = string.format("\231\178\190\231\129\181%s\231\154\132\228\186\178\229\175\134\229\186\166\228\184\186: %d/%d \229\183\178\231\180\175\232\174\161\229\174\140\230\136\144%d\230\172\161\228\186\178\230\152\181\228\186\146\229\138\168", pet.config.name, petInfo.interact_quantity or 0, petInfo.interact_quantity_threshold or 0, petInfo.interact_count or 0)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  end
end

function DebugTabPetInteract:ShowIntimacyLevel()
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  if gid then
    local req = _G.ProtoMessage:newZoneGmQueryPetClosenessReq()
    req.pet_gid = gid
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_QUERY_PET_CLOSENESS_REQ, req, self, self.ShowIntimacyLevelHandler, false, true)
  end
end

function DebugTabPetInteract:ShowIntimacyLevelHandler(rsp)
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  if gid then
    local name = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(gid).name
    if rsp and rsp.closeness_lv and rsp.closeness_exp then
      local Info = string.format("\231\178\190\231\129\181%s\231\154\132\228\186\178\229\175\134\229\186\166\231\173\137\231\186\167\228\184\186: %d\239\188\140\228\186\178\229\175\134\229\186\166\231\187\143\233\170\140\228\184\186: %d", name, rsp.closeness_lv, rsp.closeness_exp)
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
    end
  end
end

function DebugTabPetInteract:AddIntimacyLevel(Name, Panel, InputNumber)
  local text
  if Panel then
    text = Panel:GetInputNumber()
  else
    text = tonumber(InputNumber)
  end
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  if gid then
    if text <= 0 or not text then
      local Info = "\232\190\147\229\133\165\229\128\188\230\151\160\230\149\136\239\188\140\232\175\183\232\190\147\229\133\165\229\164\167\228\186\1420\231\154\132\230\149\176\229\128\188"
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
      return
    end
    local req = _G.ProtoMessage:newZoneGmAddPetClosenessReq()
    local name = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(gid).name
    req.pet_gid = gid
    req.add_exp = text
    local Info = string.format("\229\183\178\231\187\153\231\178\190\231\129\181%s\229\138\160 %d \228\186\178\229\175\134\229\186\166\231\187\143\233\170\140", name, text)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
    _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_ADD_PET_CLOSENESS_REQ, req, false)
  end
end

function DebugTabPetInteract:AddInteractValueForSelectedPet(name, panel, InputNumber)
  local InteractValue
  if panel then
    InteractValue = panel:GetInputNumber()
  else
    InteractValue = tonumber(InputNumber)
  end
  if InteractValue <= 0 or not InteractValue then
    InteractValue = 100
    local Info = "\228\189\191\231\148\168\233\187\152\232\174\164\229\128\188 100"
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  else
    local Info = string.format("\229\162\158\229\138\160\232\135\170\229\174\154\228\185\137\229\128\188: %d", InteractValue)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  end
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_INTERACTION_QUANTITY
  req.param1 = gid
  req.param2 = InteractValue
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabPetInteract:AddInteractTimesForSelectedPet(name, panel, InputNumber)
  local InteractValue
  if panel then
    InteractValue = panel:GetInputNumber()
  else
    InteractValue = tonumber(InputNumber)
  end
  if InteractValue <= 0 or not InteractValue then
    InteractValue = 100
    local Info = "\228\189\191\231\148\168\233\187\152\232\174\164\229\128\188: 100"
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  else
    local Info = string.format("\229\162\158\229\138\160\228\186\146\229\138\168\229\128\188: %d", InteractValue)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
  end
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_PET_INTERACTION_COUNT
  req.param1 = gid
  req.param2 = InteractValue
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabPetInteract:ShowMeInteractResult()
  _G.GlobalConfig.bShowExpandDialogueResult = not _G.GlobalConfig.bShowExpandDialogueResult
  local statusText = _G.GlobalConfig.bShowExpandDialogueResult and "\229\188\128\229\167\139" or "\231\187\147\230\157\159"
  local Info = string.format("%s\229\177\149\231\164\186\231\178\190\231\129\181\228\186\178\230\152\181\228\186\146\229\138\168\229\144\142\229\143\176\233\154\143\230\156\186\231\187\147\230\158\156\nBOND_FIND\231\177\187\229\158\139: %s", statusText, _G.Enum.ActionResultType[_G.Enum.ActionResultType.BOND_FIND])
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
end

function DebugTabPetInteract:SetNextResultTypeNone()
  self:SetNextResultType(_G.Enum.ActionResultType.BOND_NONE)
end

function DebugTabPetInteract:SetNextResultTypeGift()
  self:SetNextResultType(_G.Enum.ActionResultType.BOND_GIFT)
end

function DebugTabPetInteract:SetNextResultTypeFind()
  self:SetNextResultType(_G.Enum.ActionResultType.BOND_FIND)
end

function DebugTabPetInteract:SetNextResultTypeNickName()
  self:SetNextResultType(_G.Enum.ActionResultType.BOND_NICKNAME)
end

function DebugTabPetInteract:SetNextResultTypePetGift()
  self:SetNextResultType(_G.Enum.ActionResultType.BOND_GUESS_PET_GIFT)
end

function DebugTabPetInteract:SetNextResultType(ResultType)
  local gid = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetSelectedPetGid)
  local req = _G.ProtoMessage:newZoneSceneGmReq()
  req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SET_PET_INTERACTION_BOND_TYPE
  req.param1 = gid
  req.param2 = ResultType
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, req, false)
end

function DebugTabPetInteract:ShowIntimacyAndCloseness()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local LocalActorId = localPlayer.serverData.base.actor_id
  localPlayer:EnsurePetInfoMap()
  local Info = ""
  for _, npc in pairs(NPCModule._npcDic) do
    if npc and npc.serverData and npc.serverData.pet_info and npc.serverData.npc_base.create_avatar_id == LocalActorId then
      local PetGid = npc.serverData.pet_info.gid
      local pet_Scene = localPlayer.petInfoMap[PetGid]
      Info = string.format("%s\n\231\178\190\231\129\181%s\231\154\132\228\186\178\229\175\134\229\186\166\228\184\186: %d/%d \228\186\178\230\152\181\229\186\166\228\184\186:%d", Info, npc.config.name, pet_Scene.interact_quantity or 0, pet_Scene.interact_quantity_threshold or 0, npc.serverData.pet_info.closeness_lv or 0)
    end
  end
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, {Info}, "DebugInfos")
end

function DebugTabPetInteract:SelectCurrentPet()
  local gid = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  local req = _G.ProtoMessage:newZoneSelectMainTeamPetReq()
  req.gid = gid
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SELECT_MAIN_TEAM_PET_REQ, req, self, self.OnSelectCurrentPetRsp)
end

function DebugTabPetInteract:OnSelectCurrentPetRsp(Rsp)
  local Info = ""
  if 0 == Rsp.ret_code then
    Info = "DebugTabPetInteract:OnSelectCurrentPetRsp success"
  else
    Info = string.format("DebugTabPetInteract:OnSelectCurrentPetRsp error, ret_code: %d", Rsp.ret_code)
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Info)
end

return DebugTabPetInteract
