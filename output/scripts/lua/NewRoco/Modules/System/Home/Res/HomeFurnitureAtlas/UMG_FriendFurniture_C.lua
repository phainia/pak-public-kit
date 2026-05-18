local UMG_FriendFurniture_C = _G.NRCPanelBase:Extend("UMG_FriendFurniture_C")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")

function UMG_FriendFurniture_C:OnConstruct()
  self:SetChildViews(self.PopUp)
  self.maxIndex = 1
end

function UMG_FriendFurniture_C:OnActive(friendsData, totalFriendNum)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendFurniture_C", self, HomeModuleEvent.OnFriendFurniturePanelScroll, self.SetMaxIndex)
  local initData = table.new(totalFriendNum, 0)
  local totalGet = #friendsData
  self.totalGet = totalGet
  for i = 1, totalGet do
    initData[i] = friendsData[i]
  end
  for i = totalGet + 1, totalFriendNum do
    initData[i] = {}
  end
  self.SeedList:InitList(initData)
  self.initData = initData
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.CloseFriendFurniture
  self.PopUp:SetPanelInfo(CommonPopUpData)
  self:PlayAnimation(self:GetAnimByIndex(0))
end

function UMG_FriendFurniture_C:SetMaxIndex(index)
  self.maxIndex = math.max(index, self.maxIndex)
end

function UMG_FriendFurniture_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, HomeModuleEvent.OnFriendFurniturePanelScroll, self.SetMaxIndex)
end

function UMG_FriendFurniture_C:OnPcClose()
  self:CloseFriendFurniture()
end

function UMG_FriendFurniture_C:CloseFriendFurniture()
  self:PlayAnimation(self:GetAnimByIndex(2))
end

function UMG_FriendFurniture_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.CloseFriendFurniture)
  end
end

function UMG_FriendFurniture_C:RefreshFriendPanel(friendsData)
  local totalGet = #friendsData
  for i = self.totalGet + 1, totalGet do
    self.initData[i] = friendsData[i]
  end
  if not friendsData[1].refreshIndex then
    for i = #self.initData, 1, -1 do
      if not self.initData[i].home_level then
        self.initData[i].Collapsed = true
      else
        break
      end
    end
  end
  self.SeedList:InitList(self.initData, true)
  self.totalGet = totalGet
  if friendsData[1].refreshIndex and not self.initData[self.maxIndex].home_level then
    _G.NRCEventCenter:DispatchEvent(HomeModuleEvent.GetMoreFriendDataByFurnitureId)
  end
end

return UMG_FriendFurniture_C
