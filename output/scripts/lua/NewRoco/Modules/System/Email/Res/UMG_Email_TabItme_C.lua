local EmailModuleEvent = require("NewRoco.Modules.System.Email.EmailModuleEvent")
local UMG_Email_TabItme_C = _G.NRCPanelBase:Extend("UMG_Email_TabItme_C")

function UMG_Email_TabItme_C:OnActive(index)
  local MailIconPath = "PaperSprite'/Game/NewRoco/Modules/System/Email/Raw/Frames/img_youjian_png.img_youjian_png'"
  local MailIconPath1 = "PaperSprite'/Game/NewRoco/Modules/System/Email/Raw/Frames/img_youjian1_png.img_youjian1_png'"
  local NoticeIconPath = "PaperSprite'/Game/NewRoco/Modules/System/Email/Raw/Frames/img_gonggao_png.img_gonggao_png'"
  local NoticeIconPath1 = "PaperSprite'/Game/NewRoco/Modules/System/Email/Raw/Frames/img_gonggao1_png.img_gonggao1_png'"
  self.isSelect = false
  if 0 == index then
    self.PitchOn:SetPath(MailIconPath)
    self.Ordinary:SetPath(MailIconPath1)
    self.RedDot:SetupKey(61)
  else
    self.PitchOn:SetPath(NoticeIconPath)
    self.Ordinary:SetPath(NoticeIconPath1)
    self.RedDot:SetupKey(63)
  end
  self:PlayAnimation(self.normal)
  self.moduleData = _G.NRCModuleManager:GetModule("EmailModule"):GetData("EmailModuleData")
  self.index = index
  self:AddButtonListener(self.btnLevelUp, self.OnClickBtn)
end

function UMG_Email_TabItme_C:OnClickBtn()
  local curIndex = self.moduleData:GetTableIndex()
  if curIndex == self.index then
    return
  end
  if self.CanClick and not self.CanClick() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_Email_TabItme_C.OnClickBtn")
  self.moduleData:SetTableIndex(self.index)
  _G.NRCModuleManager:GetModule("EmailModule"):DispatchEvent(EmailModuleEvent.ClickTableNameEvent, true)
end

function UMG_Email_TabItme_C:ShowSelect()
  if self.isSelect == false then
    self:StopAllAnimations()
    self:PlayAnimation(self.change1)
  end
  self.isSelect = true
end

function UMG_Email_TabItme_C:UnShowSelect()
  if self.isSelect == true then
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
  self.isSelect = false
end

function UMG_Email_TabItme_C:OnDeactive()
end

function UMG_Email_TabItme_C:OnAddEventListener()
end

function UMG_Email_TabItme_C:OnConstruct()
end

function UMG_Email_TabItme_C:OnDestruct()
  self:CancelDelay()
end

function UMG_Email_TabItme_C:PlayLoopAnim()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:PlayAnimation(self.select_loop)
  self:CancelDelay()
  self:DelaySeconds(8, self.PlayLoopAnim, self)
end

function UMG_Email_TabItme_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:DelaySeconds(3, function()
      self:PlayLoopAnim()
    end)
  elseif anim == self.change2 then
    self:CancelDelay()
  end
end

function UMG_Email_TabItme_C:SetCanClick(checkFun, checkFunCaller, ...)
  self.CanClick = _G.MakeWeakFunctor(checkFunCaller, checkFun, ...)
end

return UMG_Email_TabItme_C
