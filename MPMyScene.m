//
//  MPMyScene.m
//  SpriteTimeClock
//
//  Created by Steven Lipton on 5/6/14.
//  Copyright (c) 2014 Steven Lipton. All rights reserved.
//

#import "MPMyScene.h"

@implementation MPMyScene{
    SKLabelNode *myTimeLabel;
    SKLabelNode *myDateLabel;
    BOOL isShowingTime;
    BOOL isStopwatch;           //changed from isStopWatch for clarity
    BOOL isResettingStopwatch;  //changed from isStartingStopwatch for clarity.
    BOOL isRunningStopwatch;
    CFTimeInterval startTime;
    CFTimeInterval previousElapsedTime;
    CFTimeInterval elapsedTimeInterval;
    CFTimeInterval totalElapsedTime;
    
}

-(CGPoint)gridPointX:(float)xPoint pointY:(float)yPoint{
    CGFloat xDivision = CGRectGetMaxX(self.frame) /5.0;
    CGFloat yDivision = CGRectGetMaxY(self.frame)/5.0;
    return CGPointMake(xPoint * xDivision, yPoint * yDivision);
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    
        //add snow the the top of the screen using emitters
        NSString *snowPath = [[NSBundle mainBundle] pathForResource:@"MySnowParticle" ofType:@"sks"];
        SKEmitterNode *snowEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:snowPath];
        snowEmitter.position = [self gridPointX:2.5 pointY:5.0];
        [self addChild:snowEmitter];
        
        myTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        myTimeLabel.text = @"00:00:00";
        myTimeLabel.fontSize = 40;
        myTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMaxY(self.frame)*0.80);
        myTimeLabel.name = @"myTimeLabel";
        
         [self addChild:myTimeLabel];
 
        myDateLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        myDateLabel.text = @"Date Goes Here";
        myDateLabel.fontSize = 40;
        myDateLabel.alpha = 0.20;
        myDateLabel.position = [self gridPointX:2.5 pointY:3.0];
        myDateLabel.name = @"myDateLabel";
        
        [self addChild:myDateLabel];

        //make a switch to a stopwatch
        //SKSpriteNode *modeButton= [SKSpriteNode spriteNodeWithImageNamed:@"solidcircle"];
        //modeButton.name = @"modeButton";
        //modeButton.position = [self gridPointX:4.0 pointY:2.0];
        //[self addChild:modeButton];
        
        //add the stopwatch buttons
        [self makeStopWatchButtonsAtGridPoint:CGPointMake(4.0, 2.0)];
        
        
        //Make the ball
        CGPoint tick = [self gridPointX:0.5 pointY:1];
        CGPoint tock = [self gridPointX:4.5 pointY:1];
        SKSpriteNode *bouncingBall = [SKSpriteNode spriteNodeWithImageNamed:@"solidcircle"];
        bouncingBall.position = tock;
        [bouncingBall setScale:0.75];
        bouncingBall.name=@"bouncingBall";
        [self addChild:bouncingBall];
        
        //add fire to the ball using emitters
        NSString *firePath = [[NSBundle mainBundle] pathForResource:@"MyFireParticle" ofType:@"sks"];
        SKEmitterNode *fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
        CGVector emitterVector = CGVectorMake(bouncingBall.frame.size.width * 1.1, 0);
        fireEmitter.particlePositionRange = emitterVector;
        [bouncingBall addChild:fireEmitter];
        
        
        
 
/*
        //simple animation to the ball
        SKAction *bounceBall = [SKAction moveToX:tick.x duration:1.0];
        [bouncingBall runAction:bounceBall withKey:@"bounceBall"];

*/
        //add animation to the ball
        SKAction *bounceBall = [SKAction sequence:@[
                                                    [SKAction moveToX:tock.x duration:1.0],
                                                    [SKAction moveToX:tick.x duration:1.0],
                                                    ]];
        bounceBall.timingMode = SKActionTimingEaseInEaseOut;
        [bouncingBall runAction:[SKAction repeatActionForever:bounceBall] withKey:@"bounceBall"];
        
        //initialize everything else
        isShowingTime = YES;
        isStopwatch = NO;
        previousElapsedTime = 0.0;
        isRunningStopwatch = NO;
        isResettingStopwatch = NO;
    }
    
    return self;
}

-(SKSpriteNode *)makeButtonWithTitleAndName:(NSString *)title withImageNamed:(NSString *)imageName{
    SKSpriteNode *aSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    aSprite.name = title;
    [aSprite setScale:0.75];
    SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    titleNode.text = title;
    titleNode.name = @"title";
    titleNode.fontSize = 16;
    titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    titleNode.position = CGPointMake(CGRectGetMidX(aSprite.frame), CGRectGetMidY(aSprite.frame));
    titleNode.fontColor = [UIColor blackColor];
    [aSprite addChild:titleNode];
    return aSprite;
    
}

-(void)makeStopWatchButtonsAtGridPoint:(CGPoint)gridPoint{
    NSString *image = @"solidcircle";
    //make a base layeranchor is on the right side center.
    //anchor is right middle
        //make button 1 -- start
    SKSpriteNode *startButton = [self makeButtonWithTitleAndName:@"Start" withImageNamed:image];
    startButton.position = [self gridPointX:gridPoint.x pointY:gridPoint.y];
    [self addChild:startButton];
    //make button 2 -- stop
    SKSpriteNode *stopButton = [self makeButtonWithTitleAndName:@"Stop" withImageNamed:image];
    stopButton.position = [self gridPointX:gridPoint.x pointY:gridPoint.y];
    [self addChild:stopButton];
    //make button 3 -- reset
    SKSpriteNode *resetButton = [self makeButtonWithTitleAndName:@"Reset" withImageNamed:image];
    resetButton.position = [self gridPointX:gridPoint.x pointY:gridPoint.y];
    [self addChild:resetButton];
    
    //make a switch to a stopwatch
    SKSpriteNode *modeButton= [self makeButtonWithTitleAndName:@"Mode" withImageNamed:image];
    modeButton.position = [self gridPointX:gridPoint.x pointY:gridPoint.y];
    modeButton.scale = 1.0;
    [self addChild:modeButton];

}

-(SKAction *)moveToGridPositionX:(CGFloat)gridPointX fadeIn:(BOOL)isFadein duration:(NSTimeInterval)duration{
    CGPoint point = [self gridPointX:gridPointX pointY:0.0];
    SKAction *move =[SKAction moveToX:point.x duration:duration];
    SKAction *fadeInOut;
    if (isFadein){
        fadeInOut = [SKAction fadeInWithDuration:duration ];
    }else{
        fadeInOut = [SKAction fadeOutWithDuration:duration];
    }
    return [SKAction group:@[move,fadeInOut]];
}


-(void)animatedStopwatchMenuOpen:(BOOL)isOpen{
    //a method to make buttons appear for the stopwatch
    NSTimeInterval duration = 1.0;
    SKAction *moveButton;
    //get our buttons
    SKNode *modeButton =[self childNodeWithName:@"Mode"];
    SKNode *startButton = [self childNodeWithName:@"Start"];
    SKNode *stopButton = [self childNodeWithName:@"Stop"];
    SKNode *resetButton = [self childNodeWithName:@"Reset"];
    SKNode *title;
    
    if (isOpen){
    //push the on off to the side
        moveButton = [self moveToGridPositionX:5 fadeIn:YES duration:duration];
        [modeButton runAction:moveButton];
        title = [modeButton childNodeWithName:@"title"];
        [title runAction:[SKAction fadeOutWithDuration:duration]];
    //start to poistion 1
        moveButton = [self moveToGridPositionX:1 fadeIn:YES duration:duration];
        [startButton runAction:moveButton];
    //stop to position 2
        moveButton = [self moveToGridPositionX:2 fadeIn:YES duration:duration];
        [stopButton runAction:moveButton];
    //reset to position 3
        moveButton = [self moveToGridPositionX:3 fadeIn:YES duration:duration];
        [resetButton runAction:moveButton];
    }else{
    //close the menu
        moveButton = [self moveToGridPositionX:4 fadeIn:NO duration:duration];
        title = [modeButton childNodeWithName:@"title"];
        [title runAction:[SKAction fadeInWithDuration:duration]];
        
        [startButton runAction:moveButton];
        [stopButton runAction:moveButton];
        [resetButton runAction:moveButton];
        moveButton = [self moveToGridPositionX:4 fadeIn:YES duration:duration];
        [modeButton runAction:moveButton];
    }
}

#pragma mark -----target action
-(void)moveDateOnTop:(BOOL)isDate{
    //set positions for display elements
    CGPoint topDisplay = [self gridPointX:2.5 pointY:4];
    CGPoint bottomDisplay = [self gridPointX:2.5 pointY:3.0];
    
    //make two actions for use
    SKAction *labelHideAction = [SKAction group:@[
                                                  [SKAction fadeAlphaTo:0.2 duration:3.0],
                                                  [SKAction moveToY:bottomDisplay.y duration:3.0]
                                                  ]];
    SKAction *labelShowAction = [SKAction group:@[
                                                  [SKAction fadeInWithDuration:3],
                                                  [SKAction moveToY:topDisplay.y duration:3.0]]];
    
    //remove the previous action.
    [myTimeLabel removeActionForKey:@"timeLabelAction"];
    [myDateLabel removeActionForKey:@"dateLabelAction"];
    
    //run the appropriate action
    if (isDate) {
        [myTimeLabel runAction:labelHideAction withKey:@"timeLabelAction"];
        [myDateLabel runAction:labelShowAction withKey:@"dateLabelAction"];
    }else{
       
        [myTimeLabel runAction:labelShowAction withKey:@"timeLabelAction"];
        [myDateLabel runAction:labelHideAction withKey:@"dateLabelAction"];

    }

}

-(void)screenPressed{
    isStopwatch = NO;
    previousElapsedTime = totalElapsedTime ;
    //move buttons back
    [self animatedStopwatchMenuOpen:NO];
    //toggle action
    [self moveDateOnTop: isShowingTime];
    isShowingTime = !isShowingTime;

}

-(void)modePressed{
    //---------------------code for stopwatch here
    //show the stopwatch buttons
    [self animatedStopwatchMenuOpen:YES];
    //display the date on top
    [self moveDateOnTop:YES];
    isStopwatch = YES;
    isResettingStopwatch = YES;
    isShowingTime = NO;
    isRunningStopwatch = NO;
}

-(void)startPressed{
    isRunningStopwatch = YES;
}
-(void)stopPressed{
    isRunningStopwatch = NO;
    previousElapsedTime += elapsedTimeInterval;
}
-(void)resetPressed{
    isResettingStopwatch = YES;
    isRunningStopwatch = NO;
    previousElapsedTime = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    //find where the buttons are
    CGRect modeRect=[[self childNodeWithName:@"Mode"] frame];
    CGRect startRect=[[self childNodeWithName:@"Start"] frame];
    CGRect stopRect=[[self childNodeWithName:@"Stop"] frame];
    CGRect resetRect=[[self childNodeWithName:@"Reset"] frame];
    
    //scan the touches for button presses
    for (UITouch *touch in touches) {
        CGPoint touchPoint =[touch locationInNode:self];
        //--------------------------code for mode button
        if (CGRectContainsPoint(modeRect, touchPoint)){
            [self modePressed];
        }
        //--------------------------code for starting Stopwatch button
        else if (CGRectContainsPoint(startRect, touchPoint)){
            [self startPressed];
        }else if (CGRectContainsPoint(stopRect, touchPoint )){
        //--------------------------code for stopping Stopwatch button
            [self stopPressed];
        }else if (CGRectContainsPoint(resetRect, touchPoint)) {
        //--------------------------code for resetting Stopwatch button
            [self resetPressed];
        }else{
// shut down Stopwatch if touching anywhere else on screen.
            [self screenPressed];
        }
    }
}

#pragma mark ------game loop
-(void)update:(CFTimeInterval)currentTime {
    
    // time display
    /* Called before each frame is rendered */
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    CFRelease(CFTimeZoneCopySystem());
    NSString *formattedTimeString = [NSString stringWithFormat:@"%02d:%02d:%02.0f", currentDate.hour, currentDate.minute, currentDate.second];
    myTimeLabel.text = formattedTimeString;
    
    /* ------- date or stopwatch display ---------------------  */
    
    if(isStopwatch){
        CFGregorianDate elapsedTime;
        //start the stopwatch by getting a point for elapsed time
        if(isResettingStopwatch){
            startTime=currentTime;
            isResettingStopwatch=NO;
        }
        
        if (isRunningStopwatch) { //get the time interval
        //update the time in the stopwatch
            elapsedTimeInterval =currentTime - startTime;
        } else { //keep start and current time the same for the next start of the watch
            elapsedTimeInterval = 0;
            startTime = currentTime;
        }
        
        totalElapsedTime =(elapsedTimeInterval + previousElapsedTime);
        //format and display the time
        elapsedTime  = CFAbsoluteTimeGetGregorianDate(totalElapsedTime, nil);
        NSString *formattedDateString = [NSString stringWithFormat:@"%02d:%02d:%05.2f", elapsedTime.hour, elapsedTime.minute, elapsedTime.second];
        myDateLabel.text = formattedDateString;
        
    }else{
        NSString *formattedDateString =[NSString stringWithFormat:@"%04d %02d %02d", (int)currentDate.year, currentDate.month, currentDate.day];
    myDateLabel.text = formattedDateString;
    }
    
}

@end
