//
// MotionStreak Demo
// a cocos2d example
//
// Example by Jason Booth (slipster216)

// cocos import
#import "cocos2d.h"
#import "MotionStreakTest.h"

enum {
	kTagLabel = 1,
	kTagSprite1 = 2,
	kTagSprite2 = 3,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"Test1",
	@"Test2",
};

#pragma mark Callbacks

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark Demo examples start here

@implementation MotionStreakTest
-(id) init
{
	if( (self = [super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];	
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:0 tag:kTagLabel];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
		[self addChild: menu z:1];
		
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end


#pragma mark Test1

@implementation Test1
-(NSString*) title
{
	return @"MotionStreak test 1";
}
-(void) dealloc
{
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
  
	// the root object just rotates around
	root = [CCSprite spriteWithFile:@"r1.png"];
	[self addChild: root z:1];
	[root setPosition: ccp(s.width/2, s.height/2)];
  
	// the target object is offset from root, and the streak is moved to follow it
	target = [CCSprite spriteWithFile:@"r1.png"];
	[root addChild:target];
	[target setPosition:ccp(100,0)];

	// create the streak object and add it to the scene
	streak = [CCMotionStreak streakWithFade:2 minSeg:3 image:@"streak.png" width:32 length:32 color:ccc4(0,255,0,255)];
	[self addChild:streak];
	// schedule an update on each frame so we can syncronize the streak with the target
	[self schedule:@selector(onUpdate:)];
  
	id a1 = [CCRotateBy actionWithDuration:2 angle:360];

	id action1 = [CCRepeatForever actionWithAction:a1];
	id motion = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
	[root runAction:[CCRepeatForever actionWithAction:[CCSequence actions:motion, [motion reverse], nil]]];
	[root runAction:action1];
}

-(void)onUpdate:(ccTime)delta
{
//  CGPoint p = [target absolutePosition];
//  float r = [root rotation];
	[streak setPosition:[target convertToWorldSpace:CGPointZero]];

}
@end

#pragma mark Test2

@implementation Test2
-(NSString*) title
{
	return @"MotionStreak test (tap screen)";
}
-(void) dealloc
{
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	
	self.isTouchEnabled = YES;

	CGSize s = [[CCDirector sharedDirector] winSize];
		
	// create the streak object and add it to the scene
	streak = [CCMotionStreak streakWithFade:3 minSeg:3 image:@"streak.png" width:64 length:32 color:ccc4(255,255,255,255)];
	[self addChild:streak];
	
	streak.position = ccp(s.width/2, s.height/2);
}

-(BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	[streak setPosition:touchLocation];
	
	return YES;
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];

	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[[CCDirector sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
