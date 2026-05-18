local GCloudEndPoints = require("Core.Service.GCloud.GCloudEndPoints")
local JsonUtils = require("Common.JsonUtils")
local MapleTask = Class("MapleTask")

function MapleTask:Ctor()
end

function MapleTask:Start(OpenID, Caller, Callback, LeafID)
  if self.Observer then
    Log.Error("[MapleTask:Start] \229\173\152\229\156\168\233\135\141\229\164\141\232\176\131\231\148\168\239\188\129\233\156\128\232\166\129\230\142\146\230\159\165\228\191\174\230\173\163")
    self:Stop()
  end
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.OnPrePIEEnded, self.Stop)
  local World = _G.UE4Helper.GetCurrentWorld()
  self.Observer = NewObject(UE.UMapleObserver, World, "", "Core.Service.GCloud.MapleObserver", self)
  self.ObServer_Ref = UnLua.Ref(self.Observer)
  UE.UMapleStatics.AddObserver(self.Observer)
  UE.UMapleStatics.EnableManualUpdate(true)
  local InitInfo = UE.TDirInitInfo()
  InitInfo:SetOpenID(OpenID)
  InitInfo:SetUrl(GCloudEndPoints:GetMapleUrl())
  InitInfo.TDirType = 2
  InitInfo.EnableManualUpdate = true
  self.Caller = Caller
  self.Callback = Callback
  if not UE.UMapleStatics.Initialize(InitInfo) then
    Log.Error("Maple\229\136\157\229\167\139\229\140\150\229\164\177\232\180\165...")
    self:FireCallback(false)
    return false
  end
  _G.UpdateManager:Register(self)
  local ServerInfo = string.split(tostring(AppMain.launchParams.servers), "|")
  if 2 == #ServerInfo then
    local TreeID = tonumber(ServerInfo[2])
    if LeafID then
      self:QueryLeaf(TreeID, LeafID)
    else
      self:QueryTree(TreeID)
    end
    self.TreeID = tonumber(ServerInfo[2])
  elseif _G.AppMain:GetAppVersion() then
    if _G.AppMain:GetFormalPipeline() and RocoEnv.IS_SHIPPING then
      if LeafID then
        self:QueryLeaf(2, LeafID)
      else
        self:QueryTree(2)
      end
      self.TreeID = 2
    else
      if LeafID then
        self:QueryLeaf(1, LeafID)
      else
        self:QueryTree(1)
      end
      self.TreeID = 1
    end
  else
    if LeafID then
      self:QueryLeaf(2, LeafID)
    else
      self:QueryTree(2)
    end
    self.TreeID = 2
  end
  return true
end

function MapleTask:QueryTree(TreeID)
  UE.UMapleStatics.QueryTree(TreeID)
end

function MapleTask:QueryLeaf(TreeID, LeafID)
  UE.UMapleStatics.QueryLeaf(TreeID, LeafID)
end

function MapleTask:OnQueryTreeProc(Result, NodeList)
  if not Result:IsSuccess() then
    Log.Error("QueryTree result", Result:IsSuccess(), Result.ErrorCode, Result.Reason)
    self:FireCallback(false, Result)
    return
  end
  local Count = NodeList.NodeList:Length()
  if 0 == Count then
    Log.Error("NodeList is nil QueryTree result", Result:IsSuccess(), Result.ErrorCode, Result.Reason)
    self:FireCallback(false, Result)
    return
  end
  local Payload = {}
  local GroupRegister = {}
  for i = 0, Count - 1 do
    local NodeWrapper = NodeList.NodeList:GetNodeWrapperAtIndex(i)
    if NodeWrapper:IsLeaf() then
      local LeafNode = NodeWrapper:GetLeaf()
      local PlayerRoles
      local Roles = LeafNode.RoleCollection.RoleInfos
      local RoleCount = Roles:Length()
      for j = 0, RoleCount - 1 do
        PlayerRoles = PlayerRoles or {}
        local RoleInfo = Roles:GetRoleInfoAtIndex(j)
        table.insert(PlayerRoles, RoleInfo)
      end
      local Name = tostring(LeafNode.Name)
      local Url, Port = self:SplitUrl(tostring(LeafNode.Url))
      local Platform = tostring(LeafNode.CustomData.Attr1)
      local Environment = tostring(LeafNode.CustomData.Attr2)
      local CustomUserData = JsonUtils.StringToJson(tostring(LeafNode.CustomData.UserData))
      local clb = {}
      if CustomUserData and CustomUserData.clb and #CustomUserData.clb > 0 then
        for _, v in ipairs(CustomUserData.clb) do
          table.insert(clb, v)
        end
      end
      if 2 == self.TreeID then
        table.insert(Payload, {
          group = "\231\142\176\231\189\145\230\156\141",
          id = LeafNode.Id,
          key = Name,
          flag = LeafNode.Flag,
          ip = Url,
          port = Port,
          Roles = PlayerRoles,
          Platform = Platform,
          Environment = Environment,
          typeid = 1,
          zoneid = 1,
          encryptMethod = 3,
          keyMakingMethod = 2,
          clb = clb
        })
      else
        local Group = GroupRegister[LeafNode.ParentId]
        table.insert(Payload, {
          group = Group.Name,
          id = LeafNode.Id,
          key = Name,
          flag = LeafNode.Flag,
          ip = Url,
          port = Port,
          Roles = PlayerRoles,
          Platform = Platform,
          Environment = Environment,
          typeid = 1,
          zoneid = 1,
          clb = clb
        })
      end
    elseif NodeWrapper:IsCategory() and not NodeWrapper:IsRoot() then
      local CategoryNode = NodeWrapper:GetCategory()
      local GroupId = CategoryNode.Id
      local GroupName = GroupRegister[GroupId]
      if not GroupName then
        GroupName = tostring(CategoryNode.Name)
        GroupRegister[GroupId] = {Name = GroupName, Count = 0}
      end
    end
  end
  self:FireCallback(true, Payload)
end

function MapleTask:SplitUrl(Url)
  local Splat = string.Split(Url, ":")
  return Splat[1], tonumber(Splat[2])
end

function MapleTask:OnQueryLeafProc(Result, Node)
  if not Result:IsSuccess() then
    Log.Error("QueryLeaf result", Result:IsSuccess(), Result.ErrorCode, Result.Reason)
    self:FireCallback(false, Result)
    return
  end
  local Payload = {}
  if Node:IsLeaf() then
    local LeafNode = Node:GetLeaf()
    local PlayerRoles
    local Roles = LeafNode.RoleCollection.RoleInfos
    local RoleCount = Roles:Length()
    for j = 0, RoleCount - 1 do
      PlayerRoles = PlayerRoles or {}
      local RoleInfo = Roles:GetRoleInfoAtIndex(j)
      table.insert(PlayerRoles, RoleInfo)
    end
    local Name = tostring(LeafNode.Name)
    local Url, Port = self:SplitUrl(tostring(LeafNode.Url))
    local Platform = tostring(LeafNode.CustomData.Attr1)
    local Environment = tostring(LeafNode.CustomData.Attr2)
    local CustomUserData = JsonUtils.StringToJson(tostring(LeafNode.CustomData.UserData))
    local clb = {}
    if CustomUserData and CustomUserData.clb and #CustomUserData.clb > 0 then
      for _, v in ipairs(CustomUserData.clb) do
        table.insert(clb, v)
      end
    end
    if 2 == self.TreeID then
      table.insert(Payload, {
        group = "\231\142\176\231\189\145\230\156\141",
        id = LeafNode.Id,
        key = Name,
        flag = LeafNode.Flag,
        ip = Url,
        port = Port,
        Roles = PlayerRoles,
        Platform = Platform,
        Environment = Environment,
        typeid = 1,
        zoneid = 1,
        encryptMethod = 3,
        keyMakingMethod = 2,
        clb = clb
      })
    else
      table.insert(Payload, {
        id = LeafNode.Id,
        key = Name,
        flag = LeafNode.Flag,
        ip = Url,
        port = Port,
        Roles = PlayerRoles,
        Platform = Platform,
        Environment = Environment,
        typeid = 1,
        zoneid = 1,
        clb = clb
      })
    end
  end
  self:FireCallback(true, Payload)
end

function MapleTask:Stop()
  Log.Debug("MapleTask:Stop")
  if self.Observer then
    self.Observer:UnInitialize()
    UE.UMapleStatics.RemoveObserver(self.Observer)
    self.Observer = nil
    self.ObServer_Ref = nil
  end
  tcall(self, self.InternalStop)
end

function MapleTask:InternalStop()
  _G.UpdateManager:UnRegister(self)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnPrePIEEnded, self.Stop)
end

function MapleTask:OnTick(DeltaTime)
  UE.UMapleStatics.ManualUpdate()
end

function MapleTask:FireCallback(Success, ...)
  local Callback = self.Callback
  local Caller = self.Caller
  self.Caller = nil
  self.Callback = nil
  self:Stop()
  if not Callback then
    Log.Error("Callback is empty")
    return
  end
  if Caller then
    Callback(Caller, Success, ...)
  else
    Callback(Success, ...)
  end
end

return MapleTask
