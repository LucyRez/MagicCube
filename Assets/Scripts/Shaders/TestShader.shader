Shader "Fractals/RaymarchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #pragma target 3.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform sampler2D _CameraDepthTexture;
            uniform float4 camWorldSpace;
            uniform float4 sphere;
            uniform float maxDistance;
            uniform float4x4 camFrustum, camToWorld;
            uniform float3 lightDirection;

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
                o.uv = v.uv;

                o.ray = camFrustum[(int)index].xyz;

                o.ray /= abs(o.ray.z);

                o.ray = mul(camToWorld, o.ray);
                return o;
            }

            float sdSphere(float3 position, float scale){
                return length(position) - scale;
            }

            float distanceField(float3 position){
                float Sphere = sdSphere(position - sphere.xyz, sphere.w);
                return Sphere;
            }

            float3 getNormal(float3 position){
                const float2 offset = float2(0.001, 0.0);
                float3 normal = float3(
                    distanceField(position + offset.xyy) - distanceField(position - offset.xyy),
                     distanceField(position + offset.yxy) - distanceField(position - offset.yxy),
                      distanceField(position + offset.yyx) - distanceField(position - offset.yyx)
                );

                return normalize(normal);
            }

             fixed4 raymarching(float3 origin, float3 direction, float depth){
                fixed4 result = fixed4(1,1,1,1);
                
                const int maxIter = 256;
                float distanceTravelled = 0; // distance travelled along the ray direction

                for(int i = 0; i < maxIter; i++){
                    if(distanceTravelled  > maxDistance || distanceTravelled >= depth){
                        // Draw the environment

                        result = fixed4(direction, 0);
                        break;
                    }

                    float3 position = origin + direction * distanceTravelled;

                    // Check for hit in distance field
                    float distance = distanceField(position);

                    // if we hit smth
                    if(distance < 0.01){
                        //shading

                        float3 normal = getNormal(position);
                        float light = dot(-lightDirection, normal);

                        result = fixed4(fixed3(1,1,1) * light,1);
                        break;
                    }

                    distanceTravelled += distance;
                }

                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {

              float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
               depth *= length(i.ray);
               fixed3 color = tex2D(_MainTex, i.uv);
               float3 rayDirection = normalize(i.ray.xyz);
               float3 rayOrigin = _WorldSpaceCameraPos;
               fixed4 result = raymarching(rayOrigin, rayDirection, depth);
               return fixed4(color * (1.0 - result.w) + result.xyz * result.w,1.0);
            }
            ENDCG
        }
    }
}
