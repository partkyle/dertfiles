/* Custom config for dionysus (laptop): eDP-1 @ 1.25 scale for HiDPI.
 * Keybinds ported from Hyprland partkyle.lua where dwl supports them.
 */

/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 0;  /* focus follows mouse: off — use keyboard focus */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const unsigned int borderpx         = 2;  /* border pixel of windows */
static const float rootcolor[]             = COLOR(0x11111bee);
static const float bordercolor[]           = COLOR(0x45475aee);
static const float focuscolor[]            = COLOR(0x89b4faee);
static const float urgentcolor[]           = COLOR(0xf38ba8ee);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f}; /* You can also use glsl colors */

/* tagging - TAGCOUNT must be no greater than 31 */
#define TAGCOUNT (9)

/* logging */
static int log_level = WLR_ERROR;

static const Rule rules[] = {
	/* app_id             title       tags mask     isfloating   monitor */
	{ "Gimp_EXAMPLE",     NULL,       0,            1,           -1 }, /* Start on currently visible tags floating, not tiled */
	{ "firefox_EXAMPLE",  NULL,       1 << 8,       0,           -1 }, /* Start on ONLY tag "9" */
    /* default/example rule: can be changed but cannot be eliminated; at least one rule must exist */
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* monitors */
/* (x=-1, y=-1) is reserved as an "autoconfigure" monitor position indicator
 * WARNING: negative values other than (-1, -1) cause problems with Xwayland clients due to
 * https://gitlab.freedesktop.org/xorg/xserver/-/issues/899 */
static const MonitorRule monrules[] = {
   /* name        mfact  nmaster scale layout       rotate/reflect                x    y */
	{ "eDP-1",    0.55f, 1,      1.25, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	{ NULL,       0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	/* default monitor rule: can be changed but cannot be eliminated; at least one monitor rule must exist */
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
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
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* Use Windows/Super key for MODKEY to match Hyprland muscle memory */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "foot", NULL };
static const char *menucmd[] = { "/bin/sh", "-c", "compgen -c | sort -u | tofi | xargs -r sh -c 'exec \"$0\"'", NULL };
static const char *filemanagercmd[] = { "/bin/sh", "-c", "foot -e yazi", NULL };
static const char *browsercmd[] = { "/bin/sh", "-c", "brave", NULL };
static const char *lockcmd[] = { "/bin/sh", "-c", "swaylock", NULL };
static const char *volupcmd[]  = { "/bin/sh", "-c", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", NULL };
static const char *voldowncmd[] = { "/bin/sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", NULL };
static const char *volmutecmd[] = { "/bin/sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", NULL };
static const char *brightupcmd[]  = { "/bin/sh", "-c", "brightnessctl -e4 -n2 set 5%+", NULL };
static const char *brightdowncmd[] = { "/bin/sh", "-c", "brightnessctl -e4 -n2 set 5%-", NULL };

static const Key keys[] = {
	/* Note that Shift changes certain key codes: 2 -> at, etc. */
	/* modifier                  key                  function          argument */

	/* --- Launcher / Terminal --- */
	{ MODKEY,                    XKB_KEY_p,           spawn,            {.v = menucmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,      spawn,            {.v = termcmd} },

	/* --- Navigation (focus) --- */
	{ MODKEY,                    XKB_KEY_j,           focusstack,       {.i = +1} },   /* down  (vim j) */
	{ MODKEY,                    XKB_KEY_k,           focusstack,       {.i = -1} },   /* up    (vim k) */
	{ MODKEY,                    XKB_KEY_h,           setmfact,         {.f = -0.05f} }, /* shrink master */
	{ MODKEY,                    XKB_KEY_l,           setmfact,         {.f = +0.05f} }, /* grow master */
	{ MODKEY,                    XKB_KEY_Return,      zoom,             {0} },          /* swap with master */
	{ MODKEY,                    XKB_KEY_Tab,         view,             {0} },          /* previous tag */

	/* --- Window management --- */
	{ MODKEY,                    XKB_KEY_q,           killclient,       {0} },          /* close (like Super+Q) */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c,           killclient,       {0} },          /* also close (dwl default) */
	{ MODKEY,                    XKB_KEY_f,           togglefullscreen, {0} },          /* fullscreen (like Super+F) */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,       togglefloating,   {0} },          /* toggle float (like Super+G) */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_f,           setlayout,        {.v = &layouts[1]}, /* floating layout */

	/* --- Apps --- */
	{ MODKEY,                    XKB_KEY_e,           spawn,            {.v = filemanagercmd} }, /* file manager (like Super+E) */
	{ MODKEY,                    XKB_KEY_b,           spawn,            {.v = browsercmd} },      /* browser (like Super+B) */
	{ MODKEY,                    XKB_KEY_Escape,      spawn,            {.v = lockcmd} },         /* lock (like Super+Escape) */

	/* --- Layouts --- */
	{ MODKEY,                    XKB_KEY_t,           setlayout,        {.v = &layouts[0]} }, /* tile */
	{ MODKEY,                    XKB_KEY_s,           setlayout,        {.v = &layouts[2]} }, /* monocle (s for single-window) */
	{ MODKEY,                    XKB_KEY_space,       setlayout,        {0} },                /* cycle layouts */

	/* --- Tags (workspaces) --- */
	{ MODKEY,                    XKB_KEY_0,           view,             {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright,  tag,              {.ui = ~0} },
	{ MODKEY,                    XKB_KEY_comma,       focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,      focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,        tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,     tagmon,           {.i = WLR_DIRECTION_RIGHT} },
	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                        0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                            1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                    2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                        3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                       4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                   5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                     6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                      7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                     8),

	/* --- Volume --- */
	{ WLR_MODIFIER_LOGO,         XKB_KEY_XF86AudioRaiseVolume,  spawn, {.v = volupcmd} },
	{ WLR_MODIFIER_LOGO,         XKB_KEY_XF86AudioLowerVolume,  spawn, {.v = voldowncmd} },
	{ WLR_MODIFIER_LOGO,         XKB_KEY_XF86AudioMute,        spawn, {.v = volmutecmd} },

	/* --- Brightness (laptop) --- */
	{ WLR_MODIFIER_LOGO,         XKB_KEY_XF86MonBrightnessUp,   spawn, {.v = brightupcmd} },
	{ WLR_MODIFIER_LOGO,         XKB_KEY_XF86MonBrightnessDown, spawn, {.v = brightdowncmd} },

	/* --- dwl basics --- */
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q,           quit,             {0} },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
	/* Ctrl-Alt-Fx is used to switch to another VT, if you don't know what a VT is
	 * do not remove them.
	 */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
