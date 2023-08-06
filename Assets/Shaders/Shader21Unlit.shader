﻿Shader "NiksShaders/Shader21Unlit"
{
    Properties
    {
        _AxisColor("Axis Color", Color) = (0.8, 0.8, 0.8, 1)
        _SweepColor("Sweep Color", Color) = (0.1, 0.3, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members position)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 position: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                return o;
            }
            
            float getDelta(float x){
                return (sin(x)+1.0)/2.0;
            }

            float sweep(float2 pt, float2 center, float radius, float line_width, float edge_thickness){
                float2 d = pt - center;
                float theta = _Time.z;
                float2 p = float2(cos(theta), -sin(theta))*radius;
                float h = clamp( dot(d,p)/dot(p,p), 0.0, 1.0 );
                //float h = dot(d,p)/dot(p,p);
                float l = length(d - p*h);

                float gradient = 0.0;
                const float gradient_angle = UNITY_PI * 0.2;

                if (length(d)<radius){
                    float angle = fmod(theta + atan2(d.y, d.x), UNITY_TWO_PI);
                    gradient = clamp(gradient_angle - angle, 0.0, gradient_angle)/gradient_angle * 0.5;
                }

                return gradient + 1.0 - smoothstep(line_width, line_width+edge_thickness, l);
            }

            float circle(float2 pt, float2 center, float radius, float line_width, float edge_thickness){
                pt -= center;
                float len = length(pt);
                //Change true to false to soften the edge
                float result = smoothstep(radius-line_width/2.0-edge_thickness, radius-line_width/2.0, len) - smoothstep(radius + line_width/2.0, radius + line_width/2.0 + edge_thickness, len);

                return result;
            }

            float onLine(float x, float y, float line_width, float edge_width){
                return smoothstep(x-line_width/2.0-edge_width, x-line_width/2.0, y) - smoothstep(x+line_width/2.0, x+line_width/2.0+edge_width, y);
            }

            float polygon(float2 pt, float2 center, float radius, int sides, float rotate, float edge_thickness){
                pt -= center;

                // Angle and radius from the current pixel
                float theta = atan2(pt.y, pt.x) + rotate;
                float rad = UNITY_TWO_PI/float(sides);

                // Shaping function that modulate the distance
                float d = cos(floor(0.5 + theta/rad)*rad-theta)*length(pt);

                return 1.0 - smoothstep(radius, radius + edge_thickness, d);
            }
            
            fixed4 _AxisColor;
            fixed4 _SweepColor;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color = onLine(i.uv.y, 0.5, 0.002, 0.001) * _AxisColor;//xAxis
                color += onLine(i.uv.x, 0.5, 0.002, 0.001) * _AxisColor;//yAxis

                float2 center = 0.5;
                color += circle(i.uv, center, 0.3, 0.002, 0.001) * _AxisColor;
                color += circle(i.uv, center, 0.2, 0.002, 0.001) * _AxisColor;
                color += circle(i.uv, center, 0.1, 0.002, 0.001) * _AxisColor;

                color += sweep(i.uv, center, 0.3, 0.003, 0.001) * _SweepColor;
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
