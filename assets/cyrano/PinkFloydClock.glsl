// https://www.shadertoy.com/view/7dlSzr
#define S smoothstep 
#define PI 3.14159265359
#define TAU 6.283185307179586
#define RES iResolution.xy

vec3 ShapeN(vec2 st, int N, float w, float h){

  vec3 color = vec3(0.0);
  float d = 0.0;

  // Remap the space to -1. to 1.
  st = st *2.-1.;
  st.x += 1.0 ;
  st.y += .7;
  st.y /= h;
    st.x *= w;
  // Number of sides of your shape
  //int N = 3;

  // Angle and radius from the current pixel
  float a = atan(st.x,st.y)+PI;
  float r = TAU/float(N);

  // Shaping function that modulates the distance
  d = cos(floor(.5+a/r)*r-a)*length(st);

  color = vec3(S(.41,.4,d));

    return color;
}
vec2 polarMap(vec2 uv, float shift, float inner) {

    uv = vec2(0.5) - uv;
    
    
    float px = 1.0 - fract(atan(uv.y, uv.x) / 6.28 + 0.25) + shift;
    float py = (length(uv) * (1.0 + inner * 2.0) - inner) * 2.0;
    
    return vec2(px, py);
}
vec2 rot (vec2 p,float a)
{
    float c = cos(a);
    float s = sin(a);
    return p*mat2(c,s,-s,c);
}
float circle (vec2 p, float r, float g)
{

    float d = length(p / r);

    float ss = S(.32,.32 - g,d);
    
    ss = max(0.,ss);
    return ss;

}
float segment(vec2 P, vec2 A, vec2 B, float r) 
{
    vec2 g = B - A;
    vec2 h = P - A;
    float d = length(h - g * clamp(dot(g, h) / dot(g,g), 0.0, 1.0));
	return S(r, 0.7*r, d);
}
float segmentT(vec2 P, vec2 A, vec2 B, float r) 
{
    vec2 g = B - A;
    vec2 h = P - A ;
    float d = length(h - g * clamp(dot(g , h ) / dot(g,g), 0.0, 1.0));
    

	return S(r, 0.7*r, d);
}



vec4 Hand(vec2 uv , float l, float w, float t)
{
    vec4 col = vec4(0.);
    

    float h = segmentT(uv,vec2(0,0.),rot(vec2(0.,.8 * l)  ,t * TAU/60.  ) , 1. * RES.y/RES.x * w);
    
    uv *= .35;
    vec4 shape = vec4(ShapeN(rot( uv * 1.5, -t* TAU/60.) , 7,/* Width*/6.,/* Height*/ l - .2),1.);
    col += shape;
    col *=  h + shape;

 
    col.a = col.r;// at this point, each of the rgb vals is at 1. and showing the mask, so store it in the A channel.
    
    col = max (col,vec4(0.));
    return col;
}

vec4 HandsShadow(vec2 uv , float l, float w, float t , float b)
{
    vec4 col = vec4(0.);
    
    uv.y += .05;
    uv.x -= .02;
    float h = segmentT(uv,vec2(0,0.),rot(vec2(0.,.8 * l)  ,t * TAU/60.  ) , w);
    uv.y += .02;
    uv *= .45;
    vec4 shape = vec4(ShapeN(rot( uv * 1.5, -t* TAU/60.) , 7,/* Width*/6. * w,/* Height*/ l - .2),1.);
    col += shape;
    col *=  h + shape;

    col -= length(uv.y) * 2.; // attenuate based on height

    col = max (col,vec4(0.));
    return col * .1;
}
vec4 Dial(vec2 uv, float m)
{
    
    vec4 col = vec4(0.);
    vec2 fuv = polarMap(uv + .5, .008 , .0) * .5;
    
    
    fuv.x = fract(fuv.x * 8. ) ;
    col += vec4(ShapeN(fuv+vec2(0.,-.6) ,4  ,  3.15, 0.8 ),0.7) * .5;
    
    
    uv = polarMap(uv + .5, .0035 , .25) * .5;
    
    uv.x = fract(uv.x * 24. * m ) ;

    vec2 id = floor(uv * 24.  );

    if(id.x <=  1.6 && id.y >= 18. && id.y <= 26.)return col = vec4(.35);

    col = clamp(col,0.,1.);
    return col;
}


//returns a working clock
vec4 ClockFace(vec2 uv){

    vec4 col = vec4(0.,0.,0.,1.);
    
    vec4 wt = vec4(.8,.7,0.,1.);// sample wood tex
    
    wt += S(-.7,.1,-abs(uv.y)); // add shine
    
    float f = circle(uv,4.3, .001 );//clocks frame
    float fm = (1. - (circle(uv,4.3, .055 ) )) * .6;//clocks frame bevel
    f -= fm;
    col += f;
    col -= circle(uv,3.8, .001 ) - circle(uv,3.7, .001 );//clocks frame
    col = mix(col,  wt ,  col - circle(uv,3.7, .001 )); // apply wood tex

    //Decoration at 12 o'clock
    col += circle(uv + vec2(0.,-1.03),0.3, .001 ) * 0.5;
    col -= circle(uv + vec2(0.,-1.03),0.25, .001 ) * 0.5;
   // col += circle(uv + vec2(0.,-1.0),0.3, .5 );
    col -= vec4(ShapeN(uv+vec2(0.,-.5) ,5  ,  5.15, 1.15 ),0.7) * .3;
    col += circle(   uv + vec2(0.,-.8) ,0.1, .1 );
    
    col -= (circle(uv,3.6, .001 ) * .18) + (-uv.y * .1); //inset and shading
    
    // Shadow
    float d = length(uv + vec2(0.,0.1 ))* 0.88;
    float m = 1. - circle(uv,4.3,.0001);
  
    
     //add the dial and decoration
    col -= Dial(uv/1.3, 1.);
    
    //---------- time is set here------------

    //vec4 iDate = iDate;
    float mils = fract(iDate.w);
	float secs = mod( (iDate.w),        60.0 );
	float mins = 0.0;//mod( (iDate.w/60.0),   60.0 );
	float hors = 6.0;//mod( (iDate.w/3600.0) + 0.0, 24.0 );


    vec4 ch1 = Hand(uv, 0.9,0.9, hors  * TAU * .8 );//hours hand
    
    ch1 = clamp(ch1,0.,1.);
    col -= ch1;
    vec4 ch1s = HandsShadow(uv , 1.,.9, hors  * TAU * .8 , .5);
    col -= ch1s;

    vec4 ch2 = Hand(uv , 1.6,0.5, mins);//minutes hand

    ch2 = clamp(ch2,0.,1.);
    col -= ch2;
    vec4 ch2s = HandsShadow(uv , 1.7,.7, mins , .5);
    col -= ch2s;

    //vec4 ch3 = Hand(uv ,  2.0, .07 ,secs ); //secondes hand
    vec4 ch3 = vec4(segmentT(uv,vec2(0,0.),rot(vec2(0.,1.0)  ,secs * TAU/60.  ) , 
    1. * RES.y/RES.x * .05 ));
   // vec4 ch3m = Hand(uv , 1.1, .05 ,secs ); //secondes hand m
    //ch3 -= ch3m;
    

    ch3 = clamp(ch3,0.,1.);
    col -= ch3;
    vec4 ch3s = vec4(segmentT(uv,vec2(0,-0.02),rot(vec2(0.1* uv.y ,  1. - uv.y * .1)  ,secs * TAU/60.  ) , 
    1. * RES.y/RES.x * .05 )) * .1;
    col -= ch3s;
    
    vec4 hCol = vec4(0.4,0.4,0.4,1.);// clock hand clr
    
    float sh = -   dot(-uv.x * .5,.5) + dot(-uv.y * .5,.5) + .8 ;// clock hands shading
    
    
    vec4 tex1 =hCol / sh;// texture(iChannel0,(rot( uv * 2., -secs* TAU/60.)));
    vec4 tex2 =hCol/ sh;// texture(iChannel0,(rot( uv * 2., -mins* TAU/60.)));
    vec4 tex3 =hCol/ sh;// texture(iChannel0,(rot( uv * 2., -hors* TAU/60.)));// we also have to spin the texture per hand!
  
    col = mix (col, ch1 * tex3  , ch1) ;
    col = mix (col,ch2 * tex2 ,ch2 ) ;
    col = mix (col,ch3 * tex1 ,ch3 ) ;

    //------------End of Time setting-----------------  
   
    float cc =  circle(uv,0.3, .001 ) ;//clocks hand cover
    cc = ceil(cc);
    
    cc = max(cc,0.);
    cc = min(cc,1.);
    
    col =  mix(vec4(cc * .3) , col,1. -cc);
    col += vec4(circle(uv,0.3, .2 ) * .3) *(fract( uv.y* 50. - .1)  ) ; // dot on the clock hand cover
    
    col -= circle(uv,3.7, .001 ) * .18;// glass cover
    col += max((circle(uv,3.9, .05 ) * .3 * uv.y),0.);
     m = 1. - circle(uv,4.3,.001);
    col.a =  1.- m;
    col = col - m;
    col = max(vec4(0.),col);
    return col;   
}

void main(void)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (gl_FragCoord.xy -.5* iResolution.xy)/iResolution.y;
    vec2 ouv = uv;
    
    vec4 col = vec4(0.0);

     uv *= 3.;
    
     col -= max( 1. - length((uv + vec2(.0,.1))* .63), 0.) ;
    vec4 cf = ClockFace(uv);
    col = mix(col,cf,cf.a);
       
    // Output to screen
    gl_FragColor = col;
}
