// Common.h

#ifdef DEBUG
  #define debug(...) NSLog(__VA_ARGS__)
#else
  #define debug(...)
#endif

#define GREENTEXT
