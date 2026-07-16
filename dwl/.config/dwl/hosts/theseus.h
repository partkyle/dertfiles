/* theseus (desktop) — 4K main @240Hz + 1440p portrait @144Hz */
static const MonitorRule monrules[] = {
	/* name   mfact  nmaster scale layout       transform                    x     y */
	{ "DP-1", 0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   0,   0 },
	{ "DP-2", 0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_270,   2560,   0 },
};
