-- theseus-specific monitor config
-- 4K main display at 1.5 scale
-- 1440p secondary in portrait at 144 Hz

hl.monitor({
	output = "DP-1",
	mode = "3840x2160@240",
	position = "0x0",
	scale = "1.5",
})

hl.monitor({
	output = "DP-2",
	mode = "2560x1440@143.91",
	position = "2560x0",
	scale = "1",
	transform = 3,
})
