#define MAKE_SINGLETON(class_name, shared_method_name) \
+ (id)shared_method_name { \
static dispatch_once_t pred; \
static class_name * z ## class_name ## _ = nil; \
dispatch_once(&pred, ^{ \
z ## class_name ## _ = [[self alloc] init]; \
}); \
return z ## class_name ## _; \
} \
- (id)copy { \
return self; \
}/*
- (id)retain { \
return self; \
} \
- (NSUInteger)retainCount { \
return UINT_MAX; \
} \
- (void)release { \
} \
- (id)autorelease { \
return self; \
}
*/