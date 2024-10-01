export type AssemblyProxy = {
	Attachment: Attachment;
	AlignPosition: AlignPosition;
	AlignOrientation: AlignOrientation;
	BasePart: BasePart;
	CFrame: CFrame;
	Position: Vector3;
	Orientation: Vector3;
	Drop: (self: AssemblyProxy) -> ();
}

if not _G.AssemblyRegistry then
	_G.AssemblyRegistry = setmetatable({}, table.freeze({__mode = "k"}));
end

local function Assembly(root: BasePart): AssemblyProxy
	for k: AssemblyProxy, v: BasePart in next, _G.AssemblyRegistry do
		if v ~= root then continue end
		
		return k;
	end
	
	local ud: AssemblyProxy = newproxy(true);
	
	_G.AssemblyRegistry[ud] = root;
	
	local mt = getmetatable(ud);
	
	function mt:Drop()
		mt.Attachment:Destroy();
		mt = nil;
		_G.AssemblyRegistry[self] = nil;
		self = nil;
	end
	
	local pos: Vector3, rot: Vector3;
	
	function mt.__index(_, k: string): Attachment | AlignPosition | AlignOrientation | BasePart | CFrame | Vector3
		if k == "BasePart" then
			return root;
		elseif k == "CFrame" then
			local rot = rot or root.Orientation * (math.pi / 180);
			
			return CFrame.new(pos or root.Position) * CFrame.fromOrientation(rot.X, rot.Y, rot.Z);
		elseif k == "Position" then
			return pos or root.Position;
		elseif k == "Orientation" then
			return rot or root.Orientation;
		end
		
		return mt[k]
	end
	
	function mt.__newindex(_, k: string, v: CFrame | Vector3): ()
		local t = typeof(v);
		
		if t ~= "CFrame" and t ~= "Vector3" then return end
		
		if k == "CFrame" then
			if t == "CFrame" then
				pos = (v::CFrame).Position;
				rot = Vector3.new((v::CFrame):ToOrientation());
				mt.AlignPosition.Position = pos;
				mt.AlignOrientation.CFrame = v::CFrame;
			else
				pos = v::Vector3;
				rot = Vector3.zero;
				mt.AlignPosition.Position = v::Vector3;
				mt.AlignOrientation = CFrame.identity;
			end
			
			mt.AlignPosition.Enabled = true;
			mt.AlignOrientation.Enabled = true;
		elseif k == "Position" then
			mt.AlignPosition.Position = v::Vector3;
			mt.AlignPosition.Enabled = true;
		elseif k == "Orientation" then
			mt.AlignOrientation.CFrame = t == "CFrame" and v::CFrame or t == "Vector3" and v::Vector3;
			mt.AlignOrientation.Enabled = true;
		end
	end
	
	mt.Attachment = Instance.new("Attachment");
	mt.AlignPosition = Instance.new("AlignPosition");
	mt.AlignOrientation = Instance.new("AlignOrientation");
	table.freeze(mt);
	mt.Attachment.Name = "Assembly";
	mt.Attachment.Parent = root;
	mt.AlignPosition.Enabled = false;
	mt.AlignPosition.RigidityEnabled = true;
	mt.AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment;
	mt.AlignPosition.Attachment0 = mt.Attachment;
	mt.AlignPosition.Parent = mt.Attachment;
	mt.AlignOrientation.Enabled = false;
	mt.AlignOrientation.RigidityEnabled = true;
	mt.AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment;
	mt.AlignOrientation.Attachment0 = mt.Attachment;
	mt.AlignOrientation.Parent = mt.Attachment;
	return ud;
end

return Assembly;
--rektertwo
