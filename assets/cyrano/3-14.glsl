const float PI = 3.14159265358979323846264;

void main(void)
{
   vec2 uv = 2.0 * iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
   float xTime = iTime*0.2;
   // calculate the centre of the circular sines
   vec2 center = iZoom * vec2((iResolution.x / 2.0) + sin(xTime) * (iResolution.x / 1.5),
                  (iResolution.y / 2.0) + cos(xTime) * (iResolution.y / 1.5));
   center.x -= iRenderXY.x;
   center.y -= iRenderXY.y;
   
   float distance = length(gl_FragCoord.xy - center);
   
   // circular plasmas sines
   float circ = (sin(distance / (iResolution.x / 7.6) + sin(xTime * 1.1) * 5.0) + 1.25)
            + (sin(distance / (iResolution.x / 11.5) - sin(xTime * 1.1) * 6.0) + 1.25);
   
   // x and y plasma sines
   float xval = (sin(gl_FragCoord.x / (iResolution.x / 6.5) + sin(xTime * 1.1) * 4.5) + 1.25)
            + (sin(gl_FragCoord.x / (iResolution.x / 9.2) - sin(xTime * 1.1) * 5.5) + 1.25);
   
   float yval = (sin(gl_FragCoord.y / (iResolution.x / 6.8) + sin(xTime * 1.1) * 4.75) + 1.25)
            + (sin(gl_FragCoord.y / (iResolution.x / 12.5) - sin(xTime * 1.1) * 5.75) + 1.25);

   // add the values together for the pixel
   float tval = circ + xval + yval / 3.0;
   
   // work out the colour
   vec3 color = vec3((cos(PI * tval / 4.0 + xTime * 3.0) + 1.0) / 2.0,
                 (sin(PI * tval / 3.5 + xTime * 3.0) + 1.0) / 2.5,
                 (sin(PI * tval / 2.0 + xTime * 3.0) + 2.0) / 8.0);
   
  gl_FragColor = vec4(color,1.0);
}
