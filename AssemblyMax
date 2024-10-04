export type AssemblyProxy = {
	BasePart: BasePart;
	Attachment: Attachment;
	AlignPosition: AlignPosition;
	AlignOrientation: AlignOrientation;
	CFrame: CFrame;
	Position: Vector3;
	Orientation: Vector3;
	Drop: (self: AssemblyProxy) -> ();
}

if not _G.AssemblyRegistry then
	_G.AssemblyRegistry = setmetatable({}, table.freeze({__mode = "k"}));
end

local function Assembly(root: BasePart): AssemblyProxy
	for k, v in next, _G.AssemblyRegistry do
		if v ~= root then continue end
		
		return k;
	end
	
	local ud = newproxy(true);
	
	_G.AssemblyRegistry[ud] = root;
	
	local mt = getmetatable(ud);
	local pos, rot;
	
	function mt.__index(_, k)
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
		
		return mt[k];
	end
	
	local a0 = Instance.new("Attachment");
	
	a0.Name = "Assembly";
	a0.Parent = root;
	
	local ap = Instance.new("AlignPosition");
	
	ap.Enabled = false;
	ap.Mode = Enum.PositionAlignmentMode.OneAttachment;
	ap.MaxForce = math.huge;
	ap.Responsiveness = 200;
	ap.Attachment0 = a0;
	ap.Parent = a0;
	
	local ao = Instance.new("AlignOrientation");
	
	ao.Enabled = false;
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment;
	ao.MaxTorque = math.huge;
	ao.Responsiveness = 200;
	ao.Attachment0 = a0;
	ao.Parent = a0;
	
	mt.Attachment = a0;
	mt.AlignPosition = ap;
	mt.AlignOrientation = ao;
	
	function mt.__newindex(_, k, v)
		local t = typeof(v);
		
		if t ~= "CFrame" and t ~= "Vector3" then return end
		
		if k == "CFrame" then
			if t == "CFrame" then
				pos = v.Position;
				rot = Vector3.new(v:ToOrientation());
				ap.Position = pos;
				ao.CFrame = v;
			else
				pos = v;
				rot = Vector3.zero;
				ap.Position = v;
				ao.CFrame = CFrame.identity;
			end
			
			ap.Enabled = true;
			ao.Enabled = true;
		elseif k == "Position" then
			ap.Position = t == "Vector3" and v or t == "CFrame" and v.Position;
			ap.Enabled = true;
		elseif k == "Orientation" then
			ao.CFrame = t == "CFrame" and v or t == "Vector3" and v;
			ao.Enabled = true;
		end
	end
	
	function mt:Drop()
		mt = nil;
		_G.AssemblyRegistry[self] = nil;
		self = nil;
		a0:Destroy();
	end
	
	table.freeze(mt);
	return ud;
end

return Assembly;
--rektertwo
