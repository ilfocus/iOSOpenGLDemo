//
//  AdvanceViewController.m
//  iOSOpenGLDemo
//
//  Created by WangQi on 2019/10/17.
//  Copyright © 2019 $(PRODUCT_NAME). All rights reserved.
//

#import "AdvanceViewController.h"

@interface AdvanceViewController () {
	dispatch_source_t timer;
}
@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) GLKBaseEffect *mEffect;

@property (nonatomic, assign) int mCount;
@property (nonatomic, assign) float mDegreeX;
@property (nonatomic, assign) float mDegreeY;
@property (nonatomic, assign) float mDegreeZ;

@property (nonatomic, assign) BOOL mBoolX;
@property (nonatomic, assign) BOOL mBoolY;
@property (nonatomic, assign) BOOL mBoolZ;
@end

@implementation AdvanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 新建三个按钮
	UIButton *xButton = [[UIButton alloc] init];
	xButton.frame = CGRectMake(kScreenWidth / 4, kTopHeight + 10, 30, 30);
	[xButton setTitle:@"X轴" forState:(UIControlStateNormal)];
	xButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	[xButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
	xButton.backgroundColor = [UIColor whiteColor];
	[xButton addTarget:self action:@selector(xButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
	[self.view addSubview:xButton];
	
	UIButton *yButton = [[UIButton alloc] init];
	yButton.frame = CGRectMake(kScreenWidth / 2, kTopHeight + 10, 30, 30);
	[yButton setTitle:@"Y轴" forState:(UIControlStateNormal)];
	[yButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
	yButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	yButton.backgroundColor = [UIColor whiteColor];
	[yButton addTarget:self action:@selector(yButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
	[self.view addSubview:yButton];
	
	UIButton *zButton = [[UIButton alloc] init];
	zButton.frame = CGRectMake(kScreenWidth * 3 / 4, kTopHeight + 10, 30, 30);
	[zButton setTitle:@"Z轴" forState:(UIControlStateNormal)];
	zButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	[zButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
	zButton.backgroundColor = [UIColor whiteColor];
	[zButton addTarget:self action:@selector(zButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
	[self.view addSubview:zButton];
	
	//新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView* view = (GLKView *)self.view;
	view.frame = CGRectMake(0, kTopHeight + 40, kScreenWidth, kScreenHeight);
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    glEnable(GL_DEPTH_TEST);
	
	[self renderNew];
	
}
- (void)xButtonClick {
	_mBoolX = !_mBoolX;
}
- (void)yButtonClick {
	_mBoolY = !_mBoolY;
}
- (void)zButtonClick {
	_mBoolZ = !_mBoolZ;
}
- (void)renderNew {
    
    //顶点数据，前三个是顶点坐标， 中间三个是顶点颜色，    最后两个是纹理坐标
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    self.mCount = sizeof(indices) / sizeof(GLuint);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
    //顶点颜色
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 6);

    
    //纹理
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
    
    
    
    //初始的投影
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    
    //定时器
    double delayInSeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.mDegreeX += 0.1  * self.mBoolX;
        self.mDegreeY += 0.1 * self.mBoolY;
        self.mDegreeZ += 0.1 * self.mBoolZ;
        
    });
    dispatch_resume(timer);
}
/**
 *  场景数据变化
 */
- (void)update {
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegreeX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegreeY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegreeZ);
    
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
}


/**
 *  渲染场景代码
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    [self.mEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}
@end
