util.AddNetworkString 'cf.start'
util.AddNetworkString 'cf.stop'
util.AddNetworkString 'cf.redominate'

function Crossfades.Start(cfName, trackToPlay, fadein)
	net.Start('cf.start')
		net.WriteString(cfName)
		net.WriteString(trackToPlay or '')
		net.WriteFloat(fadein or 0)
	net.Broadcast()
end

function Crossfades.Stop(cfName, fadeout)
	net.Start('cf.stop')
		net.WriteString(cfName)
		net.WriteFloat(fadeout or 0)
	net.Broadcast()
end

function Crossfades.Redominate(cfName, trackName, length)
	net.Start('cf.redominate')
		net.WriteString(cfName)
		net.WriteString(trackName)
		net.WriteFloat(length or 0)
	net.Broadcast()
end

hook.Add('PlayerSay', 'cf.debug', function(ply, txt)
	if not Crossfades.debug then return end
	if string.StartWith(txt, 'Crossfades.Start(\'') then
		local name = txt:gmatch('Crossfades%.Start%(\'(.-)\'.-%)')()
		local track = txt:gmatch('Crossfades%.Start%(\'.-\', -\'(.-)\'.-%)')()
		local len = txt:gmatch('Crossfades%.Start%(\'.-\', -\'.-\', -([%d%.]-)%)')()
		ply:ChatPrint(('Starting crossfade %s with first track %s, fadein %.2fs'):format(name, track, tonumber(len) or 0))
		Crossfades.Start(name, track, tonumber(len))
		return ''
	end

	if string.StartWith(txt, 'Crossfades.Redominate(\'') then
		local name = txt:gmatch('Crossfades%.Redominate%(\'(.-)\'.-%)')()
		local track = txt:gmatch('Crossfades%.Redominate%(\'.-\', -\'(.-)\'.-%)')()
		local len = txt:gmatch('Crossfades%.Redominate%(\'.-\', -\'.-\', -([%d%.]-)%)')()
		ply:ChatPrint(('Redominating crossfade %s to %s, length %.2fs'):format(name, track, tonumber(len) or 0))
		Crossfades.Redominate(name, track, tonumber(len))
		return ''
	end

	if string.StartWith(txt, 'Crossfades.Stop(\'') then
		local name = txt:gmatch('Crossfades%.Stop%(\'(.-)\'.-%)')()
		local len = txt:gmatch('Crossfades%.Stop%(\'.-\', -([%d%.]-)%)')()
		ply:ChatPrint(('Stopping crossfade %s, fadeout %.2fs'):format(name, tonumber(len) or 0))
		Crossfades.Stop(name, tonumber(len))
		return ''
	end
end)