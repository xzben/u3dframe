
local setmetatable = setmetatable
local UpdateBeat = UpdateBeat
local CoUpdateBeat = CoUpdateBeat
local Time = Time

Timer = {}

local Timer = Timer
local mt = {__index = Timer}

--unscaled false 采用deltaTime计时，true 采用 unscaledDeltaTime计时
function Timer.New(func, duration, loop, unscaled, funcOnStop)
	unscaled = unscaled or false and true	
	loop = loop or 1
	return setmetatable({func = func, funcOnStop = funcOnStop; duration = duration, time = duration, loop = loop, unscaled = unscaled, running = false}, mt)	
end

function Timer:Start()
	self.running = true

	if not self.handle then
		self.handle = UpdateBeat:CreateListener(self.Update, self)
	end

	UpdateBeat:AddListener(self.handle)	
end

function Timer:Reset(func, duration, loop, unscaled, funcOnStop)
	self.duration 	= duration
	self.loop		= loop or 1
	self.unscaled	= unscaled
	self.func		= func
	self.time		= duration
	self.funcOnStop = funcOnStop
end

function Timer:Stop()
	self.running = false

	if self.handle then
		UpdateBeat:RemoveListener(self.handle)	
	end

	if type(self.funcOnStop) == "function" then
		self.funcOnStop()
	end
end

function Timer:Update()
	if not self.running then
		return
	end

	local delta = self.unscaled and Time.unscaledDeltaTime or Time.deltaTime	
	self.time = self.time - delta
	--print("self.time", self.time)
	if self.time <= 0 then
		if true == self.func( delta ) then
			self:Stop()
		end
		--print("call func")
		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end
		
		if self.loop == 0 then
			self:Stop()
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
end

--给协同使用的帧计数timer
FrameTimer = {}

local FrameTimer = FrameTimer
local mt2 = {__index = FrameTimer}

function FrameTimer.New(func, count, loop, funcOnStop)	
	local c = Time.frameCount + count
	loop = loop or 1
	return setmetatable({func = func, funcOnStop = funcOnStop; loop = loop, duration = count, count = c, running = false}, mt2)		
end

function FrameTimer:Reset(func, count, loop, funcOnStop)
	self.func = func
	self.duration = count
	self.loop = loop
	self.count = Time.frameCount + count
	self.funcOnStop = funcOnStop		
end

function FrameTimer:Start()		
	if not self.handle then
		self.handle = CoUpdateBeat:CreateListener(self.Update, self)
	end
	
	CoUpdateBeat:AddListener(self.handle)	
	self.running = true
end

function FrameTimer:Stop()	
	self.running = false

	if self.handle then
		CoUpdateBeat:RemoveListener(self.handle)	
	end

	if type(self.funcOnStop) == "function" then
		self.funcOnStop()
	end
end

function FrameTimer:Update()	
	if not self.running then
		return
	end

	if Time.frameCount >= self.count then
		if true == self.func() then
			self:Stop()
		end	
		
		if self.loop > 0 then
			self.loop = self.loop - 1
		end
		
		if self.loop == 0 then
			self:Stop()
		else
			self.count = Time.frameCount + self.duration
		end
	end
end

CoTimer = {}

local CoTimer = CoTimer
local mt3 = {__index = CoTimer}

function CoTimer.New(func, duration, loop, funcOnStop)	
	loop = loop or 1
	return setmetatable({duration = duration, loop = loop, func = func, funcOnStop = funcOnStop, time = duration, running = false}, mt3)			
end

function CoTimer:Start()		
	if not self.handle then	
		self.handle = CoUpdateBeat:CreateListener(self.Update, self)
	end
	
	self.running = true
	CoUpdateBeat:AddListener(self.handle)	
end

function CoTimer:Reset(func, duration, loop, funcOnStop)
	self.duration 	= duration
	self.loop		= loop or 1	
	self.func		= func
	self.time		= duration
	self.funcOnStop = funcOnStop			
end

function CoTimer:Stop()
	self.running = false

	if self.handle then
		CoUpdateBeat:RemoveListener(self.handle)	
	end

	if type(self.funcOnStop) == "function" then
		self.funcOnStop()
	end
end

function CoTimer:Update()	
	if not self.running then
		return
	end

	if self.time <= 0 then
		if true == self.func() then
			self:Stop()
		end
		
		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end
		
		if self.loop == 0 then
			self:Stop()
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
	
	self.time = self.time - Time.deltaTime
end