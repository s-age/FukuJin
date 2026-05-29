#ifndef CGSPrivate_h
#define CGSPrivate_h

#include <CoreGraphics/CoreGraphics.h>

typedef int CGSConnectionID;

extern int32_t _AXUIElementGetWindow(CFTypeRef element, uint32_t *wid);

extern CGSConnectionID CGSMainConnectionID(void);
extern CGError CGSSetWindowLevel(CGSConnectionID cid, uint32_t wid, int32_t level);
extern CGError CGSGetWindowLevel(CGSConnectionID cid, uint32_t wid, int32_t *level);
extern CGError CGSOrderWindow(CGSConnectionID cid, uint32_t wid, int32_t place, uint32_t relativeToWid);
extern CGError CGSMoveWindow(CGSConnectionID cid, uint32_t wid, const CGPoint *point);
extern CGError CGSGetWindowBounds(CGSConnectionID cid, uint32_t wid, CGRect *outBounds);

#endif
