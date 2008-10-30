//
//  SineWave.m
//  Dowoscillator
//
//  Created by youpy on 08/10/30.
//

#import "SineWave.h"

typedef struct {
	@defs(SineWave);
} SinewaveDef;

@implementation SineWave
OSStatus    RenderCallback(void                          *inRefCon,
                           AudioUnitRenderActionFlags    *ioActionFlags,
                           const AudioTimeStamp          *inTimeStamp,
                           UInt32                        inBusNumber,
                           UInt32                        inNumberFrames,
                           AudioBufferList               *ioData)
{
	SinewaveDef* def = inRefCon;
	float samplingRate = 44100;
	float freq = def->frequency * 2 * M_PI / samplingRate;

	float *outL = ioData->mBuffers[0].mData;
	float *outR = ioData->mBuffers[1].mData;

	int i;
	for (i=0; i< inNumberFrames; i++){
		float wave = sin(def->phase);
		*outL++ = wave;
		*outR++ = wave;

		def->phase = def->phase + freq;
	}
	return noErr;
}

-(void)awakeFromNib{
	AudioUnit	defaultOutputUnit;

	ComponentDescription cd;
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_DefaultOutput;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;

	Component comp = FindNextComponent(NULL, &cd);
	OpenAComponent(comp, &defaultOutputUnit);

	AURenderCallbackStruct input;
	input.inputProc = RenderCallback;
	input.inputProcRefCon = self;

	AudioUnitSetProperty (defaultOutputUnit,
												kAudioUnitProperty_SetRenderCallback,
												kAudioUnitScope_Input,
												0,
												&input,
												sizeof(input));

	AudioUnitInitialize(defaultOutputUnit);

	[self getDji];

	[NSTimer scheduledTimerWithTimeInterval:30.0f
					 target:self
					 selector:@selector(getDji)
					 userInfo:nil
					 repeats:YES];

	AudioOutputUnitStart (defaultOutputUnit);
}

-(void)getDji {
	webView = [[WebView alloc] init];

	NSURL* url = [NSURL URLWithString:@"http://dji.appjet.net/"];
	NSString* json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	WebScriptObject* wso = [webView windowScriptObject];
	WebScriptObject* obj = [wso evaluateWebScript:[[NSString alloc] initWithFormat:@"(function() { return %@ function callback(obj) { return obj; } })()", json]];
	NSNumber* dji = [obj valueForKey:@"dji"];

	frequency = [dji floatValue];
	NSLog(@"%f", frequency);
}
@end
