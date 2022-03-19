#version 150

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform vec3 spectrum;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D prevFrame;
uniform sampler2D prevPass;

in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;

out vec4 fragColor;

#define rouge  vec3(1.0, 0.0, 0.0)
#define orange vec3(1.0, 0.5, 0.0)
#define jaune  vec3(1.0, 1.0, 0.0)
#define vert   vec3(0.0, 0.5, 0.0)
#define bleu   vec3(0.0, 0.0, 1.0)
#define violet vec3(0.5, 0.0, 0.5)
#define noir   vec3(0.0, 0.0, 0.0)
#define blanc  vec3(1.0, 1.0, 1.0)

vec3 arc[8] ;
void initabArc()
{
   arc[0] = noir ;
   arc[1] = violet ;
   arc[2] = bleu;
   arc[3] = vert ;
   arc[4] = jaune ;
   arc[5] = orange ;
   arc[6] = rouge ;
   arc[7] = noir ;
}

vec3 rainbow(float level )
{  int i = int(level) ;
   i = min( i, 7 );
   i = max( i, 0 );
   return arc[i];
}

vec3 plainRainbow( float x )
{
    return rainbow( floor(x*6.0) + 1 ) ;
}

// nbre de rangées :
#define NBR 7
vec3 smoothRainbow (float x)
{   // return plainRainbow(x); // Pour les tests
    float level1 = floor(x*NBR);
    float level2 = min(NBR, floor(x*NBR) + 1.0);

    vec3 a = rainbow(level1 );
    vec3 b = rainbow(level2 );

    return mix(a, b, fract(x*NBR));
}
// ratio larg ecran / hauteur :
#define RATIO ( resolution.x / resolution.y )
// RB = rayon blanc E=epaisseur, B=bas, H=haut
#define IRBE  0.01
#define IRBB  0.6
#define IRBH  0.55
// ILRG : largeur max de l'arc en ciel
#define ILRG 0.7
// Largeur du point central
#define CLRG 0.02
// y de la base du triangle :
#define THB  0.3
// longueur coté triangle :
#define TLNG 0.3
// y du triangle
#define TY 0.58
#define PI 3.141596

float plot(float y, float pct){
  return  smoothstep( pct-0.14, pct, y) -
          step( pct, y) ;
}

float triangle(vec2 p, float size) {
    vec2 q = abs(p);
    return max( q.x * RATIO + p.y * 0.5, - p.y * 0.6) - size * 0.5;
}


void main(void)
{   //vec2 uv = inData.v_texcoord;
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec3 color ;
    float itime = time * 0.3  ;
    float y = uv.y ;
    float x = uv.x ;

    float beat = sin( itime * PI / 2.0 ) ;

    // Triangle V2
    // Modif du triangle en fonction du temps :
    float tlng = TLNG + beat * 0.03 + spectrum.y * 0.7   ;
    float tepais  = tlng * 0.2 ;
    float text = triangle(uv - vec2(0.5, TY ), tlng) ;
    float tint = triangle(uv - vec2(0.5, TY - tepais / 6.0 ), tlng - tepais * 0.6  ) ;
    color = blanc * ( 1 - smoothstep( 0, text, tint ) ) ;

    // Le trait blanc
    float xg = 2 * x ;
    // On fait varier RBB en fonction du temps :
    float RBB = IRBB + beat * 0.5 ;
    float RBH =  IRBH ;
    float RBE = IRBE + abs( cos( itime ) * 0.001 ) ;
    // trait blanc jusqu'au milieu
    float limD = 1 ;
    float limB = RBB + xg * ( RBH - RBB ) ;
    float limH = limB + RBE ;
    float trD = 1 - smoothstep( limD-CLRG, limD+CLRG, xg  ) ;
    float trB =     smoothstep( limB-0.02, limB, y )  ;
    float trH = 1 - smoothstep( limH, limH + 0.02, y )  ;
    float trLim = trD * trB * trH ;
    color = color + blanc * trLim  ;

    // L'arc
    // Couleurs de l'arc
    initabArc() ;
    // Dimensions
    float LRG = ILRG + abs( cos( itime ) * 0.1 );
    float xd = ( x - 0.5 ) * 2 ; // 0 = centre, 1 = droite
    float lh = RBH + 2 * RBE - xd * ( RBH - RBB - ( LRG + RBE ) / 2 ) ; // Limite haut de l'arc
    float lb = RBH - 2 * RBE - xd * ( RBH - RBB + ( LRG + RBE ) / 2 ) ;
    float limG = 0.5 ;
    float arG = smoothstep( limG - CLRG , limG + CLRG , x );
    float arB = step( lb, y );
    float arH = step( y, lh );
    float arLim = arG * arB * arH ;

    float ampY = lh - lb ;          // Amplitude de Y en fonction de xd
    float Y = ( ( y - lb ) / ampY )  ;
    color = color + smoothRainbow(Y) * arLim  ;
    // color = plainRainbow(Y) * arG;
    fragColor = vec4(color,1.0);
}
