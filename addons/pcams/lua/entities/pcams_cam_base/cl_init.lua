--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

include("shared.lua")

function ENT:Initialize()
	self.hasInitialized = true
	self.RenderTargetID = "pcams_cam_"..self:EntIndex()

	self.RenderTarget = GetRenderTarget(self.RenderTargetID, PerfectCams.Canvas.w, PerfectCams.Canvas.h)
	self.RenderTargetMaterial = CreateMaterial(self.RenderTargetID, "UnlitGeneric", {
		["$basetexture"] = self.RenderTargetID,
	    ["$ignorez"] = true
	})

	PerfectCams.ActiveCamera = self
	self.lastFrame = 0
end

function ENT:Draw()
	if !self.hasInitialized then
		self:Initialize()
	end

	if (self.ProcessPoseParams) then
		self:ProcessPoseParams()
	end

	self:GetCamView()

	self:DrawModel()
end

function ENT:GetRT()
	return self.RenderTarget	
end
function ENT:GetRTMaterial()
	if (PerfectCams.Cameras[self:EntIndex()]) then
		PerfectCams.Cameras[self:EntIndex()].render = true
	end

	return self.RenderTargetMaterial
end


local timePerFrame
function ENT:UpdateRT()
	if (PerfectCams.Config.Cameras.FPS) then
		if (!timePerFrame) then
			timePerFrame = 1/PerfectCams.Config.Cameras.FPS
		end

		local curTime = CurTime()

		if ((curTime - self.lastFrame) < timePerFrame) then return end

		self.lastFrame = curTime
	end

	local camPos, camAng = self:GetCamView()

	render.PushRenderTarget(self:GetRT())
		render.ClearDepth()
		render.Clear(0, 0, 0, 0)
		render.RenderView({
			origin = camPos,
			angles = camAng,
			x = 0, y = 0,
			w = PerfectCams.Canvas.w, h = PerfectCams.Canvas.h,
			drawhud = false,
			drawviewmodel = false
		})

		if (self.PostRender) then
			self:PostRender()
		end
	render.PopRenderTarget()
end

--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
