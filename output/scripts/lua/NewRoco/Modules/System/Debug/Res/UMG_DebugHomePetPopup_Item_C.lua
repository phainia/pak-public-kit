local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DebugHomePetPopup_Item_C = Base:Extend("UMG_DebugHomePetPopup_Item_C")

function UMG_DebugHomePetPopup_Item_C:OnConstruct()
  self.homeModule = _G.NRCModuleManager:GetModule("HomeModule")
  self.npcModule = _G.NRCModuleManager:GetModule("NPCModule")
  self:OnAddEventListener()
end

function UMG_DebugHomePetPopup_Item_C:OnDestruct()
end

function UMG_DebugHomePetPopup_Item_C:OnAddEventListener()
  self:AddButtonListener(self.Button, self.OnSetBtnClicked)
end

function UMG_DebugHomePetPopup_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetMainInfo()
end

function UMG_DebugHomePetPopup_Item_C:OnItemSelected(_bSelected)
end

function UMG_DebugHomePetPopup_Item_C:OnDeactive()
end

function UMG_DebugHomePetPopup_Item_C:SetMainInfo()
  if self.uiData.home_pet and self.uiData.home_pet.home_pet_info then
    local homePetInfo = self.uiData.home_pet.home_pet_info
    if homePetInfo.name then
      self.Name:SetText(homePetInfo.name)
    end
  end
  if self.uiData.base then
    local baseInfo = self.uiData.base
    if baseInfo.actor_id then
      local actorId = self.uiData.base.actor_id
      self.pairNPC = self.npcModule:GetNpcByServerID(actorId)
    end
  end
  if self.pairNPC and self.pairNPC.HomePetAttributeComponent then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local playerId = player:GetServerId()
    local AttrComp = self.pairNPC.HomePetAttributeComponent
    local friendliness = AttrComp.FriendlinessCurrent[playerId]
    self.Frindliness_Num:SetText(friendliness)
    local counterPercentage
    if _G.GlobalConfig.bShouldUseGMPetCounterPercentage then
      local actorId = self.uiData.base.actor_id
      counterPercentage = _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.GetGMPetCounterPercentage, actorId)
      if not counterPercentage then
        counterPercentage = self:GetCounterPercentage(friendliness)
      end
    else
      counterPercentage = self:GetCounterPercentage(friendliness)
    end
    if counterPercentage then
      self.CounterStatus_Num:SetText(counterPercentage)
    end
  else
    Log.Error("\230\156\170\232\142\183\229\143\150\229\136\176HomePetAttributeComponent,\233\135\141\230\150\176\230\137\147\229\188\128\228\184\128\230\172\161gm\229\136\183\230\150\176\228\184\139\231\187\132\228\187\182\232\142\183\229\143\150")
  end
end

function UMG_DebugHomePetPopup_Item_C:GetCounterPercentage(friendliness)
  local LowRangeConf = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_attack_low")
  local MiddleRangeConf = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_attack_middle")
  local HighRangeConf = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_attack_high")
  local RangeList = {
    {
      LowRangeConf.numList[1],
      LowRangeConf.numList[2]
    },
    {
      MiddleRangeConf.numList[1],
      MiddleRangeConf.numList[2]
    },
    {
      HighRangeConf.numList[1],
      HighRangeConf.numList[2]
    }
  }
  local ProbabilityConf = {
    LowRangeConf.num,
    MiddleRangeConf.num,
    HighRangeConf.num
  }
  local Level
  for ConfLevel, ConfRange in ipairs(RangeList) do
    if friendliness >= ConfRange[1] and friendliness <= ConfRange[2] then
      Level = ConfLevel
      break
    end
  end
  if not Level then
    Log.Error("\231\174\151\228\184\141\229\135\186\230\157\165\229\165\189\230\132\159\229\186\166\229\164\132\229\156\168\229\147\170\228\184\170\231\173\137\231\186\167\239\188\159\230\163\128\230\159\165\228\184\128\228\184\139\230\149\176\230\141\174\231\156\139\231\156\139")
    return nil
  end
  return math.floor(ProbabilityConf[Level] / 100)
end

function UMG_DebugHomePetPopup_Item_C:OnSetBtnClicked()
  if tonumber(self.Frindliness_Num:GetText()) >= 0 and tonumber(self.Frindliness_Num:GetText()) <= 100 then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local playerId = player:GetServerId()
    local AttrComp = self.pairNPC.HomePetAttributeComponent
    AttrComp:SetFriendliness(playerId, tonumber(self.Frindliness_Num:GetText()))
    Log.Warning("\229\143\139\229\165\189\229\186\166\232\174\190\231\189\174\229\174\140\230\175\149")
  else
    Log.Error("\232\175\183\232\190\147\229\133\1650\229\136\176100\228\185\139\233\151\180\231\154\132\229\143\139\229\165\189\229\186\166")
  end
  if tonumber(self.CounterStatus_Num:GetText()) >= 0 and tonumber(self.CounterStatus_Num:GetText()) <= 100 then
    _G.GlobalConfig.bShouldUseGMPetCounterPercentage = true
    local actorId = self.uiData.base.actor_id
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetGMPetCounterPercentage, actorId, tonumber(self.CounterStatus_Num:GetText()))
    Log.Warning("\229\143\141\229\135\187\230\166\130\231\142\135\232\174\190\231\189\174\229\174\140\230\175\149")
  else
    Log.Error("\232\175\183\232\190\147\229\133\1650\229\136\176100\228\185\139\233\151\180\231\154\132\229\143\141\229\135\187\230\166\130\231\142\135")
  end
end

return UMG_DebugHomePetPopup_Item_C
