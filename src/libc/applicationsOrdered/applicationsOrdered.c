//
//  ApplicationsOrdered.c
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

#include "ApplicationsOrdered.h"

extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID *out);

uint32_t getWindowId(AXUIElementRef window) {
  CGWindowID _windowId;
  if (_AXUIElementGetWindow(window, &_windowId) == kAXErrorSuccess) {
    return _windowId;
  }
  return -1;
}

/*
 * Returns an array of CFDictionaryRef types, each of which contains information
 * about one of the processes. The processes are ordered in front to back, i.e.
 * in the same order they appear when typing command + tab, from left to right.
 * See the ProcessInformationCopyDictionary function documentation for the keys
 * used in the dictionaries. If something goes wrong, then this function returns
 * NULL.
 */
CFArrayRef CopyLaunchedApplicationsInFrontToBackOrder(void) {
  CFArrayRef (*_LSCopyApplicationArrayInFrontToBackOrder)(uint32_t sessionID) =
      NULL;
  void (*_LSASNExtractHighAndLowParts)(void const *asn, UInt32 *psnHigh,
                                       UInt32 *psnLow) = NULL;
  CFTypeID (*_LSASNGetTypeID)(void) = NULL;

  void *lsHandle = dlopen("/System/Library/Frameworks/CoreServices.framework/"
                          "Frameworks/LaunchServices.framework/LaunchServices",
                          RTLD_LAZY);
  if (!lsHandle) {
    return NULL;
  }

  _LSCopyApplicationArrayInFrontToBackOrder = (CFArrayRef(*)(uint32_t))dlsym(
      lsHandle, "_LSCopyApplicationArrayInFrontToBackOrder");
  _LSASNExtractHighAndLowParts =
      (void (*)(void const *, UInt32 *, UInt32 *))dlsym(
          lsHandle, "_LSASNExtractHighAndLowParts");
  _LSASNGetTypeID = (CFTypeID(*)(void))dlsym(lsHandle, "_LSASNGetTypeID");

  if (_LSCopyApplicationArrayInFrontToBackOrder == NULL ||
      _LSASNExtractHighAndLowParts == NULL || _LSASNGetTypeID == NULL) {
    return NULL;
  }

  CFMutableArrayRef orderedApplications =
      CFArrayCreateMutable(kCFAllocatorDefault, 64, &kCFTypeArrayCallBacks);
  if (!orderedApplications) {
    return NULL;
  }

  CFArrayRef apps = _LSCopyApplicationArrayInFrontToBackOrder(-1);
  if (!apps) {
    CFRelease(orderedApplications);
    return NULL;
  }

  CFIndex count = CFArrayGetCount(apps);
  for (CFIndex i = 0; i < count; i++) {
    ProcessSerialNumber psn = {0, kNoProcess};
    CFTypeRef asn = CFArrayGetValueAtIndex(apps, i);
    if (CFGetTypeID(asn) == _LSASNGetTypeID()) {
      _LSASNExtractHighAndLowParts(asn, &psn.highLongOfPSN, &psn.lowLongOfPSN);

      CFDictionaryRef processInfo = ProcessInformationCopyDictionary(
          &psn, kProcessDictionaryIncludeAllInformationMask);
      if (processInfo) {
        CFArrayAppendValue(orderedApplications, processInfo);
        CFRelease(processInfo);
      }
    }
  }
  CFRelease(apps);

  CFArrayRef result =
      CFArrayGetCount(orderedApplications) == 0
          ? NULL
          : CFArrayCreateCopy(kCFAllocatorDefault, orderedApplications);
  CFRelease(orderedApplications);
  return result;
}
