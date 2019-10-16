//
//  ShaderView.m
//  iOSOpenGLDemo
//
//  Created by WangQi on 2019/10/16.
//  Copyright © 2019 $(PRODUCT_NAME). All rights reserved.
//

#import "ShaderView.h"
#import <OpenGLES/ES2/gl.h>

@interface ShaderView ()
@property (nonatomic , strong) EAGLContext* myContext;
@property (nonatomic , strong) CAEAGLLayer* myEagLayer;
@property (nonatomic , assign) GLuint       myProgram;


@property (nonatomic , assign) GLuint myColorRenderBuffer;
@property (nonatomic , assign) GLuint myColorFrameBuffer;

- (void)setupLayer;
@end

@implementation ShaderView
+ (Class)layerClass {
	return [CAEAGLLayer class];
}
- (void)layoutSubviews {
	[self setupLayer];
    [self setupContext];
	[self destoryRenderAndFrameBuffer];
	[self setupRenderBuffer];
	[self setupFrameBuffer];
	[self render];
}
#pragma mark - init
- (void)setupLayer {
	self.myEagLayer = (CAEAGLLayer *)self.layer;
	[self setContentScaleFactor:[[UIScreen mainScreen] scale]];
	self.myEagLayer.opaque = YES;
	self.myEagLayer.drawableProperties = @{
		@(NO) : kEAGLDrawablePropertyRetainedBacking,
		kEAGLColorFormatRGBA8 : kEAGLDrawablePropertyColorFormat
	};
}
- (void)setupContext {
	EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
	if (!context) {
		NSLog(@"Failed to initialize OpenGLES 2.0 context");
		exit(1);
	}
	// 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
	self.myContext = context;
}
- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}
- (void)setupRenderBuffer {
	GLuint buffer;
	glGenBuffers(1, &buffer);
	self.myColorFrameBuffer = buffer;
	
	glBindRenderbuffer(GL_RENDERBUFFER, self.myColorFrameBuffer);
	// 分配空间
	[self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}
- (void)setupFrameBuffer {
	GLuint buffer;
	glGenBuffers(1, &buffer);
	self.myColorFrameBuffer = buffer;
	glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
	
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}
- (void)render {
	glClearColor(0, 1.0, 0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	CGFloat scale = [[UIScreen mainScreen] scale]; //获取视图放大倍数，可以把scale设置为1试试
	//设置视口大小
	glViewport(self.frame.origin.x * scale,
			   self.frame.origin.y * scale,
			   self.frame.size.width * scale,
			   self.frame.size.height * scale); //设置视口大小
	//读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
	
	//加载shader
	self.myProgram = [self loadShaders:vertFile frag:fragFile];
	// 链接
	glLinkProgram(self.myProgram);
	
	GLint linkSuccess;
	glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
	
	if (linkSuccess == GL_FALSE) {
		GLchar message[256];
		glGetProgramInfoLog(self.myProgram, sizeof(message), 0, &message[0]);
		NSString *messageString = [NSString stringWithUTF8String:message];
		NSLog(@"error %@",messageString);
	} else {
		NSLog(@"link ok");
		glUseProgram(self.myProgram);
	}
	
	GLfloat attrArr[] =
    {
		0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
		0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
		-0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上

		0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
		-0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
		-0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
	
	GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
	
	GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
	
	[self setupTexture:@"for_test"];
	
	//获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    GLuint rotate = glGetUniformLocation(self.myProgram, "rotateMatrix");
	float radians = 10 * 3.14159f / 180.0f;
	//    float s = sin(radians);
	//    float c = cos(radians);
	float s = 0;
	float c = 1;
	//z轴旋转矩阵
	GLfloat zRotation[16] = { //
		c, -s, 0, 0.2, //
		s, c, 0, 0,//
		0, 0, 1.0, 0,//
		0.0, 0, 0, 1.0//
	};
	//设置旋转矩阵
	glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
	
	glDrawArrays(GL_TRIANGLES, 0, 6);
	[self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}
- (GLuint)setupTexture:(NSString *)fileName {
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
	UIImage *image = [UIImage imageWithContentsOfFile:filePath];
	CGImageRef spriteImage = image.CGImage;
	if (!spriteImage) {
		NSLog(@"Filed to load image %@",fileName);
		exit(1);
	}
	// 读取图片大小
	size_t width = CGImageGetWidth(spriteImage);
	size_t height = CGImageGetHeight(spriteImage);
	// calloc-在内存的动态存储区中分配num个长度为size的连续空间，函数返回一个指向分配起始地址的指针
	// rgba 4字节，所以大小要*4
	GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
	
	// 获得上下文
	CGContextRef spriteContent = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
	// 绘图
	CGContextDrawImage(spriteContent, CGRectMake(0, 0, width, height), spriteImage);
	CGContextRelease(spriteContent);
	
	// 绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
	glBindTexture(GL_TEXTURE_2D, 0);
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    return 0;
}
/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *  @return 编译成功的shaders
 */
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag {
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert]; // 顶点
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag]; // 片无
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
	NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
	const char *source = (GLchar *)[content UTF8String];
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
}
@end
