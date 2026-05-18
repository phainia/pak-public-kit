local Class = _G.MakeSimpleClass
local ShowHideBase = Class("ShowHideBase")

function ShowHideBase:Ctor()
  self.NPCs = setmetatable({}, {__mode = "kv"})
  self.bShouldHideOrShow = false
end

function ShowHideBase:Add(npc)
  if not npc then
    return
  end
  self.NPCs[npc:GetServerId()] = npc
end

function ShowHideBase:Contains(npc)
  if not npc then
    return false
  end
  return 0 ~= self.NPCs[npc:GetServerId()]
end

function ShowHideBase:Remove(npc)
  if not npc then
    return
  end
  self.NPCs[npc:GetServerId()] = nil
end

function ShowHideBase:ShouldPauseTick()
  return true
end

function ShowHideBase:ShouldPauseFind()
  return false
end

function ShowHideBase:GetReason()
  return 0
end

function ShowHideBase:StartHide()
  return true
end

function ShowHideBase:CheckShouldHide(npc)
  return true
end

function ShowHideBase:EndHide()
  self.bShouldHideOrShow = true
end

function ShowHideBase:StartShow()
  return true
end

function ShowHideBase:CheckShouldShow(npc)
  return true
end

function ShowHideBase:EndShow()
  self.bShouldHideOrShow = false
end

return ShowHideBase
