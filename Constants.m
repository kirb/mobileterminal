//
//  Constants.m
//  Terminal

#import "Constants.h"

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

NSString * DEFAULT_MENU_BUTTONS[][4] = 
{
  { @"chars", @"[", },
  { @"chars", @"]", },
  { @"chars", @"*", },
  { @"chars", @"\\", },
  { @"chars", @"/", },
  { @"chars", @"~", },
  { @"chars", @"{", },
  { @"chars", @"}", },
  { @"chars", @">", },
  { nil }
};
