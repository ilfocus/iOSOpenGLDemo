//片元着色器的目标是输出像素颜色，gl_FragColor必须赋值
varying lowp vec2 varyTextCoord;

uniform sampler2D colorMap;


void main()
{
    gl_FragColor = texture2D(colorMap, varyTextCoord);
}
