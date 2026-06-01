#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "biomenoise.h"
#import "biomes.h"
#import "finders.h"
#import "generator.h"
#import "layers.h"
#import "noise.h"
#import "quadbase.h"
#import "rng.h"
#import "btree18.h"
#import "btree19.h"
#import "btree192.h"
#import "btree20.h"
#import "btree21wd.h"
#import "util.h"

FOUNDATION_EXPORT double cubiomes_ffiVersionNumber;
FOUNDATION_EXPORT const unsigned char cubiomes_ffiVersionString[];

