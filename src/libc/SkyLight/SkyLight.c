#include "SkyLight.h"
#include <MacTypes.h>

// Type aliases
typedef uint32_t CGSConnectionID;
typedef uint64_t CGSSpaceID;
typedef const CFStringRef ScreenUuid;

// OptionSet structs as bitfields
typedef uint32_t CGSWindowCaptureOptions;

typedef int CGSCopyWindowsOptions;

typedef int CGSCopyWindowsTags;

// SkyLight private API function declarations
extern CGSConnectionID CGSMainConnectionID(void);

extern CFArrayRef CGSHWCaptureWindowList(CGSConnectionID cid,
                                         uint32_t *windowList,
                                         uint32_t windowCount,
                                         CGSWindowCaptureOptions options);

extern CFArrayRef CGSCopyManagedDisplaySpaces(CGSConnectionID cid);

extern CFArrayRef CGSCopyWindowsWithOptionsAndTags(CGSConnectionID cid,
                                                   int owner, CFArrayRef spaces,
                                                   int options, int *setTags,
                                                   int *clearTags);

extern CGSSpaceID CGSManagedDisplayGetCurrentSpace(CGSConnectionID cid,
                                                   ScreenUuid displayUuid);

extern void CGSAddWindowsToSpaces(CGSConnectionID cid, CFArrayRef windows,
                                  CFArrayRef spaces);

extern void CGSRemoveWindowsFromSpaces(CGSConnectionID cid, CFArrayRef windows,
                                       CFArrayRef spaces);

extern CGError CGSCopyWindowProperty(CGSConnectionID cid, uint32_t wid,
                                     CFStringRef property, CFTypeRef *value);

extern CFArrayRef CGSCopySpacesForWindows(CGSConnectionID cid, int mask,
                                          CFArrayRef wids);

extern CGError CGSGetWindowLevel(CGSConnectionID cid, uint32_t wid,
                                 int32_t *level);

extern uint8_t SLSRequestScreenCaptureAccess(void);

extern CGError CGSSetSymbolicHotKeyEnabled(int hotKey, bool isEnabled);

extern ScreenUuid CGSCopyActiveMenuBarDisplayIdentifier(CGSConnectionID cid);

extern CGError _SLPSSetFrontProcessWithOptions(ProcessSerialNumber *psn,
                                               uint32_t wid, uint32_t mode);

extern CGError SLPSPostEventRecordTo(ProcessSerialNumber *psn, uint8_t *bytes);

extern OSStatus GetProcessForPID(pid_t pid, ProcessSerialNumber *psn);

extern CGError _SLPSSetFrontProcessWithOptions(ProcessSerialNumber *psn,
                                               uint32_t wid, uint32_t mode);
extern CGError SLPSPostEventRecordTo(ProcessSerialNumber *psn, uint8_t *bytes);

void makeKeyWindow(pid_t app_pid, uint32_t window_id) {
  // the information specified in the events below consists of the "special"
  // category, event type, and modifiers, basically synthesizing a mouse-down
  // and up event targetted at a specific window of the application, but it
  // doesn't actually get treated as a mouse-click normally would.

  ProcessSerialNumber psn;
  GetProcessForPID(app_pid, &psn);

  _SLPSSetFrontProcessWithOptions(&psn, window_id, 0x20);

  uint8_t bytes1[0xf8] = {[0x04] = 0xF8, [0x08] = 0x01, [0x3a] = 0x10};
  uint8_t bytes2[0xf8] = {[0x04] = 0xF8, [0x08] = 0x02, [0x3a] = 0x10};

  memcpy(bytes1 + 0x3c, &window_id, sizeof(uint32_t));
  memset(bytes1 + 0x20, 0xFF, 0x10);
  memcpy(bytes2 + 0x3c, &window_id, sizeof(uint32_t));
  memset(bytes2 + 0x20, 0xFF, 0x10);
  SLPSPostEventRecordTo(&psn, bytes1);
  SLPSPostEventRecordTo(&psn, bytes2);
}
