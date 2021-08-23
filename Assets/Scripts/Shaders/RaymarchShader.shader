Shader "FractalShader/RaymarchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StencilMask("Stencil Mask", Int) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "DistanceFunctions.cginc"


            sampler2D _MainTex;
            uniform sampler2D _CameraDepthTexture;

            // All the variables are feeded through camera scipt
            uniform float4x4 camFrustum, camToWorld;
            uniform float maxDistance; // max render distance
            uniform float precision; 
            uniform int iterations;
            uniform float scaleFactor;
            uniform float3 modInterval;
            uniform float3 modOffset;
            uniform float3 modOffsetRot;
            uniform float4x4 globalTransform;
            uniform float3 globalPosition;
            uniform float4x4 rotate45;
            uniform float globalScale;
            uniform float4x4 sectionTransform;
            uniform float3 lightDirection;
            uniform fixed4 mainColor;
            uniform fixed4 secondaryColor;
            uniform int fractalType;
            uniform int useMod;
            uniform int usePlane;
            uniform int useShadow;
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0;
    
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv.xy;
                
                o.ray = camFrustum[(int)index].xyz;
                o.ray /= abs(o.ray.z);
                o.ray = mul(camToWorld, o.ray);

                return o;
            }

            // Function returns distance to fractal
            float2 distanceField(float3 p){
  
                float2 distance;
                
                if(useMod == 1){
                    p.x = pMod(p.x, modInterval.x * globalScale * 2);
                    p.y = pMod(p.y, modInterval.y * globalScale * 2);
                    p.z = pMod(p.z, modInterval.z * globalScale * 2);
                }

                // menger sponge
                if(fractalType == 1){
                    distance = sdMenger(p, globalScale, iterations, modOffset, globalTransform, scaleFactor);
                }
                //sierpinski triangle
                else if(fractalType == 2){
                    distance = sdSierpinski(p, globalScale, iterations, modOffset, globalTransform, scaleFactor, rotate45);
                }
                //menger sponge cut
                else if(fractalType == 3){
                    distance = sdMenger(p, globalScale, iterations, modOffset, globalTransform, scaleFactor);
                    float plane = sdPlane(p, sectionTransform);
                    return max(distance, plane);
                }
                // menger sphere
                else if(fractalType == 4){
                    distance = sdMengerSphere(p, globalScale, iterations, modOffset,
                    globalTransform, scaleFactor);
                }
                // Sphere by default
                else{

                }

                if(usePlane == 1){
                    float plane = sdPlane(p, sectionTransform);
                    return min(distance, plane);
                }

                return distance;
            }

            float3 getNormal(float3 p){
                const float2 offset = float2(0.001, 0.0);
                float3 n = float3(
                    distanceField(p - offset.xyy).x,
                     distanceField(p - offset.yxy).x,
                       distanceField(p - offset.yyx).x
                );

                return normalize(n);
            }

            fixed4 raymarching(float3 ro, float3 rd, float depth){
                fixed4 result = fixed4(0,0,0,0.5);
                float3 colorDepth;
                const int maxIter = 400; // max steps
                float t = 0;

                for(int i = 0; i < maxIter; i++){

                    // send out a ray from the camera
                    float3 p = ro + rd*t;

                     if(t > maxDistance || t >= depth){
                        // if too far draw environment
                        result = fixed4(rd, 0);
                        break;
                    }

                    // get distance to fractal
                    float2 d = distanceField(p);

                    // ray hit an object
                    if(d.x < precision){
                        float shadow;
                        float3 color = float3(mainColor.rgb*(iterations-d.y)/iterations +
                        secondaryColor.rgb * d.y/iterations);
                        float3 n = getNormal(p);
                        float light = dot(-lightDirection, n);

                        if(useShadow == 0){
                            light = 1;
                        }

                        colorDepth = float3(float3(color*light)*(maxDistance-t)/maxDistance);

                        result = fixed4(colorDepth,1);
                        break;
                    }

                    t+=d;
                }

                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
                depth *= length(i.ray);
                fixed3 col = tex2D(_MainTex, i.uv);

                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = raymarching(rayOrigin, rayDirection, depth);

                return fixed4(col * (1.0 - result.w) + result.xyz*result.w,1.0);
            
            }
            ENDCG
        }
    }
}
