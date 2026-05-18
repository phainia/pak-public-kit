local Base = require("Common.Singleton.Singleton")
local MFBTTemplate = Base:Extend()

function MFBTTemplate:Ctor(name)
  self.name = name or "MFBTTemplate"
  Base.Ctor(self, self.name)
  self.treeTable = {}
end

function MFBTTemplate:GetTree(treeName)
  return self.treeTable[treeName]
end

function MFBTTemplate:CreateTree(treeName, tree)
  self.treeTable[treeName] = tree
  return tree
end

return MFBTTemplate
