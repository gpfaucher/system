/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */

/* vanitygaps */
static const unsigned int gappih    = 0;        /* horiz inner gap between windows */
static const unsigned int gappiv    = 0;        /* vert inner gap between windows */
static const unsigned int gappoh    = 0;        /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 0;        /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */

/* systray */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft  = 0;   /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 4;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray             = 1;   /* 0 means no systray */

/* bar */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */

/* smartborders */
static const int smartborders       = 1;

/* fonts */
static const char *fonts[]          = { "Monaspace Neon:size=11", "Symbols Nerd Font:size=11" };
static const char dmenufont[]       = "Monaspace Neon:size=11";

/* xrdb colors - these are defaults overridden at runtime via xrdb */
static char normbgcolor[]           = "@base00@";
static char normbordercolor[]       = "@base01@";
static char normfgcolor[]           = "@base05@";
static char selfgcolor[]            = "@base00@";
static char selbordercolor[]        = "@base0D@";
static char selbgcolor[]            = "@base0D@";

static char *colors[][3] = {
	/*               fg           bg           border   */
	[SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
	[SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* named scratchpads */
static const char scratchpadname[] = "scratchpad";
static const char *scratchpadcmd[] = { "ghostty", "--class", "scratchpad", NULL };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class                  instance      title       tags mask  isfloating  isterminal  noswallow  monitor */
	{ "Ghostty",              NULL,         NULL,       0,         0,          1,          0,         -1 },
	{ "ghostty",              NULL,         NULL,       0,         0,          1,          0,         -1 },
	{ "scratchpad",           NULL,         NULL,       0,         1,          1,          0,         -1 },
	{ "teams-for-linux",      NULL,         NULL,       0,         0,          0,          0,         -1 },
	{ "zoom",                 NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "Gimp",                 NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "Steam",                NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "steam",                NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "blueman-manager",      NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "Blueman-manager",      NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "nm-connection-editor", NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "Nm-connection-editor", NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "pavucontrol",          NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "Pavucontrol",          NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ "Arandr",               NULL,         NULL,       0,         1,          0,          0,         -1 },
	{ NULL,                   NULL,         "Event Tester", 0,     0,          0,          1,         -1 }, /* xev */
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int attachbelow = 1;    /* 1 means attach after the currently active window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "[@]",      spiral },
	{ "[\\]",     dwindle },
	{ "[D]",      deck },
	{ "|M|",      centeredmaster },
	{ ">M>",      centeredfloatingmaster },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "ghostty", NULL };
static const char *lockcmd[]  = { "slock", NULL };

/* screenshot commands */
static const char *scrotfull[] = { "/bin/sh", "-c", "maim | xclip -selection clipboard -t image/png", NULL };
static const char *scrotsel[]  = { "/bin/sh", "-c", "maim -s | xclip -selection clipboard -t image/png", NULL };

static const Key keys[] = {
	/* modifier                     key            function        argument */
	/* spawn */
	{ MODKEY,                       XK_Return,     spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_d,          spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_l,          spawn,          {.v = lockcmd } },

	/* screenshots */
	{ MODKEY,                       XK_Print,      spawn,          {.v = scrotfull } },
	{ MODKEY|ShiftMask,             XK_Print,      spawn,          {.v = scrotsel } },

	/* scratchpad */
	{ MODKEY,                       XK_grave,      togglescratch,  {.v = scratchpadcmd } },

	/* window management */
	{ MODKEY,                       XK_q,          killclient,     {0} },
	{ MODKEY,                       XK_b,          togglebar,      {0} },
	{ MODKEY,                       XK_j,          focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,          focusstack,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_j,          movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,          movestack,      {.i = -1 } },
	{ MODKEY,                       XK_i,          incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_i,          incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,          setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,          setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_z,          zoom,           {0} },
	{ MODKEY,                       XK_Tab,        view,           {0} },

	/* layouts */
	{ MODKEY,                       XK_t,          setlayout,      {.v = &layouts[0]} }, /* tile */
	{ MODKEY|ShiftMask,             XK_f,          setlayout,      {.v = &layouts[1]} }, /* floating */
	{ MODKEY,                       XK_m,          setlayout,      {.v = &layouts[2]} }, /* monocle */
	{ MODKEY,                       XK_r,          setlayout,      {.v = &layouts[3]} }, /* spiral */
	{ MODKEY|ShiftMask,             XK_r,          setlayout,      {.v = &layouts[4]} }, /* dwindle */
	{ MODKEY,                       XK_c,          setlayout,      {.v = &layouts[5]} }, /* deck */
	{ MODKEY,                       XK_u,          setlayout,      {.v = &layouts[6]} }, /* centeredmaster */
	{ MODKEY|ShiftMask,             XK_u,          setlayout,      {.v = &layouts[7]} }, /* centeredfloatingmaster */
	{ MODKEY|ControlMask,           XK_Tab,        cyclelayout,    {.i = +1 } },

	/* floating */
	{ MODKEY,                       XK_space,      togglefloating, {0} },
	{ MODKEY,                       XK_f,          togglefullscr,  {0} }, /* fakefullscreen */
	{ MODKEY,                       XK_s,          togglesticky,   {0} },

	/* vanitygaps */
	{ MODKEY|Mod1Mask,              XK_equal,      incrgaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask,              XK_minus,      incrgaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_0,          togglegaps,     {0} },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_0,          defaultgaps,    {0} },

	/* all tags */
	{ MODKEY,                       XK_0,          view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,          tag,            {.ui = ~0 } },

	/* monitors */
	{ MODKEY,                       XK_comma,      focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period,     focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,      tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period,     tagmon,         {.i = +1 } },

	/* tags */
	TAGKEYS(                        XK_1,                          0)
	TAGKEYS(                        XK_2,                          1)
	TAGKEYS(                        XK_3,                          2)
	TAGKEYS(                        XK_4,                          3)
	TAGKEYS(                        XK_5,                          4)
	TAGKEYS(                        XK_6,                          5)
	TAGKEYS(                        XK_7,                          6)
	TAGKEYS(                        XK_8,                          7)
	TAGKEYS(                        XK_9,                          8)

	/* quit / restart */
	{ MODKEY|ShiftMask,             XK_q,          quit,           {0} },
	{ MODKEY|ShiftMask,             XK_r,          quit,           {1} }, /* restartsig */
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
	{ ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
	{ ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
