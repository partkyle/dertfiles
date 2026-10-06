-- theseus-specific monitor config
-- 4K main display at 1.5 scale
-- 1440p secondary in portrait at 144 Hz

hl.monitor({
	output = "DP-1",
	mode = "3840x2160@240",
	position = "0x0",
	scale = "1",
	bitdepth = 10,
	cm = "hdr",
	sdrbrightness = 1.3,        -- Boosts the general UI brightness profile so it isn't dim
	sdrsaturation = 1.05,       -- Fills out standard sRGB colors mapped to the QD-OLED wide color space
	sdr_min_luminance = 0.0001, -- Tailored to QD-OLED pure black levels
	sdr_max_luminance = 250,    -- Matches your panel's typical full-screen SDR ceiling
	min_luminance = 0.0001,     -- True black reference
	max_luminance = 1000,       -- Use 1000 for Peak 1000 mode, or 460 for True Black 400 mode
})

hl.monitor({
	output = "DP-2",
	mode = "2560x1440@143.91",
	position = "auto",
	scale = "1",
	transform = 3,
})
