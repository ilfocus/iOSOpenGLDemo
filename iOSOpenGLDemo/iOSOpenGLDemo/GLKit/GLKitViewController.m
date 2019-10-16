//
//  GLKitViewController1.m
//  iOSOpenGLDemo
//
//  Created by WangQi on 2019/10/16.
//  Copyright © 2019 $(PRODUCT_NAME). All rights reserved.
//

#import "GLKitViewController.h"

@interface GLKitViewController ()
@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) GLKBaseEffect *mEffect;
@end

@implementation GLKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
    [self uploadVertexArray];
    [self uploadTexture];
}

#pragma mark - init
- (void)setupConfig {
	self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
	
	GLKView *view = (GLKView *)self.view;
	view.frame = CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight);
	view.context = self.mContext;
	view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	[EAGLContext setCurrentContext:self.mContext];
}

- (void)uploadVertexArray {
	//顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat squareVertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上

        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
	// 顶点数据缓存
	GLuint buffer;
	// glGenBuffers申请一个标识符
	glGenBuffers(1, &buffer);
	//glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	// glBufferData()或者 glBufferSubData()
	//— 让 OpenGL ES 为当前绑定的缓存分配 并初始化足够的连续内存(通常是从 CPU 控制的内存复制数据到分配的内存)
	glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
	
	//glEnableVertexAttribArray()或 者glDisableVertexAttribArray()
	//— 告 诉 OpenGL ES 在接下来的渲染中是否使用缓存中的数据
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	//glVertexAttribPointer设置合适的格式从buffer里面读取数据
	glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
	
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
	
}

- (void)uploadTexture {
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
	NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
	
	//GLKTextureLoader读取图片，创建纹理GLKTextureInfo
	GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:option error:nil];
	
	self.mEffect = [[GLKBaseEffect alloc] init];
	self.mEffect.texture2d0.enabled = GL_TRUE;
	self.mEffect.texture2d0.name = textureInfo.name;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	glClearColor(0.3f, 0.1f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// 启动着色器
	[self.mEffect prepareToDraw];
	glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
