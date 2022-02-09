Crossfades.active = Crossfades.active or {}
local dominatingTrack = '@the-track-that-currently-dominates'

local function stopCrossfade(name)
	if not Crossfades.active[name] then return end
	local cf = Crossfades.active[name]
	for trackName, track in pairs(cf) do
		if IsValid(track) then
			track:Stop()
		end
		timer.Remove('cf.' .. name .. '.' .. trackName)
	end
	Crossfades.active[name] = nil
end

local function playTrack(cfName, trackName, cfData, sounds)
	local current, play = 0
	play = function()
		if IsValid(cfData[trackName]) then
			cfData[trackName]:Stop()
		end
		current = current + 1
		if not sounds[current] then return end
		sound.PlayFile(sounds[current][1], 'noblock', function(ch)
			if IsValid(ch) and cfData[dominatingTrack] ~= trackName then
				ch:SetVolume(0)
			end
			cfData[trackName] = ch
			timer.Create('cf.' .. cfName .. '.' .. trackName, sounds[current][2], 1, play)
		end)
	end
	play()
end

local function fmt(str, ...)
	return str:format(...)
end

net.Receive('cf.stop', function()

	local cfName = net.ReadString()
	assert(Crossfades.config[cfName], fmt('Unknown crossfade name %s', cfName))
	local cf = Crossfades.active[cfName]
	assert(cf, fmt('Crossfade %s is not active', cfName))
	local fadeout = net.ReadFloat()
	assert(fadeout >= 0, fmt('Fadeout length should not be negative (%.2fs?)', fadeout))

	if fadeout == 0 then
		return stopCrossfade(cfName)
	end

	local cur = cf[dominatingTrack]
	local start, hookName = SysTime(), 'cf.end' .. cfName
	hook.Add('Think', hookName, function()
		local progress = SysTime() - start
		local val = Lerp(progress / fadeout, 1, 0)
		if IsValid(cf[cur]) then
			cf[cur]:SetVolume(val)
		end
		if progress > fadeout then
			hook.Remove('Think', hookName)
			stopCrossfade(cfName)
		end
	end)

end)


net.Receive('cf.start', function()

	local cfName = net.ReadString()
	assert(Crossfades.config[cfName], fmt('Unknown crossfade name %s', cfName))
	local track = net.ReadString()
	assert(track == '' or Crossfades.config[cfName][track], fmt('Unknown track name %s on crossfade %s', track, cfName))
	local fadein = net.ReadFloat()
	assert(fadein >= 0, fmt('Fadein length should not be negative (%.2fs?)', fadein))


	stopCrossfade(cfName)
	local cf = {}
	Crossfades.active[cfName] = cf
	for trackName, soundsList in pairs(Crossfades.config[cfName]) do
		playTrack(cfName, trackName, cf, soundsList)
	end
	if track == '' then return end
	if fadein == 0 then
		cf[dominatingTrack] = track
		return
	end

	local start, hookName = SysTime(), 'cf.start' .. cfName
	cf[dominatingTrack] = track
	hook.Add('Think', hookName, function()
		local progress = SysTime() - start
		local val = Lerp(progress / fadein, 0, 1)
		if IsValid(cf[track]) then
			cf[track]:SetVolume(val)
		end
		if progress > fadein then
			hook.Remove('Think', hookName)
		end
	end)

end)

net.Receive('cf.redominate', function()

	local cfName = net.ReadString()
	assert(Crossfades.config[cfName], fmt('Unknown crossfade %s', cfName))
	local trackName = net.ReadString()
	assert(Crossfades.config[cfName][trackName], fmt('Unknown track name %s on crossfade %s', trackName, cfName))
	local cf = Crossfades.active[cfName]
	assert(cf, fmt('Crossfade %s is not active', cfName))
	local length = net.ReadFloat()
	assert(length >= 0, fmt('Crossfade length should not be negative (%.2fs?)', length))

	local cur = cf[dominatingTrack]
	cf[dominatingTrack] = trackName

	if length == 0 then
		if IsValid(cf[cur]) then
			cf[cur]:SetVolume(0)
		end
		if IsValid(cf[trackName]) then
			cf[trackName]:SetVolume(1)
		end
		return
	end

	local start = SysTime()
	local hookName = 'cf.redominate' .. math.random(1000000)
	hook.Add('Think', hookName, function()
		local progress = SysTime() - start
		local val = Lerp(progress / length, 0, 1)
		if IsValid(cf[trackName]) then
			cf[trackName]:SetVolume(val)
		end
		if IsValid(cf[cur]) then
			cf[cur]:SetVolume(1-val)
		end
		if progress > length then
			hook.Remove('Think', hookName)
		end
	end)
end)

hook.Add('HUDPaint', 'cfade', function()
	if not Crossfades.debug then return end
	local y = 80
	for cfID, tracks in pairs(Crossfades.active) do
		draw.SimpleText(cfID, 'DermaLarge', 10, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		local x = 20 + select(1, surface.GetTextSize(cfID))
		surface.SetFont('DermaDefault')
		for trackID, track in SortedPairs(tracks) do
			if trackID ~= dominatingTrack then
				local vol = (IsValid(track) and track:GetVolume() or 0) * 65
				local w = select(1, surface.GetTextSize(trackID))
				draw.RoundedBox(0, x, y-35+(65-vol), w, vol, Color(0,0,255))
				draw.SimpleText(trackID, 'DermaDefault', x, y+30, color_white)
				x = x + w + 10
			end
		end
		y = y + 80
	end
end)