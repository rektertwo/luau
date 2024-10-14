--optimize 2
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

if not _G.safeAssemblyRegistry then
	_G.safeAssemblyRegistry = {};
end

if not _G.unsafeAssemblyRegistry then
	_G.unsafeAssemblyRegistry = setmetatable({}, table.freeze({__mode = "k"}));
end

local defaultAssemblyProperties = table.freeze({
	attachment = {
		Name = "Assembly";
	}::Attachment;
	alignPosition = {
		Enabled = false;
		RigidityEnabled = true;
		Mode = Enum.PositionAlignmentMode.OneAttachment;
		--MaxForce = math.huge;
		--Responsiveness = 200;
	}::AlignPosition;
	alignOrientation = {
		Enabled = false;
		RigidityEnabled = true;
		Mode = Enum.OrientationAlignmentMode.OneAttachment;
		--MaxTorque = math.huge;
		--Responsiveness = 200;
	}::AlignOrientation;
});

local function Assembly(root: BasePart, safe: boolean?): AssemblyProxy
	local reg = if safe then _G.safeAssemblyRegistry else _G.unsafeAssemblyRegistry;
	
	for k, v in reg do
		if v ~= root then continue end
		
		return k;
	end
	
	local ud = newproxy(true);
	
	reg[ud] = root;
	
	local mt = getmetatable(ud);
	local pos, rot;
	
	function mt.__index(_, k)
		if k == "BasePart" then
			return root;
		elseif k == "CFrame" then
			local rot = rot or math.pi / 180 * root.Orientation;
			
			return CFrame.new(pos or root.Position) * CFrame.fromOrientation(rot.X, rot.Y, rot.Z);
		elseif k == "Position" then
			return pos or root.Position;
		elseif k == "Orientation" then
			return rot or root.Orientation;
		end
		
		return mt[k];
	end
	
	local a0 = Instance.new("Attachment");
	
	for k, v in defaultAssemblyProperties.attachment do
		a0[k] = v;
	end
	
	a0.Parent = root;
	
	local ap = Instance.new("AlignPosition");
	
	for k, v in defaultAssemblyProperties.alignPosition do
		ap[k] = v;
	end
	
	ap.Attachment0 = a0;
	ap.Parent = a0;
	
	local ao = Instance.new("AlignOrientation");
	
	for k, v in defaultAssemblyProperties.alignOrientation do
		ao[k] = v;
	end
	
	ao.Attachment0 = a0;
	ao.Parent = a0;
	
	mt.Attachment = a0;
	mt.AlignPosition = ap;
	mt.AlignOrientation = ao;
	
	function mt.__newindex(_, k, v)
		local t = typeof(v);
		
		if t ~= "CFrame" and t ~= "Vector3" then
			return;
		end
		
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
			ap.Position = if t == "CFrame" then v.Position else v;
			ap.Enabled = true;
		elseif k == "Orientation" then
			if t == "CFrame" then
				ao.CFrame = v;
			else
				local rot = math.pi / 180 * v;
				
				ao.CFrame = CFrame.fromOrientation(rot.X, rot.Y, rot.Z);
			end
			
			ao.Enabled = true;
		end
	end
	
	function mt:Drop()
		mt = nil;
		reg[self] = nil;
		self = nil;
		a0:Destroy();
		a0 = nil;
		ap = nil;
		ao = nil;
	end
	
	table.freeze(mt);
	return ud;
end

return Assembly;
--rektertwo
