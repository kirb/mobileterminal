// SubProcess.m
#import "SubProcess.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <util.h>
#import "Common.h"

@implementation SubProcess

static void signal_handler(int signal) {
  int status;
  wait(&status);
  debug(@"Child status changed to %d", status);
  exit(1);
}

- (id)initWithRows:(int)rows columns:(int)cols
{
  _fd = 0;

  // Register a callback that is fired when the forked child process
  // status is changed; Should probably only happen when it actually exits;
  signal(SIGCHLD, &signal_handler);

  struct winsize win;
  win.ws_row = rows;
  win.ws_col = cols;

  pid_t pid = forkpty(&_fd, NULL, NULL, &win);
  if (pid == -1) {
    perror("forkpty");
    exit(1);
  } else if (pid == 0) {
    // First try to use /bin/login since its a little nicer.  Fall back to
    // /bin/sh  if that is available.
    // We sleep for 5 seconds before exiting so that if someone doesn't have 
    // the correct binary, they will see an error messages printed on the
    // instead of the program exiting.
    struct stat st;
    if (stat("/bin/login", &st) == 0) {
      if (execlp("/bin/login", "login", "-f", "root", (void*)0) == -1) {
        perror("execlp: /bin/login");
        sleep(5);
      }
    } else if (stat("/bin/sh", &st) == 0) {
      if (execlp("/bin/sh", "sh", (void*)0) == -1) {
        perror("execlp: /bin/sh");
        sleep(5);
      }
    } else {
      printf("No shell available.  Please install /bin/login and /bin/sh");
      sleep(5);
    }
    exit(1);
    return nil;  // not reached
  }
  NSLog(@"Child process id: %d\n", pid);

  // Future read/write operations should not block
  int flags;
  if ((flags = fcntl(_fd, F_GETFL, 0)) == -1) {
    flags = 0;
  }
  if (fcntl(_fd, F_SETFL, flags | O_NONBLOCK) == -1) {
    perror("fcntl");
    exit(1);
  }  
  return self;
}

- (int)fileDescriptor
{
  return _fd;
}

- (void)dealloc
{
  close(_fd);
  [super dealloc];
}

@end
