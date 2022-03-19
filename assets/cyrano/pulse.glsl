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

// bas du trait bas
#define PI 3.14159265359
#define BTB  0.3
#define DEC  0.2

float entre( float x, float min, float max )
{
    return step( min, x ) * step( x, max );
}

void main(void)
{ //vec2 uv = inData.v_texcoord;
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec3 color ;
  float itime = time * 0.3  ;
  float y = uv.y ;
  float x = uv.x ;

  // lda : limite droite pour rouge jaune et bleu : dépend du temps.
  // 10 seconde pour traverser l'écran => part de 0, puis augmente
  float htt = ( 1.0 - 2.0 * BTB ) / 6 ;     // hauteur de trait
  float btb = BTB + sin( itime );

  // déplacement horizontal :
  float gx = 0.6 + sin( itime ) * 0.6   ;
  float dx = 0.6 - sin( itime ) * 0.6   ;
  float trou1 =( step( gx, x ) + step( x, gx - 0.2 ) ) ;
  float trou2 =( step( dx, x ) + step( x, dx - 0.2 ) ) ;
  // les 6 lignes violet -> rouge
  color += rouge  * entre( y, BTB+5.0*htt, BTB+6.0*htt ) * trou2 ;
  color += orange * entre( y, BTB+4.0*htt, BTB+5.0*htt ) * trou1 ;
  color += jaune  * entre( y, BTB+3.0*htt, BTB+4.0*htt ) * trou2 ;
  color += vert   * entre( y, BTB+2.0*htt, BTB+3.0*htt ) * trou1 ;
  color += bleu   * entre( y, BTB+1.0*htt, BTB+2.0*htt ) * trou2 ;
  color += violet * entre( y, BTB+0.0*htt, BTB+1.0*htt ) * trou1 ;

  // Le pulse
  float p = ( BTB+2.0*htt ) + 0.4 * sin( 5.0*time + 5.0*PI*x ) * cos( 4.0*time + 4.0*x  ) ;

  // p = p * ( 1 - trou1 );
  float pct = step( p, y) - step( p + htt, y);
  color = ( 1 - pct ) * color  + vert * pct ;

  fragColor = vec4( color, 1.0 ) ;

}