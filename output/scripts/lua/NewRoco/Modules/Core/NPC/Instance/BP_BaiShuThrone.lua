local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local BP_BaiShuThrone = Base:Extend("BP_BaiShuThrone")

function BP_BaiShuThrone:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  if not UE.UObject.IsValid(self.VirtualMesh) or not UE.UObject.IsValid(self.RealMesh) then
    Log.Error("BP_BaiShuThrone:ReceiveBeginPlay: VirtualMesh or RealMesh is not valid")
    return
  end
  self.StoryFlag = self.StoryFlag or 0
  if self.bInitNightmare then
    if not _G.DataModelMgr.PlayerDataModel:HasStoryFlag(self.StoryFlag) then
      if self.ActiveThrone and type(self.ActiveThrone) == "function" and self.SwitchToNightmare and "function" == type(self.SwitchToNightmare) then
        self:ActiveThrone()
        self:SwitchToNightmare()
      end
    elseif self.SwitchToOrigin and "function" == type(self.SwitchToOrigin) then
      self:ActiveThrone()
      self:SwitchToOrigin()
    end
  else
    if self.SwitchToOrigin and "function" == type(self.SwitchToOrigin) then
      self:SwitchToOrigin()
    end
    if not self.OutOfStoryFlagControl then
      if not _G.DataModelMgr.PlayerDataModel:HasStoryFlag(self.StoryFlag) then
        if self.DeactiveThrone and "function" == type(self.DeactiveThrone) then
          self:DeactiveThrone()
        end
      elseif self.ActiveThrone and type(self.ActiveThrone) == "function" then
        self:ActiveThrone()
      end
    else
      if not self.RealMesh:IsVisible() then
        self.RealMesh:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
      end
      if not self.VirtualMesh:IsVisible() then
        self.VirtualMesh:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
      end
    end
  end
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.STORY_FLAG_ADDED, self.OnStoryFlagAdd)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.STORY_FLAG_REMOVED, self.OnStoryFlagRemove)
end

function BP_BaiShuThrone:OnStoryFlagAdd(StoryFlag, bIsHomeOwner)
  if self.OutOfStoryFlagControl then
    return
  end
  local UseSelf = _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(StoryFlag)
  if bIsHomeOwner == UseSelf then
    return
  end
  if StoryFlag == self.StoryFlag and self.ActiveThrone and type(self.ActiveThrone) == "function" then
    self:SwitchToOrigin()
    self:ActiveThrone()
  end
end

function BP_BaiShuThrone:OnStoryFlagRemove(StoryFlag, bIsHomeOwner)
  if self.OutOfStoryFlagControl then
    return
  end
  local UseSelf = _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(StoryFlag)
  if bIsHomeOwner == UseSelf then
    return
  end
  if StoryFlag == self.StoryFlag and self.DeactiveThrone and type(self.DeactiveThrone) == "function" then
    if self.bInitNightmare then
      self:ActiveThrone()
      self:SwitchToNightmare()
    else
      self:SwitchToOrigin()
      self:DeactiveThrone()
    end
  end
end

function BP_BaiShuThrone:ReceiveEndPlay(Reason)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.STORY_FLAG_ADDED, self.OnStoryFlagAdd)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.STORY_FLAG_REMOVED, self.OnStoryFlagRemove)
  Base.ReceiveEndPlay(self, Reason)
end

return BP_BaiShuThrone
