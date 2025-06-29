//
//  ApplicationsOrdered.h
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

#ifndef ApplicationsOrdered_h
#define ApplicationsOrdered_h

#import <Carbon/Carbon.h>
#import <dlfcn.h>

CFArrayRef CopyLaunchedApplicationsInFrontToBackOrder(void);
uint32_t getWindowId(AXUIElementRef window);

#endif /* ApplicationsOrdered_h */
