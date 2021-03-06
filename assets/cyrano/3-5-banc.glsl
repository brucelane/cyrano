// http://glsl.heroku.com/e#11655.0
// minimalistic Neon by @hintz 2013-10-21

void main(void) 
{ float sTime = 0.05 * iTime ;
  vec2 v = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
	vec3 col = (vec3(fract(v.x + sTime*1.8),fract(-0.5*v.x+0.8*v.y + sTime*0.09),fract(-0.5*v.x-0.86*v.y + sTime*0.08))-0.5);
	
	col = 1.0-normalize(col*col);
	gl_FragColor = vec4(col, 1.0);
}