Shader "Unlit/Wireframe"
{
    Properties{}
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
         
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 baryCentricCoords : TEXCOORD1;
            };
            struct v2g
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 baryCentricCoords : TEXCOORD1;
            };
            typedef v2g g2f;
            
            v2g vert(appdata v)
            {
                v2g o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3],uint primitiveID: SV_PrimitiveID,inout TriangleStream<g2f> outStream)
			{
            	// Reference : https://qiita.com/masamin/items/142b99f139635d19341a
		
				input[0].baryCentricCoords  = float3(0,0.5,1);
				input[1].baryCentricCoords  = float3(0,0.5,1);
				input[2].baryCentricCoords  = float3(0,0.5,1);
				
				outStream.Append(input[0]);
				outStream.Append(input[1]);
				outStream.Append(input[2]);
                
				outStream.RestartStrip();
			}
            
            fixed4 frag(g2f i) : SV_Target
            {
                fixed4 col = float4(float3(0,0.5,1), 1.0);
                return col;
            }
            ENDCG
        }
    }
}
