local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_FurnitureDisassemblyPanel_C = _G.NRCPanelBase:Extend("UMG_FurnitureDisassemblyPanel_C")

function UMG_FurnitureDisassemblyPanel_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_FurnitureDisassemblyPanel_C:OnActive()
  _G.NRCEventCenter:RegisterEvent("UMG_FurnitureDisassemblyPanel_C", self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  self:SetCommonPopUpInfo()
  self:RefreshView()
  self:LoadAnimation(0)
end

function UMG_FurnitureDisassemblyPanel_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
end

function UMG_FurnitureDisassemblyPanel_C:OnEnterSceneFinishNtyAck()
  self.bDisableRequest = false
end

function UMG_FurnitureDisassemblyPanel_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnDecompose
  CommonPopUpData.ClosePanelHandler = self.OnBtnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_FurnitureDisassemblyPanel_C:OnCancel()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_FurnitureDisassemblyPanel_C:OnCancel")
  self:OnBtnClose()
end

function UMG_FurnitureDisassemblyPanel_C:RefreshView()
  local data = self.module:GetData()
  local Req = data:GetDecomposeRequestBody(true)
  local DataList = {}
  for i, info in pairs(Req.target_list) do
    local Data = {
      itemType = Enum.GoodsType.GT_BAGITEM,
      itemId = info.item.id,
      itemNum = info.num,
      bShowNum = true,
      bShowGetTag = false,
      IsCanClick = true
    }
    table.insert(DataList, Data)
  end
  if #DataList <= 5 then
    self.FurnitureItem.Slot:SetAutoSize(true)
  else
    self.FurnitureItem.Slot:SetAutoSize(false)
  end
  self.FurnitureItem:InitList(DataList)
  local RewardItemInfoList = data:GetDecomposeReturnItemInfos()
  self.ReturnReward:InitGridView(RewardItemInfoList)
end

function UMG_FurnitureDisassemblyPanel_C:OnDecompose()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_FurnitureDisassemblyPanel_C:OnDecompose")
  if not self.bDisableRequest then
    local Cmd = ProtoCMD.ZoneSvrCmd.ZONE_HOME_WAREHOUSE_DECOMPOSITION_REQ
    local Req = self.module:GetData():GetDecomposeRequestBody()
    local rspWrapper = {}
    rspWrapper.reqMsg = Req
    
    local function OnSvrRspHandle(_rspWrapper, _protoData)
      local Proto = _protoData
      if 0 ~= Proto.ret_info.ret_code then
        if Proto.ret_info.ret_msg ~= "" then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Proto.ret_info.ret_msg)
        end
      else
        if (_protoData.ret_info.goods_reward or {}).rewards then
          _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, _protoData.ret_info.goods_reward.rewards, "")
        end
        self.module:GetData():InitFurnitureBagData()
        self:DispatchEvent(BagModuleEvent.OnFinishDecomposeFurniture)
        self:OnBtnClose()
      end
    end
    
    self.bDisableRequest = _G.ZoneServer:SendWithHandler(Cmd, Req, rspWrapper, OnSvrRspHandle)
  end
end

function UMG_FurnitureDisassemblyPanel_C:OnBtnClose()
  if self.bPendingClose or not self.panelData then
    return
  end
  self.bPendingClose = true
  self:LoadAnimation(2)
end

function UMG_FurnitureDisassemblyPanel_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_FurnitureDisassemblyPanel_C
