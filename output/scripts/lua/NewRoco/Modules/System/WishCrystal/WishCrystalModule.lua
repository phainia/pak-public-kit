local WishCrystalModuleEvent = reload("NewRoco.Modules.System.WishCrystal.WishCrystalModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local WishCrystalModule = NRCModuleBase:Extend("WishCrystalModule")

function WishCrystalModule:OnConstruct()
  self.data = self:SetData("WishCrystalModuleData", "NewRoco.Modules.System.WishCrystal.WishCrystalModuleData")
  self.StatusChecker = StatusCheckerGroup({
    StatusCheckerEnum.Catch
  }, Log.LOG_LEVEL.ELogDebug)
  self.DelayList = {}
end

function WishCrystalModule:OnDestruct()
  for _, id in pairs(self.DelayList or {}) do
    if id then
      _G.DelayManager:CancelDelayById(id)
    end
  end
end

function WishCrystalModule:OnActive()
  self:RegisterCmd(_G.WishCrystalModuleCmd.GMAddStarlight, self.OnCmdGMAddStarlight)
  _G.NRCEventCenter:RegisterEvent("WishCrystalModule", self, WishCrystalModuleEvent.WISH_CRYSTAL_SEND_WISHSTAR_EXCHANGE_REQ, self.OnSendWishStarExchangeReq)
  _G.NRCEventCenter:RegisterEvent("WishCrystalModule", self, WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_INIT, self.OnStarligthInfoInit)
  _G.NRCEventCenter:RegisterEvent("WishCrystalModule", self, WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_ON_STARLIGHT_CHANGE, self.OnStarlightChange)
  _G.NRCEventCenter:RegisterEvent("WishCrystalModule", self, NPCModuleEvent.StillCatching, self.UpdateWithCachedNotify)
  _G.NRCEventCenter:RegisterEvent("WishCrystalModule", self, NPCModuleEvent.CatchEndWithoutCondition, self.UpdateWithCachedShareNotify)
  if _G.DataModelMgr.PlayerDataModel.starlightInfo then
    self:OnStarlightChangeNotify(_G.DataModelMgr.PlayerDataModel.starlightInfo)
  end
  _G.DataModelMgr.PlayerDataModel:RemoveStarlightListener()
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_STAR_LIGHT_INFO_NOTIFY, self.OnStarlightChangeNotify)
end

function WishCrystalModule:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, WishCrystalModuleEvent.WISH_CRYSTAL_SEND_WISHSTAR_EXCHANGE_REQ, self.OnSendWishStarExchangeReq)
  _G.NRCEventCenter:UnRegisterEvent(self, WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_INIT, self.OnStarligthInfoInit)
  _G.NRCEventCenter:UnRegisterEvent(self, WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_ON_STARLIGHT_CHANGE, self.OnStarlightChange)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.StillCatching, self.UpdateWithCachedNotify)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.CatchEndWithoutCondition, self.UpdateWithCachedShareNotify)
end

function WishCrystalModule:OnStarlightChangeNotify(rsp)
  if rsp.star_light_info then
    self.data:UpdateStarlightInfo(rsp.star_light_info, rsp.increment_star_light_num, rsp.is_share_from_wild_no_battle)
  end
  if not rsp.is_share_from_wild_no_battle then
    self.StatusChecker:Check(self, self.UpdateWithCachedNotify)
  end
end

function WishCrystalModule:OnSendWishStarExchangeReq()
  self.data.OldMoneyCount = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_DIAMOND) or 0
  local req = _G.ProtoMessage:newZoneWishingStarExchangeReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_WISHING_STAR_EXCHANGE_REQ, req, self, self.OnWishingStarExchangeRsp)
end

function WishCrystalModule:OnWishingStarExchangeRsp(rsp)
  self.data.ExchangeNum = nil
  if 0 == rsp.ret_info.ret_code then
    if rsp.star_light_info then
      self.data:ResetStarlightInfo(rsp.star_light_info)
    end
    if rsp.ret_info and rsp.ret_info.goods_change_info then
      for _, change in pairs(rsp.ret_info.goods_change_info.changes or {}) do
        if change and change.type == ProtoEnum.GoodsType.GT_VITEM and change.id == _G.Enum.VisualItem.VI_DIAMOND then
          if change.num then
            self.data:UpdateWishCrystalNum(change.num)
          end
          break
        end
      end
    end
    _G.NRCEventCenter:DispatchEvent(WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_EXCHANGE, rsp)
  end
end

function WishCrystalModule:UpdateWithCachedNotify()
  for _, info in pairs(self.data.StarlightInfoList or {}) do
    if info and not info.Unlock then
      info.Unlock = true
      local rsp = {
        star_light_info = info.PlayerStarInfo,
        increment_star_light_num = info.IncrementStarlight
      }
      _G.NRCEventCenter:DispatchEvent(WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_INFO_UPDATE, rsp)
      break
    end
  end
end

function WishCrystalModule:UpdateWithCachedShareNotify()
  local delayID = _G.DelayManager:DelayFrames(5, function()
    for _, info in pairs(self.data.StarlightInfoList or {}) do
      if info and not info.Unlock and info.IsShare then
        info.Unlock = true
        local rsp = {
          star_light_info = info.PlayerStarInfo,
          increment_star_light_num = info.IncrementStarlight
        }
        _G.NRCEventCenter:DispatchEvent(WishCrystalModuleEvent.WISH_CRYSTAL_STARLIGHT_INFO_UPDATE, rsp)
        break
      end
    end
  end)
  table.insert(self.DelayList, delayID)
end

function WishCrystalModule:OnStarligthInfoInit(InStarligthInfo)
  self.data:ResetStarlightInfo(InStarligthInfo)
end

function WishCrystalModule:OnStarlightChange()
  local module = _G.NRCModuleManager:GetModule("AreaAndZoneModule")
  if module and module.starlightTimer then
    return
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.viewObj then
    local caster = player.viewObj
    local skillComponent = caster.RocoSkill
    if skillComponent then
      local skillProxy = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Wish/G6_Wish_GetStar01.G6_Wish_GetStar01", skillComponent)
      if skillProxy then
        skillProxy:SetCaster(caster)
        skillProxy:SetPassive(true)
        skillProxy:PlaySkill()
      end
    end
  end
end

function WishCrystalModule:OnCmdGMAddStarlight(add_num)
  if add_num and add_num > 0 then
    local req = _G.ProtoMessage:newZoneGmAddStarLightReq()
    req.add_num = add_num
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_ADD_STAR_LIGHT_REQ, req, self, self.OnGMAddStarlightRsp)
  end
end

function WishCrystalModule:OnGMAddStarlightRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:Log("AddStarlight Succeed")
  else
    self:Log("AddStarlight Failed")
  end
end

return WishCrystalModule
