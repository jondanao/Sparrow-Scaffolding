//
//  Game.m
//  AppScaffold
//

#import "Game.h"

#define GRAVITY 9.81f
#define PTM_RATIO 32 // 32 pixels : 1 meter
#define WORLD_WIDTH 480
#define WORLD_HEIGHT 320

// PRIVATE INTERFACE
@interface Game ()

@property (nonatomic, assign) b2World *world;
@property (nonatomic, strong) SPSprite *worldView;
- (void)setup;
- (void)initWorld;
- (void)onEnterFrame:(SPEnterFrameEvent *)event;
- (void)onTouch:(SPTouchEvent *)event;

@end


// IMPLEMENTATION
@implementation Game

@synthesize gameWidth   = mGameWidth;
@synthesize gameHeight  = mGameHeight;
@synthesize world       = _world;
@synthesize worldView   = _worldView;

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super init]))
    {
        mGameWidth = width;
        mGameHeight = height;
        
        [self setup];
        [self initWorld];
    }
    
    return self;
}

- (void)setup
{
    self.worldView = [[SPSprite alloc] init];
    [self addChild:self.worldView];
    
    SPQuad *bg = [[SPQuad alloc] initWithWidth:WORLD_WIDTH height:WORLD_HEIGHT color:0xFFFFFF];
    [self.worldView addChild:bg];
    
    [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

- (void)initWorld
{    
    // CREATE WORLD BOUNDS
    /*
           top edge
          a---------b
     left |         | right
     edge |         | edge
          c---------d
          bottom edge
     
     a = (0, 0)
     b = (w, 0)
     c = (0, h)
     d = (w, h)
     
     */
    
    b2Vec2 a = b2Vec2(0, 0);
    b2Vec2 b = b2Vec2(WORLD_WIDTH / PTM_RATIO, 0);
    b2Vec2 c = b2Vec2(0, WORLD_HEIGHT / PTM_RATIO);
    b2Vec2 d = b2Vec2(WORLD_WIDTH / PTM_RATIO, WORLD_HEIGHT / PTM_RATIO);
    
    b2Vec2 gravity;
    gravity.Set(0.0, GRAVITY);
    
    self.world = new b2World(gravity);
    self.world->SetAllowSleeping(true);
    self.world->SetContinuousPhysics(true);
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0);
    
    b2Body *groundBody = self.world->CreateBody(&groundBodyDef);
    b2EdgeShape groundBox;
    
    // TOP EDGE: a to b
    groundBox.Set(a,b);
    groundBody->CreateFixture(&groundBox, 0);
    
    // RIGHT EDGE: b to d
    groundBox.Set(b,d);
    groundBody->CreateFixture(&groundBox, 0);
    
    // BOTTOM EDGE: c to d
    groundBox.Set(c,d);
    groundBody->CreateFixture(&groundBox, 0);
    
    // LEFT EDGE: a to c
    groundBox.Set(a,c);
    groundBody->CreateFixture(&groundBox, 0);
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    int32 velocityIterations = 10;
    int32 positionIterations = 1;
    
    self.world->Step(event.passedTime, velocityIterations, positionIterations);
    
    for (b2Body* body = self.world->GetBodyList(); body; body = body->GetNext())
	{
		if (body->GetUserData() != NULL) 
        { 
			SPDisplayObject *object = (__bridge SPDisplayObject *)body->GetUserData();
            object.x = body->GetPosition().x * PTM_RATIO;
            object.y = body->GetPosition().y * PTM_RATIO;
            object.rotation = body->GetAngle();
        }    
	}
}

- (void)onTouch:(SPTouchEvent *)event
{
    NSArray *touchesBegan = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] allObjects];
    
    if(touchesBegan.count == 1)
    {
        SPPoint *touchPoint = [[touchesBegan objectAtIndex:0] locationInSpace:self];
        float randomWidth = arc4random() % 50 + 10;
        float randomHeight = arc4random() % 50 + 10;
        
        // SPARROW BOX
        SPQuad *box = [[SPQuad alloc] initWithWidth:randomWidth height:randomHeight color:arc4random()%0xFFFFFF];
        box.x = touchPoint.x - randomWidth / 2;
        box.y = touchPoint.y - randomHeight / 2;
        box.pivotX = box.width / 2;
        box.pivotY = box.height / 2;
        [self.worldView addChild:box];
        
        // BOX2D BODY
        b2BodyDef boxBodyDef;
        boxBodyDef.type = b2_dynamicBody;
        boxBodyDef.position.Set(box.x / PTM_RATIO, box.y / PTM_RATIO);
        boxBodyDef.angle = SP_D2R(arc4random() % 360);
        boxBodyDef.userData = (__bridge void *)box;
        
        b2PolygonShape boxBoxShape;
        boxBoxShape.SetAsBox(box.width / PTM_RATIO / 2, box.height / PTM_RATIO / 2);
        
        b2FixtureDef boxFixtureDef;
        boxFixtureDef.shape = &boxBoxShape;
        boxFixtureDef.density = 1.0f;
        boxFixtureDef.friction = 0.3f;
        boxFixtureDef.restitution = 0.3f;
        
        b2Body *boxBody = self.world->CreateBody(&boxBodyDef);
        boxBody->CreateFixture(&boxFixtureDef);
    }
}

@end
