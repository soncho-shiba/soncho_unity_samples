Shader "Unlit/SolidWireFrame"
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
            // This software contains source code provided by NVIDIA Corporation.  
            // このソフトウェアにはNVIDIA Corporationによって提供されたソースコードが含まれています
            // SolidWireframe.fx  Copyright (c) 2007 NVIDIA Corporation.
            
            // Reference : Direct3D SDK SolidWireframe  
            // https://developer.download.nvidia.com/SDK/10/direct3d/Source/SolidWireframe/Doc/SolidWireframe.pdf

            #pragma vertex vert
            #pragma fragment frag
         
            #include "UnityCG.cginc"
            
            float LineWidth = 1.5;
            float FadeDistance = 50;
            float PatternPeriod = 1.5;

            float4 FillColor = float4(0.1, 0.2, 0.4, 1);
            float4 WireColor = float4(1, 1, 1, 1);
            float4 PatternColor = float4(1, 1, 0.5, 1);
            
            uint infoA[]     = { 0, 0, 0, 0, 1, 1, 2 };
            uint infoB[]     = { 1, 1, 2, 0, 2, 1, 2 };
            uint infoAd[]    = { 2, 2, 1, 1, 0, 0, 0 };
            uint infoBd[]    = { 2, 2, 1, 2, 0, 2, 1 };
            
            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2g
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                noperspective float4 EdgeA: TEXCOORD1;
                noperspective float4 EdgeB: TEXCOORD2;
                uint Case : TEXCOORD3;
            };
            
            v2g vert(appdata v)
            {
                v2g o;
                o.pos = v.pos;
                o.uv = v.uv;
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3],uint primitiveID: SV_PrimitiveID,inout TriangleStream<g2f> outStream)
			{
                g2f output;
                
                // Compute the case from the positions of point in space.
                output.Case = (input[0].pos.z < 0)*4 + (input[1].pos.z < 0)*2 + (input[2].pos.z < 0); 

                // If case is all vertices behind viewpoint (case = 7) then cull.
                if (output.Case == 7) return;

                
                // Transform position to window space
                // 頂点シェーダーからの入力をビュー座標に変換
                float2 points[3];
                points[0] = UnityObjectToClipPos(input[0].pos);
                points[1] = UnityObjectToClipPos(input[1].pos);
                points[2] = UnityObjectToClipPos(input[2].pos);
                
                // If Case is 0, all projected points are defined, do the
                // general case computation
                if (output.Case == 0) 
                {
				output.EdgeA = float4(0,0,0,0);
                output.EdgeB = float4(0,0,0,0);
                
                // Compute the case from the positions of point in space.
                // ビュー座標の頂点位置の差分からエッジのベクトルを計算
                float2 edges[3];
                edges[0] = points[0] - points[0];
                edges[1] = points[2] - points[1];
                edges[2] = points[0] - points[2];
                
                // Store the length of the edges
                // 各エッジベクトルの長さを取得
                float lengths[3];
                lengths[0] = length(edges[0]);
                lengths[1] = length(edges[1]);
                lengths[2] = length(edges[2]);

                // Compute the cos angle of each vertices
                float cosAngles[3];
                cosAngles[0] = dot( -edges[2], edges[0]) / ( lengths[2] * lengths[0] );
                cosAngles[1] = dot( -edges[0], edges[1]) / ( lengths[0] * lengths[1] );
                cosAngles[2] = dot( -edges[1], edges[2]) / ( lengths[1] * lengths[2] );
                
                // The height for each vertices of the triangle
                float heights[3];
                heights[1] = lengths[0]*sqrt(1 - cosAngles[0]*cosAngles[0]);
                heights[2] = lengths[1]*sqrt(1 - cosAngles[1]*cosAngles[1]);
                heights[0] = lengths[2]*sqrt(1 - cosAngles[2]*cosAngles[2]);
                
                float edgeSigns[3];
                edgeSigns[0] = (edges[0].x > 0 ? 1 : -1);
                edgeSigns[1] = (edges[1].x > 0 ? 1 : -1);
                edgeSigns[2] = (edges[2].x > 0 ? 1 : -1);

                float edgeOffsets[3];
                edgeOffsets[0] = lengths[0]*(0.5 - 0.5*edgeSigns[0]);
                edgeOffsets[1] = lengths[1]*(0.5 - 0.5*edgeSigns[1]);
                edgeOffsets[2] = lengths[2]*(0.5 - 0.5*edgeSigns[2]);

                output.pos =( input[0].pos );
                output.EdgeA[0] = 0;
                output.EdgeA[1] = heights[0];
                output.EdgeA[2] = 0;
                output.EdgeB[0] = edgeOffsets[0];
                output.EdgeB[1] = edgeOffsets[1] + edgeSigns[1] * cosAngles[1]*lengths[0];
                output.EdgeB[2] = edgeOffsets[2] + edgeSigns[2] * lengths[2];
                outStream.Append( output );

                output.pos = ( input[1].pos );
                output.EdgeA[0] = 0;
                output.EdgeA[1] = 0;
                output.EdgeA[2] = heights[1];
                output.EdgeB[0] = edgeOffsets[0] + edgeSigns[0] * lengths[0];
                output.EdgeB[1] = edgeOffsets[1];
                output.EdgeB[2] = edgeOffsets[2] + edgeSigns[2] * cosAngles[2]*lengths[1];
                outStream.Append( output );

                output.pos = ( input[2].pos );
                output.EdgeA[0] = heights[2];
                output.EdgeA[1] = 0;
                output.EdgeA[2] = 0;
                output.EdgeB[0] = edgeOffsets[0] + edgeSigns[0] * cosAngles[0]*lengths[2];
                output.EdgeB[1] = edgeOffsets[1] + edgeSigns[1] * lengths[1];
                output.EdgeB[2] = edgeOffsets[2];

                outStream.Append( output );
				outStream.RestartStrip();
}
                // Else need some tricky computations
                else
                {
                    // Then compute and pass the edge definitions from the case
                    output.EdgeA.xy = points[ infoA[output.Case] ];
                    output.EdgeB.xy = points[ infoB[output.Case] ];

		            output.EdgeA.zw = normalize( output.EdgeA.xy - points[ infoAd[output.Case] ] ); 
                    output.EdgeB.zw = normalize( output.EdgeB.xy - points[ infoBd[output.Case] ] );
		            
		            // Generate vertices
                    output.pos =( input[0].pos );
                    outStream.Append( output );
                 
                    output.pos = ( input[1].pos );
                    outStream.Append( output );

                    output.pos = ( input[2].pos );
                    outStream.Append( output );

                    outStream.RestartStrip();
                }
			}
            
        float evalMinDistanceToEdges(in g2f input)
        {
            float dist;

            // The easy case, the 3 distances of the fragment to the 3 edges is already
            // computed, get the min.
            if (input.Case == 0)
            {
                dist = min ( min (input.EdgeA.x, input.EdgeA.y), input.EdgeA.z);
            }
            // The tricky case, compute the distances and get the min from the 2D lines
            // given from the geometry shader.
            else
            {
                // Compute and compare the sqDist, do one sqrt in the end.
        	        
                float2 AF = input.pos.xy - input.EdgeA.xy;
                float sqAF = dot(AF,AF);
                float AFcosA = dot(AF, input.EdgeA.zw);
                dist = abs(sqAF - AFcosA*AFcosA);

                float2 BF = input.pos.xy - input.EdgeB.xy;
                float sqBF = dot(BF,BF);
                float BFcosB = dot(BF, input.EdgeB.zw);
                dist = min( dist, abs(sqBF - BFcosB*BFcosB) );
               
                // Only need to care about the 3rd edge for some cases.
                if (input.Case == 1 || input.Case == 2 || input.Case == 4)
                {
                    float AFcosA0 = dot(AF, normalize(input.EdgeB.xy - input.EdgeA.xy));
			        dist = min( dist, abs(sqAF - AFcosA0*AFcosA0) );
	            }

                dist = sqrt(dist);
            }

            return dist;
        }
            
            fixed4 frag(g2f input) : SV_Target
            {   
                // Compute the shortest distance between the fragment and the edges.
                float dist = evalMinDistanceToEdges(input);

                // Cull fragments too far from the edge.
                if (dist > 0.5*LineWidth+1) discard;

                // Map the computed distance to the [0,2] range on the border of the line.
                dist = clamp((dist - (0.5*LineWidth - 1)), 0, 2);

                // Alpha is computed from the function exp2(-2(x)^2).
                // 
                dist *= dist;
                float alpha = exp2(-2*dist);

                float4 color = WireColor;
                color.a *= alpha;
	            
                return color;
            }
            ENDCG
        }
    }
}
