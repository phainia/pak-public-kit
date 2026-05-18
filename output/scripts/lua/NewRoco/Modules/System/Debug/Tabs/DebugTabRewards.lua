local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local Base = DebugTabBase
local DebugTabRewards = Base:Extend("DebugTabRewards")

function DebugTabRewards:Ctor()
  Base.Ctor(self)
end

function DebugTabRewards:SetupTabs()
  self:Add("\233\135\141\231\189\174\230\149\153\229\173\166\229\165\150\229\138\177\233\162\134\229\143\150\231\138\182\230\128\129", self.ResetTeachingManualRewardState, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "ResetTeachingManualRewardState")
end

function DebugTabRewards:TestTopUpRebate(Name, panel, InputText)
  local function SortCost(a, b)
    return a.origin_price > b.origin_price
  end
  
  local Amt
  if panel then
    Amt = string.split(panel.InputBox:GetText(), " ")
  end
  local content = ""
  if Amt and #Amt > 0 then
    for _, A in ipairs(Amt) do
      local SaveAmt = A and tonumber(A) or 0
      local MallGoods = _G.DataConfigManager:GetAllByName("NORMAL_SHOP_CONF")
      local moneyCost = {}
      for _, v in pairs(MallGoods) do
        if v.price_goods_type == Enum.GoodsType.GT_VITEM and v.price_goods_id == Enum.VisualItem.VI_MONEY then
          table.insert(moneyCost, v)
        end
      end
      table.sort(moneyCost, SortCost)
      local SaveCostTemp = 0
      local Rebate = 0
      if SaveAmt > 2000 then
        Rebate = math.ceil(26688 + (SaveAmt - 2000) * 10 * 1.113)
      else
        for i, v in pairs(moneyCost) do
          if SaveAmt >= v.origin_price and v.item_num > 1 then
            SaveCostTemp = SaveAmt - v.origin_price
            Rebate = v.item_num
            break
          end
          if i == #moneyCost then
            Rebate = SaveAmt * 10
            SaveCostTemp = 0
          end
        end
        while SaveCostTemp > 0 do
          for i, v in pairs(moneyCost) do
            if SaveCostTemp >= v.origin_price and v.item_num > 1 then
              SaveCostTemp = SaveCostTemp - v.origin_price
              Rebate = Rebate + v.item_num
              break
            end
            if i == #moneyCost then
              Rebate = Rebate + SaveCostTemp * 10
              SaveCostTemp = 0
            end
          end
        end
        Rebate = math.ceil(Rebate * 1.2)
      end
      content = content .. A .. ":" .. Rebate .. "\n"
    end
  end
  local Ctx = DialogContext()
  Ctx:SetTitle("\232\191\148\229\136\169\230\181\139\232\175\149"):SetContent(content):SetCloseOnCancel(true):SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabRewards:ResetTeachingManualRewardState()
  local Req = _G.ProtoMessage:newZoneGmResetTeachingTabRewardsReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_RESET_TEACHING_TAB_REWARDS_REQ, Req, self, self.OnResetTeachingTabRewardsRsp)
end

function DebugTabRewards:OnResetTeachingTabRewardsRsp(rsp)
  if rsp and rsp.ret_info and 0 == rsp.ret_info.ret_code then
    Log.Error("\233\135\141\231\189\174\230\149\153\229\173\166\229\165\150\229\138\177\233\162\134\229\143\150\231\138\182\230\128\129\230\136\144\229\138\159")
  else
    Log.Error("\233\135\141\231\189\174\230\149\153\229\173\166\229\165\150\229\138\177\233\162\134\229\143\150\231\138\182\230\128\129\229\164\177\232\180\165")
  end
end

function DebugTabRewards:ShowWhy(Name, Panel)
  local TipsModule = _G.NRCModuleManager:GetModule("TipsModule")
  local Main = _G.NRCModuleManager:GetModule("MainUIModule"):GetPanel("LobbyMain")
  local Show = {
    ["UI_Tips\229\177\149\231\164\186\228\184\173\231\154\132all"] = Main.UMG_LobbyPropTips.allList,
    ["UI_Tips\229\177\149\231\164\186\228\184\173\231\154\132Use"] = Main.UMG_LobbyPropTips.useList,
    ["UI_Tips\229\177\149\231\164\186\228\184\173\231\154\132Pro"] = Main.UMG_LobbyPropTips.PropTipsList
  }
  self:Inspect(Show, "\229\165\150\229\138\177\233\152\159\229\136\151")
end

function DebugTabRewards:PopRewards()
  local Tips = {}
  local BagItems = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BAG_ITEM_CONF):GetAllDatas()
  local Skills = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
  local VisualItems = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.VISUAL_ITEM_CONF):GetAllDatas()
  local PETBASE_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PETBASE_CONF):GetAllDatas()
  local BagKeys = {}
  for k, v in pairs(BagItems) do
    if not string.IsNilOrEmpty(v.icon) then
      table.insert(BagKeys, k)
    end
  end
  local SkillKeys = {}
  for k, v in pairs(Skills) do
    if not string.IsNilOrEmpty(v.icon) then
      table.insert(SkillKeys, k)
    end
  end
  local PetBaseKeys = {}
  for k, v in pairs(PETBASE_CONF) do
    if not string.IsNilOrEmpty(v.ui_icon) then
      table.insert(PetBaseKeys, k)
    end
  end
  for _, _tip in ipairs(Tips) do
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, _tip)
  end
end

function DebugTabRewards:PrintGetPropStats(name, panel)
  local TipsModule = _G.NRCModuleManager:GetModule("TipsModule")
  local Coordinator = TipsModule.TipsCoordinator
  local Ctx = DialogContext()
  local Content = string.format("CachedList:%d;WaitingFinishTips:%d\n", #Coordinator.CachedTipsData:Size(), #Coordinator.WaitingFinishTips)
  Content = string.format("%s; [CachedTipsData]={%s}", Content, tostring(Coordinator.CachedTipsData))
  local WaitingFinishTipsContent = ""
  for i, tip in ipairs(Coordinator.WaitingFinishTips) do
    WaitingFinishTipsContent = string.format("%s;%d=%s", WaitingFinishTipsContent, i, tostring(tip))
  end
  Content = string.format("%s; [WaitingFinishTips]={%s}", Content, WaitingFinishTipsContent)
  local Main = _G.NRCModuleManager:GetModule("MainUIModule"):GetPanel("LobbyMain")
  Content = string.format([[
%s
Main:%s]], Content, Main and "Yes" or "None")
  if Main then
    local PropTips = Main.UMG_LobbyPropTips
    Content = string.format("%s;PropTips:%s", Content, PropTips and "Yes" or "None")
    if PropTips then
      Content = string.format("%s;TipsQueue:%d;allList:%d", Content, #PropTips.PropTipsList, #PropTips.allList)
    end
  end
  Content = string.format([[
%s

AllTipsQueue:%d;WaitQueue:%d]], Content, #Queue.PropTipsList, #Queue.WaitList)
  Ctx:SetContent(Content):SetMode(DialogContext.Mode.OK):SetCallback(self, self.CheckReward)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  NRCEventCenter:DispatchEvent(MainUIModuleEvent.MAINUIOPEN)
  if panel then
    panel:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function DebugTabRewards:UseBagItem(name, panel, InputText)
  local ID
  if panel then
    ID = tonumber(panel.InputBox:GetText())
  else
    ID = tonumber(InputText)
  end
  local Item, Index = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, ID)
  if not Item then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\230\137\190\228\184\141\229\136\176%d", ID))
    return
  end
  local Req = ProtoMessage:newZoneUseBagItemReq()
  Req.gid = Item.gid
  Req.item_conf_id = Item.id
  Req.num = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_USE_BAG_ITEM_REQ, Req, self, self.OnUseItem, true, true)
end

function DebugTabRewards:ClearAllInBag()
  local req = _G.ProtoMessage:newZoneGmClearBagItemReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLEAR_BAG_ITEM_REQ, req, self, self.OnClearAllInBag)
end

function DebugTabRewards:OnUseItem(rsp)
  Log.Dump(rsp, 2, "Use Item Result")
end

function DebugTabRewards:OnClearAllInBag(rsp)
  Log.Dump(rsp, 3, "OnClearAllInBag")
end

function DebugTabRewards:OperateItem(name, panel, InputText)
  local params
  if panel then
    params = string.split(panel.InputBox:GetText(), " ")
  else
    params = InputText
  end
  if #params < 4 then
    Log.ErrorFormat("Operate item failed, invalid input, " .. "eg: <Op> <ItemType> <ItemId> <ItemNum>")
    return
  end
  self:_OperateItem(params[1], params[2], tonumber(params[3]), tonumber(params[4]))
end

function DebugTabRewards:GetTaskTestPetReward()
  self:_OperateItem("ADD", "REWARD", 17095, 1)
end

function DebugTabRewards:GetRoleSpecialReward(name, panel)
  local _DCM = DataConfigManager
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local rewardId = _DCM:GetGlobalConfigByKeyType("special_role_reward", cfgTableId).num
  self:_OperateItem("ADD", "REWARD", rewardId, 1)
end

function DebugTabRewards:OneKeyToUnlockVisit()
  self:_OperateItem("ADD", "VITEM", 10, 20)
  self:_OperateItem("ADD", "VITEM", 20, 5)
end

function DebugTabRewards:OneTestTemporaryHP()
  local action = ProtoMessage:newSpaceAct_AttrChange()
  local attr = ProtoMessage:newActorInfo_Attr()
  attr.attr_present_tag = 0
  attr.attr_type = ProtoEnum.AttrType.ENUM.HpTemporary
  attr.attr_val = 2
  action.actor_id = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_UIN)
  table.insert(action.attrs, attr)
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.PlayerAttrChange, action)
end

function DebugTabRewards:_OperateItem(opType, itemType, itemId, num)
  opType = string.upper(opType)
  _G.NRCModuleManager:DoCmd(DebugModuleCmd.AddRewardInfo, opType, itemType, itemId, num)
end

function DebugTabRewards:AddItem(name, panel, itemID, num)
  if panel then
    local req = ProtoMessage:newZoneGmClientAddItemReq()
    local inputText = panel.InputBox:GetText()
    local numbers = {}
    for number in inputText:gmatch("%d+") do
      table.insert(numbers, tonumber(number))
    end
    req.item_id = numbers[1]
    req.num = numbers[2]
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_ITEM_REQ, req, self, self.GetRsp)
  elseif itemID and num then
    local req = ProtoMessage:newZoneGmClientAddItemReq()
    local IDNum = tonumber(itemID)
    local ItemNum = tonumber(num)
    req.item_id = IDNum
    req.num = ItemNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_ITEM_REQ, req, self, self.GetRsp)
  end
end

function DebugTabRewards:AddReward(name, panel, rewardID, num)
  if panel then
    local req = ProtoMessage:newZoneGmClientAddRewardReq()
    local inputText = panel.InputBox:GetText()
    local numbers = {}
    for number in inputText:gmatch("%d+") do
      table.insert(numbers, tonumber(number))
    end
    req.reward_id = numbers[1]
    req.num = numbers[2]
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_REWARD_REQ, req, self, self.GetRsp)
  elseif rewardID and num then
    local req = ProtoMessage:newZoneGmClientAddRewardReq()
    local IDNum = tonumber(rewardID)
    local RewardNum = tonumber(num)
    req.reward_id = IDNum
    req.num = RewardNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_REWARD_REQ, req, self, self.GetRsp)
  end
end

function DebugTabRewards:GetRsp(rsp)
  Log.Error("DebugTabRewards:GetRsp")
end

return DebugTabRewards
