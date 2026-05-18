local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Email_ContentItme_C = Base:Extend("UMG_Email_ContentItme_C")

function UMG_Email_ContentItme_C:OnConstruct()
end

function UMG_Email_ContentItme_C:OnDestruct()
end

function UMG_Email_ContentItme_C:OnItemUpdate(_data, datalist, index)
  self.Dialogue:SetText(_data)
end

function UMG_Email_ContentItme_C:OnItemSelected(_bSelected)
end

function UMG_Email_ContentItme_C:OnDeactive()
end

function UMG_Email_ContentItme_C:OnLogin()
end

function UMG_Email_ContentItme_C:OnAnimationFinished(anim)
end

return UMG_Email_ContentItme_C
