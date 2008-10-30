//
//  SineWave.h
//  Dowoscillator
//
//  Created by youpy on 08/10/30.
//

#import <Cocoa/Cocoa.h>
#import <audiounit/AudioUnit.h>
#import <webkit/WebKit.h>

@interface SineWave : NSObject
{
    float phase;
	float frequency;
	WebView *webView;
}

-(void)getDji;
@end
