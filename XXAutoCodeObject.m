//
//  XXAutoCodeObject.m
//  20191206
//
//

#import "XXAutoCodeObject.h"
#import <objc/runtime.h>

@implementation XXAutoCodeObject

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        Class curClass = self.class;
        while (!(curClass == [XXAutoCodeObject class])) {
            unsigned int count = 0;
            Ivar *ivar = class_copyIvarList(curClass, &count);
            for (int i = 0; i<count; i++) {
                Ivar iva = ivar[i];
                const char *name = ivar_getName(iva);
                NSString *strName = [NSString stringWithUTF8String:name];
                id value = [decoder decodeObjectForKey:strName];
                if (value != nil) {
                    [self setValue:value forKey:strName];
                }else{
                    // value nil
                }
            }
            free(ivar);
            
            curClass = [curClass superclass];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    Class curClass = self.class;
    while (!(curClass == [XXAutoCodeObject class])) {
        unsigned int count;
        Ivar *ivar = class_copyIvarList(curClass, &count);
        for (int i=0; i<count; i++) {
            Ivar iv = ivar[i];
            const char *name = ivar_getName(iv);
            NSString *strName = [NSString stringWithUTF8String:name];
            id value = [self valueForKey:strName];
            if ([value respondsToSelector:@selector(encodeWithCoder:)]) {
                [encoder encodeObject:value forKey:strName];
            }else{
                NSLog(@"unrecognized selector encoderWithCoder:");
            }
        }
        free(ivar);
        
        curClass = [curClass superclass];
    }
}

@end
