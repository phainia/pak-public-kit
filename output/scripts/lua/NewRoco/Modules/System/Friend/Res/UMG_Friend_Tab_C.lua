local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_Friend_Tab_C = _G.NRCViewBase:Extend("UMG_Friend_Tab_C")

function UMG_Friend_Tab_C:OnConstruct()
  self:IsSelect(false)
  self.index = nil
  self:AddButtonListener(self.btnLevelUp, self.OnSelectInfo)
  self.normal = self:GetAnimByIndex(0)
  self.change1 = self:GetAnimByIndex(1)
  self.select_loop = self:GetAnimByIndex(2)
  self.change2 = self:GetAnimByIndex(3)
  self:PlayAnimation(self.change2)
  self.GetCurrentSelectedTabCallback = nil
  self.SetSelectedTabCallback = nil
  self.Caller = nil
end

function UMG_Friend_Tab_C:OnDestruct()
end

function UMG_Friend_Tab_C:PlayUpAnimation()
  self:PlayAnimation(self.Up)
end

function UMG_Friend_Tab_C:PlayPressAnimation()
  self:PlayAnimation(self.Press)
end

function UMG_Friend_Tab_C:PlayLoopAnimation()
  self:PlayAnimation(self.Loop)
end

function UMG_Friend_Tab_C:SetPath(Index, loginChannelType)
  local _Path, _Path1
  if Index == FriendEnum.FriendTab.GameFriend then
    _Path = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_haiyou_png.img_haiyou_png'"
    _Path1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_haoyou1_png.img_haoyou1_png'"
  elseif Index == FriendEnum.FriendTab.PlatformFriend then
    if loginChannelType == Enum.CliLoginChannel.CLC_QQ then
      _Path = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_qq2_png.img_icon_qq2_png'"
      _Path1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_qq1_png.img_icon_qq1_png'"
    elseif loginChannelType == Enum.CliLoginChannel.CLC_WX then
      _Path = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_weixin2_png.img_icon_weixin2_png'"
      _Path1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_weixin1_png.img_icon_weixin1_png'"
    end
  elseif Index == FriendEnum.FriendTab.SearchFriend then
    _Path = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_sousuo_png.img_icon_sousuo_png'"
    _Path1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_sousuo1_png.img_icon_sousuo1_png'"
  elseif Index == FriendEnum.FriendTab.WeGameFriend then
    _Path = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_wegame_png.img_icon_wegame_png'"
    _Path1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_icon_wegame1_png.img_icon_wegame1_png'"
  end
  self.index = Index
  self.Ordinary:SetPath(_Path)
  self.ps:SetPath(_Path1)
end

function UMG_Friend_Tab_C:SetCallbacks(getIndexCallback, setIndexCallback, InCaller)
  self.GetCurrentSelectedTabCallback = getIndexCallback
  self.SetSelectedTabCallback = setIndexCallback
  self.Caller = InCaller
end

function UMG_Friend_Tab_C:OnSelectInfo()
  if not self.GetCurrentSelectedTabCallback then
    Log.Error("UMG_Friend_Tab_C:OnSelectInfo", "GetCurrentSelectedTabCallback is nil")
    return
  end
  local CurSelectTabIndex = self.GetCurrentSelectedTabCallback(self.Caller)
  if CurSelectTabIndex ~= self.index then
    self:OnSelect()
  end
end

function UMG_Friend_Tab_C:OnSelect()
  if not self.SetSelectedTabCallback then
    Log.Error("UMG_Friend_Tab_C:OnSelect", "SetSelectedTabCallback is nil")
    return
  end
  self.SetSelectedTabCallback(self.Caller, self.index)
  self:IsSelect(true)
end

function UMG_Friend_Tab_C:RemoveSelected(_CurItemType)
  if _CurItemType == self.index then
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
    self:IsSelect(false)
  end
end

function UMG_Friend_Tab_C:IsSelect(_IsSelect)
  if _IsSelect then
    self:PlayAnimation(self.change1)
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_Friend_Tab_C:OnDeactive()
end

function UMG_Friend_Tab_C:OnAnimationFinished(Animation)
end

return UMG_Friend_Tab_C
