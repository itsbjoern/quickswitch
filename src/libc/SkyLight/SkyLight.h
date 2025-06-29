#ifndef Skylight_h
#define Skylight_h

#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdbool.h>
#include <stdint.h>
#include <sys/_types/_pid_t.h>

void makeKeyWindow(pid_t app_pid, uint32_t window_id);

#endif /* Skylight_h */
