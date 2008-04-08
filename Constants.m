//
//  Constants.m
//  Terminal

#import "Constants.h"

struct StrCtrlMap STRG_CTRL_MAP[] = {
{ @"!",       {0xd} }, { @"return",  {0xd} },              
{ @"t",       {0x9} }, 
{ @"home",    {0x1B, 0x5B, 0x31, 0x7e} },
{ @"del",     {0x1B, 0x5B, 0x33, 0x7e} },
{ @"end",     {0x1B, 0x5B, 0x34, 0x7e} },
{ @"pgup",    {0x1B, 0x5B, 0x35, 0x7e} },
{ @"pgdown",  {0x1B, 0x5B, 0x36, 0x7e} },
{ @"up",      {0x1B, 0x5B, 0x41} },
{ @"down",    {0x1B, 0x5B, 0x42} },
{ @">",       {0x1B, 0x5B, 0x43} }, { @"right",   {0x1B, 0x5B, 0x43} }, 
{ @"<",       {0x1B, 0x5B, 0x44} }, { @"left",    {0x1B, 0x5B, 0x44} }, 
{ @"A",       {0x1B, 0x1} }, 
{ @"B",       {0x1B, 0x2} },
{ @"C",       {0x1B, 0x3} },
{ @"D",       {0x1B, 0x4} }, 
{ @"E",       {0x1B, 0x5} },
{ @"F",       {0x1B, 0x6} },
{ @"G",       {0x1B, 0x7} }, 
{ @"H",       {0x1B, 0x8} },
{ @"I",       {0x1B, 0x9} },
{ @"J",       {0x1B, 0xa} }, 
{ @"K",       {0x1B, 0xb} },
{ @"L",       {0x1B, 0xc} },
{ @"M",       {0x1B, 0xd} }, 
{ @"N",       {0x1B, 0xe} },
{ @"O",       {0x1B, 0xf} },
{ @"P",       {0x1B, 0x10} }, 
{ @"Q",       {0x1B, 0x11} },
{ @"R",       {0x1B, 0x12} },
{ @"S",       {0x1B, 0x13} },
{ @"T",       {0x1B, 0x14} },
{ @"U",       {0x1B, 0x15} },
{ @"V",       {0x1B, 0x16} },
{ @"W",       {0x1B, 0x17} },
{ @"X",       {0x1B, 0x18} },
{ @"Y",       {0x1B, 0x19} },
{ @"Z",       {0x1B, 0x1a} },
{ @"esc",     {0x1B} },
{ nil, {0} },
};

NSString * ZONE_KEYS[] =
{
  @"n", @"ne", @"e", @"se", @"s", @"sw", @"w", @"nw", @"ln", @"lne", @"le", @"lse", @"ls", @"lsw", @"lw", @"lnw", nil
};

NSString * DEFAULT_SWIPE_GESTURES[][2] = 
{
{ @"n",    @"\x1B[A" }, // up
{ @"ne",   @"\x03"   }, // ctrl-c
{ @"e",    @"\x1B[C" }, // right
{ @"se",   @"[CTRL]" }, // ctrl mode
{ @"s",    @"\x1B[B" }, // down
{ @"sw",   @"\x09"   }, // tab
{ @"w",    @"\x1B[D" }, // left
{ @"nw",   @"\x1B"   }, // esc
{ @"ln",   @""       },
{ @"lne",  @""       },
{ @"le",   @"\x5"    }, // ctrl-e
{ @"lse",  @""       }, 
{ @"ls",   @""       },
{ @"lsw",  @""       },
{ @"lw",   @"\x1"    }, // ctrl-a
{ @"lnw",  @""       },
{ nil,     nil       }
};

#define M_(c,t) @"cmd",(c),@"title",(t),
#define _1(c,t) @"cmd_1",(c),@"title_1",(t),
#define _2(c,t) @"cmd_2",(c),@"title_2",(t),
#define _3(c,t) @"cmd_3",(c),@"title_3",(t),
#define _4(c,t) @"cmd_4",(c),@"title_4",(t),
#define _5(c,t) @"cmd_5",(c),@"title_5",(t),
#define _6(c,t) @"cmd_6",(c),@"title_6",(t)

NSString * DEFAULT_MENU_BUTTONS[][MENU_BUTTON_DICT_KEYS] = 
{
  { _1(@"ls -a\x0d",  @"ls")    _2(@"cd /\x0d",  @"cd /")                                                                           _4(@"tail -n 100 ", @"tail100")  _5(@"killall SpringBoard", @"respring")    _6(@"print ", @"print")},
  { _1(@"cd ",        @"cd")    _2(@"cd ..\x0d", @"cd ..")                                                                          _4(@"tail ",        @"tail")                                                _6(@"print \"%\" %(,)\x1B[D\x1B[D", @"printf")},
  { _1(@"clear\x0d",  @"clear") _2(@"cd ~\x0d",  @"cd ~")                                                                           _4(@"tail -f ",     @"tail -f")  _5(@"sudo reboot", @"reboot")              _6(@"python\x0d", @"python")},
  { M_(@"[menu1]", @"misc")},
  { _1(@"<",       @"<")        _2(@"popd\x0d",          @"popd")             _3(@"locate ",                           @"locate")   _4(@"cat ",         @"cat")                                                 _6(@"[]\x1B[D", @"[]")},
  { _1(@"/",       @"/")        _2(@"dirs -l -p -v | sort -r\x0d", @"dirs")   _3(@"find . -name \"\"\x1B[D",           @"find")     _4(@"head ",        @"head")     _5(@"killall Terminal", @"quit")           _6(@"()\x1B[D", @"()")},
  { _1(@" -",      @"-")        _2(@"pushd ",            @"pusd")             _3(@"grep -r \"\" .\x1B[D\x1B[D\x1B[D",  @"grep")     _4(@"less ",        @"less")                                                _6(@"{}\x1B[D", @"{}")},
  { M_(@"[menu2]", @"cd..")},
  { _1(@"-",       @"-")        _2(@"ls -trhog\x0d",  @"ls-time")                                                                                                                                               _6(@"def (self):\x1B[D\x1B[D\x1B[D\x1B[D\x1B[D\x1B[D\x1B[D", @"def..")},
  { _1(@"~",       @"~")        _2(@"ls -hsSr\x0d",   @"ls-size")                                                                   _4(@"vim ",         @"vim")      _5(@"sudo ", @"sudo")                      _6(@":\x0d\x09", @":")},
  { _1(@".",       @".")        _2(@"ls -la\x0d",     @"ls-la")                                                                     _4(@"nano ",        @"nano")     _5(@"alpine\x0d", @"alpine")               _6(@"for in :\x1B[D\x1B[D\x1B[D\x1B[D", @"for..")},
  { M_(@"[menu3]", @"find")},
  { M_(@"[menu6]", @"prog")},
  { M_(@"[menu5]", @"sys")},
  { M_(@"[menu4]", @"view")},
  { M_(@"",        @"")},
  { nil }
};
