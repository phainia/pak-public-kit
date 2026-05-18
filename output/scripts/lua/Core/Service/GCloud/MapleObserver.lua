local MapleObserver = NRCClass()

function MapleObserver:Initialize(Parent)
  self.Parent = Parent
end

function MapleObserver:OnQueryTreeProc(Result, NodeList)
  if not self.Parent then
    Log.Error("MapleObserver:OnQueryTreeProc parent missing...")
    return
  end
  if not self.Parent.OnQueryTreeProc then
    Log.Error("MapleObserver:OnQueryTreeProc parent didn't implement OnQueryTreeProc...")
    return
  end
  self.Parent:OnQueryTreeProc(Result, NodeList)
end

function MapleObserver:OnQueryAllProc(Result, TreeList)
  if not self.Parent then
    Log.Error("MapleObserver:OnQueryAllProc parent missing...")
    return
  end
  if not self.Parent.OnQueryAllProc then
    Log.Error("MapleObserver:OnQueryAllProc parent didn't implement OnQueryAllProc...")
    return
  end
  self.Parent:OnQueryAllProc(Result, TreeList)
end

function MapleObserver:OnQueryLeafProc(Result, Node)
  if not self.Parent then
    Log.Error("MapleObserver:OnQueryLeaf parent missing...")
    return
  end
  if not self.Parent.OnQueryLeafProc then
    Log.Error("MapleObserver:OnQueryLeaf parent didn't implement OnQueryLeaf...")
    return
  end
  self.Parent:OnQueryLeafProc(Result, Node)
end

function MapleObserver:OnGetAccountBatch(Result, Node)
  if not self.Parent then
    Log.Error("MapleObserver:OnGetAccountBatch parent missing...")
    return
  end
  if not self.Parent.OnQueryTreeProc then
    Log.Error("MapleObserver:OnGetAccountBatch parent didn't implement OnGetAccountBatch...")
    return
  end
  self.Parent:OnGetAccountBatch(Result, Node)
end

function MapleObserver:UnInitialize()
  self.Parent = nil
end

return MapleObserver
