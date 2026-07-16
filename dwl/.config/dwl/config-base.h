/* dwl config.h — derived from config.def.h, adapted for Hyprland-like keybindings */

#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

/* appearance — Catppuccin Mocha inspired */
static const int sloppyfocus               = 0;  /* focus follows mouse: off (click to focus) */
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 2;
static const float rootcolor[]             = COLOR(0x1e1e2eff); /* base */
static const float bordercolor[]           = COLOR(0x45475aff); /* surface1 */
static const float focuscolor[]            = COLOR(0xcba6f7ff); /* mauve */
static const float urgentcolor[]           = COLOR(0xf38ba8ff); /* red */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

/* tagging — 9 tags, matching 1-9 workspaces */
#define TAGCOUNT (9)

static int log_level = WLR_ERROR;

static const Rule rules[] = {
	/* app_id     title  tags mask  isfloating  monitor */
	{ NULL,       NULL,  0,         0,          -1 },
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* floating */
	{ "[M]",      monocle },
};

/* monitors — defined in host-specific file */

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	.options = "ctrl:nocaps",
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* Use Super (Windows) key as MODKEY to match Hyprland muscle memory */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* programs — matching Hyprland setup */
static const char *termcmd[]  = { "foot", NULL };
static const char *menucmd[]  = { "rofi", "-show", "drun", NULL };
static const char *browsercmd[] = { "brave", NULL };
static const char *filemgr[]  = { "foot", "-e", "yazi", NULL };
static const char *lockcmd[]  = { "quickshell", "--path", "~/.config/quickshell/lock.qml", NULL };

static const Key keys[] = {
	/* ---- launching ----
	 * These are the same sequences used in the Hyprland Lua config */
	{ MODKEY,                    XKB_KEY_Return,      spawn,            {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_space,       spawn,            {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_b,           spawn,            {.v = browsercmd} },
	{ MODKEY,                    XKB_KEY_e,           spawn,            {.v = filemgr} },
	{ MODKEY,                    XKB_KEY_Escape,      spawn,            {.v = lockcmd} },

	/* ---- window management ---- */
	{ MODKEY,                    XKB_KEY_q,           killclient,       {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q,           quit,             {0} },
	{ MODKEY,                    XKB_KEY_f,           togglefullscreen, {0} },
	{ MODKEY,                    XKB_KEY_g,           togglefloating,   {0} },

	/* ---- layout ---- */
	{ MODKEY,                    XKB_KEY_t,           setlayout,        {.v = &layouts[0]} }, /* tile */
	{ MODKEY,                    XKB_KEY_y,           setlayout,        {.v = &layouts[1]} }, /* float */
	{ MODKEY,                    XKB_KEY_u,           setlayout,        {.v = &layouts[2]} }, /* monocle */
	{ MODKEY,                    XKB_KEY_m,           setlayout,        {0} },              /* cycle layouts */
	{ MODKEY,                    XKB_KEY_semicolon,   setlayout,        {0} },              /* cycle layouts (matches Hyprland's togglesplit) */

	/* ---- focus movement (arrow keys + vim-style hjkl) ---- */
	{ MODKEY,                    XKB_KEY_h,           focusstack,       {.i = -1} }, /* left / prev */
	{ MODKEY,                    XKB_KEY_l,           focusstack,       {.i = +1} }, /* right / next */
	{ MODKEY,                    XKB_KEY_k,           focusmon,         {.i = WLR_DIRECTION_UP} },
	{ MODKEY,                    XKB_KEY_j,           focusmon,         {.i = WLR_DIRECTION_DOWN} },
	{ MODKEY,                    XKB_KEY_Left,        focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_Right,       focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY,                    XKB_KEY_Up,          focusmon,         {.i = WLR_DIRECTION_UP} },
	{ MODKEY,                    XKB_KEY_Down,        focusmon,         {.i = WLR_DIRECTION_DOWN} },

	/* ---- window swap / move (shift + vim keys) ---- */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_h,           tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_l,           tagmon,           {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_k,           tagmon,           {.i = WLR_DIRECTION_UP} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_j,           tagmon,           {.i = WLR_DIRECTION_DOWN} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Left,        tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Right,       tagmon,           {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Up,          tagmon,           {.i = WLR_DIRECTION_UP} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Down,        tagmon,           {.i = WLR_DIRECTION_DOWN} },

	/* ---- master area controls ---- */
	{ MODKEY,                    XKB_KEY_i,           incnmaster,       {.i = +1} },
	{ MODKEY,                    XKB_KEY_d,           incnmaster,       {.i = -1} },
	{ MODKEY,                    XKB_KEY_r,           setmfact,         {.f = -0.05f} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_r,           setmfact,         {.f = +0.05f} },

	/* ---- zoom / swap focused with master ---- */
	{ MODKEY,                    XKB_KEY_Return,      zoom,             {0} },

	/* ---- view all tags ---- */
	{ MODKEY,                    XKB_KEY_0,           view,             {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_0,           tag,              {.ui = ~0} },

	/* ---- monitor focus ---- */
	{ MODKEY,                    XKB_KEY_comma,       focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,      focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_comma,       tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_period,      tagmon,           {.i = WLR_DIRECTION_RIGHT} },

	/* ---- tag keys 1-9 (workspace switching) ---- */
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                        0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                            1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                    2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                        3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                       4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                   5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                     6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                      7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                     8),

	/* ---- media / volume / brightness (matches Hyprland binds) ---- */
	{ 0,                        XKB_KEY_XF86AudioRaiseVolume,  spawn,  SHCMD("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+") },
	{ 0,                        XKB_KEY_XF86AudioLowerVolume,  spawn,  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
	{ 0,                        XKB_KEY_XF86AudioMute,         spawn,  SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },
	{ 0,                        XKB_KEY_XF86AudioMicMute,      spawn,  SHCMD("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") },
	{ 0,                        XKB_KEY_XF86MonBrightnessUp,   spawn,  SHCMD("brightnessctl -e4 -n2 set 5%+") },
	{ 0,                        XKB_KEY_XF86MonBrightnessDown, spawn,  SHCMD("brightnessctl -e4 -n2 set 5%-") },
	{ 0,                        XKB_KEY_XF86AudioNext,         spawn,  SHCMD("playerctl next") },
	{ 0,                        XKB_KEY_XF86AudioPause,        spawn,  SHCMD("playerctl play-pause") },
	{ 0,                        XKB_KEY_XF86AudioPlay,         spawn,  SHCMD("playerctl play-pause") },
	{ 0,                        XKB_KEY_XF86AudioPrev,         spawn,  SHCMD("playerctl previous") },

	/* ---- misc ---- */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_e,           quit,             {0} },
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },

	/* ---- VT switching ---- */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
