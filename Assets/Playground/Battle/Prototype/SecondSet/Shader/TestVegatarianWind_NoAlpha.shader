Shader "Custom/TestVegatarianWind_NoAlpha"
{
    Properties
    {
        [NoScaleOffset] _MainTex("Sprite Texture", 2D) = "white" {}
        RimColor("Rim Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_MaskTex("Mask Texture", 2D) = "white" {}
        [NoScaleOffset]_NormalMap("Normal Texture", 2D) = "bump" {}
        Vector2_AB971143("Wind Direction", Vector) = (2, 0, 0, 0)
        Vector1_52D24AB4("Wind Scale", Float) = 1
        Vector1_36BC0FD6("Wind Strength", Float) = 0.1
        Vector1_3AEF5FB5("Wind Speed", Float) = 2
        Vector1_7AA64B76("Wind Influence Mask  - Y Position", Float) = 4
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz = input.sh;
            #endif
            output.interp7.xyzw = input.fogFactorAndVertexLight;
            output.interp8.xyzw = input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 RimColor;
        float4 _MaskTex_TexelSize;
        float4 _NormalMap_TexelSize;
        float2 Vector2_AB971143;
        float Vector1_52D24AB4;
        float Vector1_36BC0FD6;
        float Vector1_3AEF5FB5;
        float Vector1_7AA64B76;
        CBUFFER_END

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

            // Graph Functions

            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }


            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_Preview_float(float In, out float Out)
            {
                Out = In;
            }

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent = input.tangentOS;
                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition = input.positionOS;
                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                output.uv0 = input.uv0;
                output.TimeParameters = _TimeParameters.xyz;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }


            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>

                // Defines
                #define _AlphaClip 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                    float3 AbsoluteWorldSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz = input.sh;
                    #endif
                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                    output.interp8.xyzw = input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 RimColor;
                float4 _MaskTex_TexelSize;
                float4 _NormalMap_TexelSize;
                float2 Vector2_AB971143;
                float Vector1_52D24AB4;
                float Vector1_36BC0FD6;
                float Vector1_3AEF5FB5;
                float Vector1_7AA64B76;
                CBUFFER_END

                    // Object and Global properties
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);
                    TEXTURE2D(_MaskTex);
                    SAMPLER(sampler_MaskTex);
                    TEXTURE2D(_NormalMap);
                    SAMPLER(sampler_NormalMap);
                    SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                    // Graph Functions

                    void Unity_Absolute_float(float In, out float Out)
                    {
                        Out = abs(In);
                    }

                    void Unity_Power_float(float A, float B, out float Out)
                    {
                        Out = pow(A, B);
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    void Unity_Multiply_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }


                    float2 Unity_GradientNoise_Dir_float(float2 p)
                    {
                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                        p = p % 289;
                        // need full precision, otherwise half overflows when p > 1
                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                        x = (34 * x + 1) * x % 289;
                        x = frac(x / 41) * 2 - 1;
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float2 p = UV * Scale;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Preview_float(float In, out float Out)
                    {
                        Out = In;
                    }

                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                    {
                        RGBA = float4(R, G, B, A);
                        RGB = float3(R, G, B);
                        RG = float2(R, G);
                    }

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                        float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                        Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                        float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                        float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                        Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                        float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                        Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                        float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                        float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                        float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                        float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                        float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                        float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                        float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                        Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                        float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                        float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                        Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                        float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                        Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                        float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                        float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                        float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                        Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                        float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                        float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                        Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                        float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                        float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                        Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                        float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                        Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                        float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                        float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                        float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                        float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                        float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                        float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                        Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                        float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                        description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                        float AlphaClipThreshold;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                        float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                        Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                        float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                        float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                        float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                        float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                        float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                        Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                        float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                        float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                        float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                        Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                        float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                        float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                        float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                        float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                        surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = 0.5;
                        surface.Occlusion = 1;
                        surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                        surface.AlphaClipThreshold = 0.5;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs

                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                        output.ObjectSpaceTangent = input.tangentOS;
                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                        output.ObjectSpacePosition = input.positionOS;
                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                        output.uv0 = input.uv0;
                        output.TimeParameters = _TimeParameters.xyz;

                        return output;
                    }

                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.uv0 = input.texCoord0;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                        return output;
                    }


                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    ENDHLSL
                }
                Pass
                {
                    Name "ShadowCaster"
                    Tags
                    {
                        "LightMode" = "ShadowCaster"
                    }

                        // Render State
                        Cull Off
                        Blend One Zero
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        // PassKeywords: <None>
                        // GraphKeywords: <None>

                        // Defines
                        #define _AlphaClip 1
                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        struct Attributes
                        {
                            float3 positionOS : POSITION;
                            float3 normalOS : NORMAL;
                            float4 tangentOS : TANGENT;
                            float4 uv0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                            float4 uv0;
                        };
                        struct VertexDescriptionInputs
                        {
                            float3 ObjectSpaceNormal;
                            float3 WorldSpaceNormal;
                            float3 ObjectSpaceTangent;
                            float3 WorldSpaceTangent;
                            float3 ObjectSpaceBiTangent;
                            float3 WorldSpaceBiTangent;
                            float3 ObjectSpacePosition;
                            float3 AbsoluteWorldSpacePosition;
                            float4 uv0;
                            float3 TimeParameters;
                        };
                        struct PackedVaryings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 interp0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            output.positionCS = input.positionCS;
                            output.interp0.xyzw = input.texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }
                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.texCoord0 = input.interp0.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _MainTex_TexelSize;
                        float4 RimColor;
                        float4 _MaskTex_TexelSize;
                        float4 _NormalMap_TexelSize;
                        float2 Vector2_AB971143;
                        float Vector1_52D24AB4;
                        float Vector1_36BC0FD6;
                        float Vector1_3AEF5FB5;
                        float Vector1_7AA64B76;
                        CBUFFER_END

                            // Object and Global properties
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);
                            TEXTURE2D(_MaskTex);
                            SAMPLER(sampler_MaskTex);
                            TEXTURE2D(_NormalMap);
                            SAMPLER(sampler_NormalMap);
                            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                            // Graph Functions

                            void Unity_Absolute_float(float In, out float Out)
                            {
                                Out = abs(In);
                            }

                            void Unity_Power_float(float A, float B, out float Out)
                            {
                                Out = pow(A, B);
                            }

                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                            {
                                Out = clamp(In, Min, Max);
                            }

                            void Unity_Multiply_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }


                            float2 Unity_GradientNoise_Dir_float(float2 p)
                            {
                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                p = p % 289;
                                // need full precision, otherwise half overflows when p > 1
                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                x = (34 * x + 1) * x % 289;
                                x = frac(x / 41) * 2 - 1;
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                            {
                                float2 p = UV * Scale;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Preview_float(float In, out float Out)
                            {
                                Out = In;
                            }

                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                            {
                                RGBA = float4(R, G, B, A);
                                RGB = float3(R, G, B);
                                RG = float2(R, G);
                            }

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                                float AlphaClipThreshold;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                surface.AlphaClipThreshold = 0.5;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs

                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                output.ObjectSpaceTangent = input.tangentOS;
                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                output.ObjectSpacePosition = input.positionOS;
                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                output.uv0 = input.uv0;
                                output.TimeParameters = _TimeParameters.xyz;

                                return output;
                            }

                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                output.uv0 = input.texCoord0;
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                return output;
                            }


                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            ENDHLSL
                        }
                        Pass
                        {
                            Name "DepthOnly"
                            Tags
                            {
                                "LightMode" = "DepthOnly"
                            }

                                // Render State
                                Cull Off
                                Blend One Zero
                                ZTest LEqual
                                ZWrite On
                                ColorMask 0

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines
                                #define _AlphaClip 1
                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                struct Attributes
                                {
                                    float3 positionOS : POSITION;
                                    float3 normalOS : NORMAL;
                                    float4 tangentOS : TANGENT;
                                    float4 uv0 : TEXCOORD0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                    float4 positionCS : SV_POSITION;
                                    float4 texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                    float4 uv0;
                                };
                                struct VertexDescriptionInputs
                                {
                                    float3 ObjectSpaceNormal;
                                    float3 WorldSpaceNormal;
                                    float3 ObjectSpaceTangent;
                                    float3 WorldSpaceTangent;
                                    float3 ObjectSpaceBiTangent;
                                    float3 WorldSpaceBiTangent;
                                    float3 ObjectSpacePosition;
                                    float3 AbsoluteWorldSpacePosition;
                                    float4 uv0;
                                    float3 TimeParameters;
                                };
                                struct PackedVaryings
                                {
                                    float4 positionCS : SV_POSITION;
                                    float4 interp0 : TEXCOORD0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyzw = input.texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }
                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.texCoord0 = input.interp0.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _MainTex_TexelSize;
                                float4 RimColor;
                                float4 _MaskTex_TexelSize;
                                float4 _NormalMap_TexelSize;
                                float2 Vector2_AB971143;
                                float Vector1_52D24AB4;
                                float Vector1_36BC0FD6;
                                float Vector1_3AEF5FB5;
                                float Vector1_7AA64B76;
                                CBUFFER_END

                                    // Object and Global properties
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);
                                    TEXTURE2D(_MaskTex);
                                    SAMPLER(sampler_MaskTex);
                                    TEXTURE2D(_NormalMap);
                                    SAMPLER(sampler_NormalMap);
                                    SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                    // Graph Functions

                                    void Unity_Absolute_float(float In, out float Out)
                                    {
                                        Out = abs(In);
                                    }

                                    void Unity_Power_float(float A, float B, out float Out)
                                    {
                                        Out = pow(A, B);
                                    }

                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                    {
                                        Out = clamp(In, Min, Max);
                                    }

                                    void Unity_Multiply_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }


                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                    {
                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                        p = p % 289;
                                        // need full precision, otherwise half overflows when p > 1
                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                        x = (34 * x + 1) * x % 289;
                                        x = frac(x / 41) * 2 - 1;
                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                    }

                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                    {
                                        float2 p = UV * Scale;
                                        float2 ip = floor(p);
                                        float2 fp = frac(p);
                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Preview_float(float In, out float Out)
                                    {
                                        Out = In;
                                    }

                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                    {
                                        RGBA = float4(R, G, B, A);
                                        RGB = float3(R, G, B);
                                        RG = float2(R, G);
                                    }

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                        float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                        Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                        float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                        float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                        Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                        float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                        Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                        float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                        float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                        float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                        float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                        float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                        float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                        float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                        Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                        float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                        float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                        Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                        float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                        Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                        float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                        float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                        float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                        Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                        float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                        float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                        Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                        float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                        float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                        Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                        float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                        Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                        float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                        float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                        float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                        float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                        float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                        float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                        Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                        float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                        description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float Alpha;
                                        float AlphaClipThreshold;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                        float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                        Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                        float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                        float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                        float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                        float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                        float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                        Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                        float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                        float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                        float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                        Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                        surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                        surface.AlphaClipThreshold = 0.5;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs

                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                        output.ObjectSpaceTangent = input.tangentOS;
                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                        output.ObjectSpacePosition = input.positionOS;
                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                        output.uv0 = input.uv0;
                                        output.TimeParameters = _TimeParameters.xyz;

                                        return output;
                                    }

                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                        output.uv0 = input.texCoord0;
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                        return output;
                                    }


                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    ENDHLSL
                                }
                                Pass
                                {
                                    Name "DepthNormals"
                                    Tags
                                    {
                                        "LightMode" = "DepthNormals"
                                    }

                                        // Render State
                                        Cull Off
                                        Blend One Zero
                                        ZTest LEqual
                                        ZWrite On

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma multi_compile_instancing
                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        // PassKeywords: <None>
                                        // GraphKeywords: <None>

                                        // Defines
                                        #define _AlphaClip 1
                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        struct Attributes
                                        {
                                            float3 positionOS : POSITION;
                                            float3 normalOS : NORMAL;
                                            float4 tangentOS : TANGENT;
                                            float4 uv0 : TEXCOORD0;
                                            float4 uv1 : TEXCOORD1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                            float4 positionCS : SV_POSITION;
                                            float3 normalWS;
                                            float4 tangentWS;
                                            float4 texCoord0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                            float3 TangentSpaceNormal;
                                            float4 uv0;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                            float3 ObjectSpaceNormal;
                                            float3 WorldSpaceNormal;
                                            float3 ObjectSpaceTangent;
                                            float3 WorldSpaceTangent;
                                            float3 ObjectSpaceBiTangent;
                                            float3 WorldSpaceBiTangent;
                                            float3 ObjectSpacePosition;
                                            float3 AbsoluteWorldSpacePosition;
                                            float4 uv0;
                                            float3 TimeParameters;
                                        };
                                        struct PackedVaryings
                                        {
                                            float4 positionCS : SV_POSITION;
                                            float3 interp0 : TEXCOORD0;
                                            float4 interp1 : TEXCOORD1;
                                            float4 interp2 : TEXCOORD2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.normalWS;
                                            output.interp1.xyzw = input.tangentWS;
                                            output.interp2.xyzw = input.texCoord0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }
                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.normalWS = input.interp0.xyz;
                                            output.tangentWS = input.interp1.xyzw;
                                            output.texCoord0 = input.interp2.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _MainTex_TexelSize;
                                        float4 RimColor;
                                        float4 _MaskTex_TexelSize;
                                        float4 _NormalMap_TexelSize;
                                        float2 Vector2_AB971143;
                                        float Vector1_52D24AB4;
                                        float Vector1_36BC0FD6;
                                        float Vector1_3AEF5FB5;
                                        float Vector1_7AA64B76;
                                        CBUFFER_END

                                            // Object and Global properties
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);
                                            TEXTURE2D(_MaskTex);
                                            SAMPLER(sampler_MaskTex);
                                            TEXTURE2D(_NormalMap);
                                            SAMPLER(sampler_NormalMap);
                                            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                            // Graph Functions

                                            void Unity_Absolute_float(float In, out float Out)
                                            {
                                                Out = abs(In);
                                            }

                                            void Unity_Power_float(float A, float B, out float Out)
                                            {
                                                Out = pow(A, B);
                                            }

                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                            {
                                                Out = clamp(In, Min, Max);
                                            }

                                            void Unity_Multiply_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }


                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                            {
                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                p = p % 289;
                                                // need full precision, otherwise half overflows when p > 1
                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                x = (34 * x + 1) * x % 289;
                                                x = frac(x / 41) * 2 - 1;
                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                            }

                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                            {
                                                float2 p = UV * Scale;
                                                float2 ip = floor(p);
                                                float2 fp = frac(p);
                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Preview_float(float In, out float Out)
                                            {
                                                Out = In;
                                            }

                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                            {
                                                RGBA = float4(R, G, B, A);
                                                RGB = float3(R, G, B);
                                                RG = float2(R, G);
                                            }

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 NormalTS;
                                                float Alpha;
                                                float AlphaClipThreshold;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                surface.AlphaClipThreshold = 0.5;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs

                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                output.ObjectSpaceTangent = input.tangentOS;
                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                output.ObjectSpacePosition = input.positionOS;
                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                output.uv0 = input.uv0;
                                                output.TimeParameters = _TimeParameters.xyz;

                                                return output;
                                            }

                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                output.uv0 = input.texCoord0;
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                return output;
                                            }


                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                            ENDHLSL
                                        }
                                        Pass
                                        {
                                            Name "Meta"
                                            Tags
                                            {
                                                "LightMode" = "Meta"
                                            }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                                                // GraphKeywords: <None>

                                                // Defines
                                                #define _AlphaClip 1
                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_META
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                struct Attributes
                                                {
                                                    float3 positionOS : POSITION;
                                                    float3 normalOS : NORMAL;
                                                    float4 tangentOS : TANGENT;
                                                    float4 uv0 : TEXCOORD0;
                                                    float4 uv1 : TEXCOORD1;
                                                    float4 uv2 : TEXCOORD2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                    float4 positionCS : SV_POSITION;
                                                    float4 texCoord0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                    float4 uv0;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                    float3 ObjectSpaceNormal;
                                                    float3 WorldSpaceNormal;
                                                    float3 ObjectSpaceTangent;
                                                    float3 WorldSpaceTangent;
                                                    float3 ObjectSpaceBiTangent;
                                                    float3 WorldSpaceBiTangent;
                                                    float3 ObjectSpacePosition;
                                                    float3 AbsoluteWorldSpacePosition;
                                                    float4 uv0;
                                                    float3 TimeParameters;
                                                };
                                                struct PackedVaryings
                                                {
                                                    float4 positionCS : SV_POSITION;
                                                    float4 interp0 : TEXCOORD0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyzw = input.texCoord0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }
                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0 = input.interp0.xyzw;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _MainTex_TexelSize;
                                                float4 RimColor;
                                                float4 _MaskTex_TexelSize;
                                                float4 _NormalMap_TexelSize;
                                                float2 Vector2_AB971143;
                                                float Vector1_52D24AB4;
                                                float Vector1_36BC0FD6;
                                                float Vector1_3AEF5FB5;
                                                float Vector1_7AA64B76;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    TEXTURE2D(_MainTex);
                                                    SAMPLER(sampler_MainTex);
                                                    TEXTURE2D(_MaskTex);
                                                    SAMPLER(sampler_MaskTex);
                                                    TEXTURE2D(_NormalMap);
                                                    SAMPLER(sampler_NormalMap);
                                                    SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                    // Graph Functions

                                                    void Unity_Absolute_float(float In, out float Out)
                                                    {
                                                        Out = abs(In);
                                                    }

                                                    void Unity_Power_float(float A, float B, out float Out)
                                                    {
                                                        Out = pow(A, B);
                                                    }

                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                    {
                                                        Out = clamp(In, Min, Max);
                                                    }

                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }


                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                    {
                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                        p = p % 289;
                                                        // need full precision, otherwise half overflows when p > 1
                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                        x = (34 * x + 1) * x % 289;
                                                        x = frac(x / 41) * 2 - 1;
                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                    }

                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                    {
                                                        float2 p = UV * Scale;
                                                        float2 ip = floor(p);
                                                        float2 fp = frac(p);
                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Preview_float(float In, out float Out)
                                                    {
                                                        Out = In;
                                                    }

                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                    {
                                                        RGBA = float4(R, G, B, A);
                                                        RGB = float3(R, G, B);
                                                        RG = float2(R, G);
                                                    }

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                        float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                        Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                        float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                        float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                        Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                        float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                        Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                        float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                        float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                        float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                        float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                        float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                        float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                        float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                        Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                        float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                        float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                        Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                        float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                        Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                        float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                        float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                        float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                        Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                        float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                        float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                        Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                        float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                        float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                        Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                        float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                        Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                        float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                        float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                        Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                        float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                        description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                        float Alpha;
                                                        float AlphaClipThreshold;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                        float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                        Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                        float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                        Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                        float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                        float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                        float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                        Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                        surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                                                        surface.Emission = float3(0, 0, 0);
                                                        surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                        surface.AlphaClipThreshold = 0.5;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs

                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                        output.ObjectSpacePosition = input.positionOS;
                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                        output.uv0 = input.uv0;
                                                        output.TimeParameters = _TimeParameters.xyz;

                                                        return output;
                                                    }

                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                        output.uv0 = input.texCoord0;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                        return output;
                                                    }


                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    ENDHLSL
                                                }
                                                Pass
                                                {
                                                        // Name: <None>
                                                        Tags
                                                        {
                                                            "LightMode" = "Universal2D"
                                                        }

                                                        // Render State
                                                        Cull Off
                                                        Blend One Zero
                                                        ZTest LEqual
                                                        ZWrite On

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines
                                                        #define _AlphaClip 1
                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_2D
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        struct Attributes
                                                        {
                                                            float3 positionOS : POSITION;
                                                            float3 normalOS : NORMAL;
                                                            float4 tangentOS : TANGENT;
                                                            float4 uv0 : TEXCOORD0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                            float4 positionCS : SV_POSITION;
                                                            float4 texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                            float4 uv0;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                            float3 ObjectSpaceNormal;
                                                            float3 WorldSpaceNormal;
                                                            float3 ObjectSpaceTangent;
                                                            float3 WorldSpaceTangent;
                                                            float3 ObjectSpaceBiTangent;
                                                            float3 WorldSpaceBiTangent;
                                                            float3 ObjectSpacePosition;
                                                            float3 AbsoluteWorldSpacePosition;
                                                            float4 uv0;
                                                            float3 TimeParameters;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                            float4 positionCS : SV_POSITION;
                                                            float4 interp0 : TEXCOORD0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyzw = input.texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }
                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.texCoord0 = input.interp0.xyzw;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _MainTex_TexelSize;
                                                        float4 RimColor;
                                                        float4 _MaskTex_TexelSize;
                                                        float4 _NormalMap_TexelSize;
                                                        float2 Vector2_AB971143;
                                                        float Vector1_52D24AB4;
                                                        float Vector1_36BC0FD6;
                                                        float Vector1_3AEF5FB5;
                                                        float Vector1_7AA64B76;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            TEXTURE2D(_MainTex);
                                                            SAMPLER(sampler_MainTex);
                                                            TEXTURE2D(_MaskTex);
                                                            SAMPLER(sampler_MaskTex);
                                                            TEXTURE2D(_NormalMap);
                                                            SAMPLER(sampler_NormalMap);
                                                            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                            // Graph Functions

                                                            void Unity_Absolute_float(float In, out float Out)
                                                            {
                                                                Out = abs(In);
                                                            }

                                                            void Unity_Power_float(float A, float B, out float Out)
                                                            {
                                                                Out = pow(A, B);
                                                            }

                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                            {
                                                                Out = clamp(In, Min, Max);
                                                            }

                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }


                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                            {
                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                p = p % 289;
                                                                // need full precision, otherwise half overflows when p > 1
                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                x = (34 * x + 1) * x % 289;
                                                                x = frac(x / 41) * 2 - 1;
                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                            }

                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                            {
                                                                float2 p = UV * Scale;
                                                                float2 ip = floor(p);
                                                                float2 fp = frac(p);
                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Preview_float(float In, out float Out)
                                                            {
                                                                Out = In;
                                                            }

                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                            {
                                                                RGBA = float4(R, G, B, A);
                                                                RGB = float3(R, G, B);
                                                                RG = float2(R, G);
                                                            }

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float3 BaseColor;
                                                                float Alpha;
                                                                float AlphaClipThreshold;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                                                                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                surface.AlphaClipThreshold = 0.5;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs

                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                output.ObjectSpacePosition = input.positionOS;
                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                output.uv0 = input.uv0;
                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                return output;
                                                            }

                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                output.uv0 = input.texCoord0;
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                return output;
                                                            }


                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                            ENDHLSL
                                                        }
    }
        SubShader
                                                            {
                                                                Tags
                                                                {
                                                                    "RenderPipeline" = "UniversalPipeline"
                                                                    "RenderType" = "Opaque"
                                                                    "UniversalMaterialType" = "Lit"
                                                                    "Queue" = "AlphaTest"
                                                                }
                                                                Pass
                                                                {
                                                                    Name "Universal Forward"
                                                                    Tags
                                                                    {
                                                                        "LightMode" = "UniversalForward"
                                                                    }

                                                                // Render State
                                                                Cull Off
                                                                Blend One Zero
                                                                ZTest LEqual
                                                                ZWrite On

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 2.0
                                                                #pragma only_renderers gles gles3 glcore
                                                                #pragma multi_compile_instancing
                                                                #pragma multi_compile_fog
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                                                                #pragma multi_compile _ LIGHTMAP_ON
                                                                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                                                                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                                                                #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                                                                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                                                                #pragma multi_compile _ _SHADOWS_SOFT
                                                                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                // GraphKeywords: <None>

                                                                // Defines
                                                                #define _AlphaClip 1
                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                #define VARYINGS_NEED_TANGENT_WS
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_FORWARD
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                struct Attributes
                                                                {
                                                                    float3 positionOS : POSITION;
                                                                    float3 normalOS : NORMAL;
                                                                    float4 tangentOS : TANGENT;
                                                                    float4 uv0 : TEXCOORD0;
                                                                    float4 uv1 : TEXCOORD1;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                    float4 positionCS : SV_POSITION;
                                                                    float3 positionWS;
                                                                    float3 normalWS;
                                                                    float4 tangentWS;
                                                                    float4 texCoord0;
                                                                    float3 viewDirectionWS;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    float2 lightmapUV;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    float3 sh;
                                                                    #endif
                                                                    float4 fogFactorAndVertexLight;
                                                                    float4 shadowCoord;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                    float3 TangentSpaceNormal;
                                                                    float4 uv0;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                    float3 ObjectSpaceNormal;
                                                                    float3 WorldSpaceNormal;
                                                                    float3 ObjectSpaceTangent;
                                                                    float3 WorldSpaceTangent;
                                                                    float3 ObjectSpaceBiTangent;
                                                                    float3 WorldSpaceBiTangent;
                                                                    float3 ObjectSpacePosition;
                                                                    float3 AbsoluteWorldSpacePosition;
                                                                    float4 uv0;
                                                                    float3 TimeParameters;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                    float4 positionCS : SV_POSITION;
                                                                    float3 interp0 : TEXCOORD0;
                                                                    float3 interp1 : TEXCOORD1;
                                                                    float4 interp2 : TEXCOORD2;
                                                                    float4 interp3 : TEXCOORD3;
                                                                    float3 interp4 : TEXCOORD4;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    float2 interp5 : TEXCOORD5;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    float3 interp6 : TEXCOORD6;
                                                                    #endif
                                                                    float4 interp7 : TEXCOORD7;
                                                                    float4 interp8 : TEXCOORD8;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyz = input.positionWS;
                                                                    output.interp1.xyz = input.normalWS;
                                                                    output.interp2.xyzw = input.tangentWS;
                                                                    output.interp3.xyzw = input.texCoord0;
                                                                    output.interp4.xyz = input.viewDirectionWS;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    output.interp5.xy = input.lightmapUV;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    output.interp6.xyz = input.sh;
                                                                    #endif
                                                                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                                                                    output.interp8.xyzw = input.shadowCoord;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }
                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.positionWS = input.interp0.xyz;
                                                                    output.normalWS = input.interp1.xyz;
                                                                    output.tangentWS = input.interp2.xyzw;
                                                                    output.texCoord0 = input.interp3.xyzw;
                                                                    output.viewDirectionWS = input.interp4.xyz;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    output.lightmapUV = input.interp5.xy;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    output.sh = input.interp6.xyz;
                                                                    #endif
                                                                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                                                                    output.shadowCoord = input.interp8.xyzw;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _MainTex_TexelSize;
                                                                float4 RimColor;
                                                                float4 _MaskTex_TexelSize;
                                                                float4 _NormalMap_TexelSize;
                                                                float2 Vector2_AB971143;
                                                                float Vector1_52D24AB4;
                                                                float Vector1_36BC0FD6;
                                                                float Vector1_3AEF5FB5;
                                                                float Vector1_7AA64B76;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    TEXTURE2D(_MainTex);
                                                                    SAMPLER(sampler_MainTex);
                                                                    TEXTURE2D(_MaskTex);
                                                                    SAMPLER(sampler_MaskTex);
                                                                    TEXTURE2D(_NormalMap);
                                                                    SAMPLER(sampler_NormalMap);
                                                                    SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                                    // Graph Functions

                                                                    void Unity_Absolute_float(float In, out float Out)
                                                                    {
                                                                        Out = abs(In);
                                                                    }

                                                                    void Unity_Power_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = pow(A, B);
                                                                    }

                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                    {
                                                                        Out = clamp(In, Min, Max);
                                                                    }

                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }


                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                    {
                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                        p = p % 289;
                                                                        // need full precision, otherwise half overflows when p > 1
                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                        x = (34 * x + 1) * x % 289;
                                                                        x = frac(x / 41) * 2 - 1;
                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                    }

                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                    {
                                                                        float2 p = UV * Scale;
                                                                        float2 ip = floor(p);
                                                                        float2 fp = frac(p);
                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                    }

                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Preview_float(float In, out float Out)
                                                                    {
                                                                        Out = In;
                                                                    }

                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                    {
                                                                        RGBA = float4(R, G, B, A);
                                                                        RGB = float3(R, G, B);
                                                                        RG = float2(R, G);
                                                                    }

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                        float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                        Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                        float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                        float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                        Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                        float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                        Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                        float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                        float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                        float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                        float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                        float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                        float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                        float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                        Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                        float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                        float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                        Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                        float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                        Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                        float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                        float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                        Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                        float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                        Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                        float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                        float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                        Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                        float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                        float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                        Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                        float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                        Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                        float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                        float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                        Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                        float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                        description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float3 BaseColor;
                                                                        float3 NormalTS;
                                                                        float3 Emission;
                                                                        float Metallic;
                                                                        float Smoothness;
                                                                        float Occlusion;
                                                                        float Alpha;
                                                                        float AlphaClipThreshold;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                        float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                        Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                        float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                        Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                        float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                        float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                        float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                        Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                        surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                                                                        surface.NormalTS = IN.TangentSpaceNormal;
                                                                        surface.Emission = float3(0, 0, 0);
                                                                        surface.Metallic = 0;
                                                                        surface.Smoothness = 0.5;
                                                                        surface.Occlusion = 1;
                                                                        surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                        surface.AlphaClipThreshold = 0.5;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs

                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                        output.uv0 = input.uv0;
                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                        return output;
                                                                    }

                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                        output.uv0 = input.texCoord0;
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                        return output;
                                                                    }


                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                    ENDHLSL
                                                                }
                                                                Pass
                                                                {
                                                                    Name "ShadowCaster"
                                                                    Tags
                                                                    {
                                                                        "LightMode" = "ShadowCaster"
                                                                    }

                                                                        // Render State
                                                                        Cull Off
                                                                        Blend One Zero
                                                                        ZTest LEqual
                                                                        ZWrite On
                                                                        ColorMask 0

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma only_renderers gles gles3 glcore
                                                                        #pragma multi_compile_instancing
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        // PassKeywords: <None>
                                                                        // GraphKeywords: <None>

                                                                        // Defines
                                                                        #define _AlphaClip 1
                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        struct Attributes
                                                                        {
                                                                            float3 positionOS : POSITION;
                                                                            float3 normalOS : NORMAL;
                                                                            float4 tangentOS : TANGENT;
                                                                            float4 uv0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                            float4 positionCS : SV_POSITION;
                                                                            float4 texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                            float4 uv0;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                            float3 ObjectSpaceNormal;
                                                                            float3 WorldSpaceNormal;
                                                                            float3 ObjectSpaceTangent;
                                                                            float3 WorldSpaceTangent;
                                                                            float3 ObjectSpaceBiTangent;
                                                                            float3 WorldSpaceBiTangent;
                                                                            float3 ObjectSpacePosition;
                                                                            float3 AbsoluteWorldSpacePosition;
                                                                            float4 uv0;
                                                                            float3 TimeParameters;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                            float4 positionCS : SV_POSITION;
                                                                            float4 interp0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyzw = input.texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }
                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.texCoord0 = input.interp0.xyzw;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _MainTex_TexelSize;
                                                                        float4 RimColor;
                                                                        float4 _MaskTex_TexelSize;
                                                                        float4 _NormalMap_TexelSize;
                                                                        float2 Vector2_AB971143;
                                                                        float Vector1_52D24AB4;
                                                                        float Vector1_36BC0FD6;
                                                                        float Vector1_3AEF5FB5;
                                                                        float Vector1_7AA64B76;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            TEXTURE2D(_MainTex);
                                                                            SAMPLER(sampler_MainTex);
                                                                            TEXTURE2D(_MaskTex);
                                                                            SAMPLER(sampler_MaskTex);
                                                                            TEXTURE2D(_NormalMap);
                                                                            SAMPLER(sampler_NormalMap);
                                                                            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                                            // Graph Functions

                                                                            void Unity_Absolute_float(float In, out float Out)
                                                                            {
                                                                                Out = abs(In);
                                                                            }

                                                                            void Unity_Power_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = pow(A, B);
                                                                            }

                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                            {
                                                                                Out = clamp(In, Min, Max);
                                                                            }

                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }


                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                            {
                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                p = p % 289;
                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                x = (34 * x + 1) * x % 289;
                                                                                x = frac(x / 41) * 2 - 1;
                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                            }

                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                            {
                                                                                float2 p = UV * Scale;
                                                                                float2 ip = floor(p);
                                                                                float2 fp = frac(p);
                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                            }

                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Preview_float(float In, out float Out)
                                                                            {
                                                                                Out = In;
                                                                            }

                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                            {
                                                                                RGBA = float4(R, G, B, A);
                                                                                RGB = float3(R, G, B);
                                                                                RG = float2(R, G);
                                                                            }

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float Alpha;
                                                                                float AlphaClipThreshold;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                                surface.AlphaClipThreshold = 0.5;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs

                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                                output.uv0 = input.uv0;
                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                return output;
                                                                            }

                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                output.uv0 = input.texCoord0;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                return output;
                                                                            }


                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                            ENDHLSL
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "DepthOnly"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "DepthOnly"
                                                                            }

                                                                                // Render State
                                                                                Cull Off
                                                                                Blend One Zero
                                                                                ZTest LEqual
                                                                                ZWrite On
                                                                                ColorMask 0

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore
                                                                                #pragma multi_compile_instancing
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                // PassKeywords: <None>
                                                                                // GraphKeywords: <None>

                                                                                // Defines
                                                                                #define _AlphaClip 1
                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                struct Attributes
                                                                                {
                                                                                    float3 positionOS : POSITION;
                                                                                    float3 normalOS : NORMAL;
                                                                                    float4 tangentOS : TANGENT;
                                                                                    float4 uv0 : TEXCOORD0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                    float4 positionCS : SV_POSITION;
                                                                                    float4 texCoord0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                    float4 uv0;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                    float3 ObjectSpaceNormal;
                                                                                    float3 WorldSpaceNormal;
                                                                                    float3 ObjectSpaceTangent;
                                                                                    float3 WorldSpaceTangent;
                                                                                    float3 ObjectSpaceBiTangent;
                                                                                    float3 WorldSpaceBiTangent;
                                                                                    float3 ObjectSpacePosition;
                                                                                    float3 AbsoluteWorldSpacePosition;
                                                                                    float4 uv0;
                                                                                    float3 TimeParameters;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                    float4 positionCS : SV_POSITION;
                                                                                    float4 interp0 : TEXCOORD0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyzw = input.texCoord0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }
                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.texCoord0 = input.interp0.xyzw;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float4 _MainTex_TexelSize;
                                                                                float4 RimColor;
                                                                                float4 _MaskTex_TexelSize;
                                                                                float4 _NormalMap_TexelSize;
                                                                                float2 Vector2_AB971143;
                                                                                float Vector1_52D24AB4;
                                                                                float Vector1_36BC0FD6;
                                                                                float Vector1_3AEF5FB5;
                                                                                float Vector1_7AA64B76;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    TEXTURE2D(_MainTex);
                                                                                    SAMPLER(sampler_MainTex);
                                                                                    TEXTURE2D(_MaskTex);
                                                                                    SAMPLER(sampler_MaskTex);
                                                                                    TEXTURE2D(_NormalMap);
                                                                                    SAMPLER(sampler_NormalMap);
                                                                                    SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                                                    // Graph Functions

                                                                                    void Unity_Absolute_float(float In, out float Out)
                                                                                    {
                                                                                        Out = abs(In);
                                                                                    }

                                                                                    void Unity_Power_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = pow(A, B);
                                                                                    }

                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                    {
                                                                                        Out = clamp(In, Min, Max);
                                                                                    }

                                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }


                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                    {
                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                        p = p % 289;
                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                        x = (34 * x + 1) * x % 289;
                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                    }

                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                    {
                                                                                        float2 p = UV * Scale;
                                                                                        float2 ip = floor(p);
                                                                                        float2 fp = frac(p);
                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                    }

                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Preview_float(float In, out float Out)
                                                                                    {
                                                                                        Out = In;
                                                                                    }

                                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                    {
                                                                                        RGBA = float4(R, G, B, A);
                                                                                        RGB = float3(R, G, B);
                                                                                        RG = float2(R, G);
                                                                                    }

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                                        float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                                        Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                                        float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                                        float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                                        Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                                        float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                                        Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                                        float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                        float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                        float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                        float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                                        float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                                        float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                                        float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                                        Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                                        float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                                        float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                                        Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                                        float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                                        Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                                        float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                                        float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                                        Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                                        float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                                        Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                                        float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                                        float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                                        Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                                        float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                                        float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                                        Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                                        float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                                        Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                                        float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                                        float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                                        Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                                        float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                                        description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float Alpha;
                                                                                        float AlphaClipThreshold;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                                        float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                                        Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                                        float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                                        Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                                        float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                                        float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                                        float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                                        Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                                        surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                                        surface.AlphaClipThreshold = 0.5;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs

                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                                        output.uv0 = input.uv0;
                                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                                        return output;
                                                                                    }

                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                        output.uv0 = input.texCoord0;
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                        return output;
                                                                                    }


                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                                    ENDHLSL
                                                                                }
                                                                                Pass
                                                                                {
                                                                                    Name "DepthNormals"
                                                                                    Tags
                                                                                    {
                                                                                        "LightMode" = "DepthNormals"
                                                                                    }

                                                                                        // Render State
                                                                                        Cull Off
                                                                                        Blend One Zero
                                                                                        ZTest LEqual
                                                                                        ZWrite On

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        // PassKeywords: <None>
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines
                                                                                        #define _AlphaClip 1
                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        struct Attributes
                                                                                        {
                                                                                            float3 positionOS : POSITION;
                                                                                            float3 normalOS : NORMAL;
                                                                                            float4 tangentOS : TANGENT;
                                                                                            float4 uv0 : TEXCOORD0;
                                                                                            float4 uv1 : TEXCOORD1;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                            float4 positionCS : SV_POSITION;
                                                                                            float3 normalWS;
                                                                                            float4 tangentWS;
                                                                                            float4 texCoord0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                            float3 TangentSpaceNormal;
                                                                                            float4 uv0;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                            float3 ObjectSpaceNormal;
                                                                                            float3 WorldSpaceNormal;
                                                                                            float3 ObjectSpaceTangent;
                                                                                            float3 WorldSpaceTangent;
                                                                                            float3 ObjectSpaceBiTangent;
                                                                                            float3 WorldSpaceBiTangent;
                                                                                            float3 ObjectSpacePosition;
                                                                                            float3 AbsoluteWorldSpacePosition;
                                                                                            float4 uv0;
                                                                                            float3 TimeParameters;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                            float4 positionCS : SV_POSITION;
                                                                                            float3 interp0 : TEXCOORD0;
                                                                                            float4 interp1 : TEXCOORD1;
                                                                                            float4 interp2 : TEXCOORD2;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.normalWS;
                                                                                            output.interp1.xyzw = input.tangentWS;
                                                                                            output.interp2.xyzw = input.texCoord0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }
                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.normalWS = input.interp0.xyz;
                                                                                            output.tangentWS = input.interp1.xyzw;
                                                                                            output.texCoord0 = input.interp2.xyzw;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float4 _MainTex_TexelSize;
                                                                                        float4 RimColor;
                                                                                        float4 _MaskTex_TexelSize;
                                                                                        float4 _NormalMap_TexelSize;
                                                                                        float2 Vector2_AB971143;
                                                                                        float Vector1_52D24AB4;
                                                                                        float Vector1_36BC0FD6;
                                                                                        float Vector1_3AEF5FB5;
                                                                                        float Vector1_7AA64B76;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            TEXTURE2D(_MainTex);
                                                                                            SAMPLER(sampler_MainTex);
                                                                                            TEXTURE2D(_MaskTex);
                                                                                            SAMPLER(sampler_MaskTex);
                                                                                            TEXTURE2D(_NormalMap);
                                                                                            SAMPLER(sampler_NormalMap);
                                                                                            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                                                            // Graph Functions

                                                                                            void Unity_Absolute_float(float In, out float Out)
                                                                                            {
                                                                                                Out = abs(In);
                                                                                            }

                                                                                            void Unity_Power_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = pow(A, B);
                                                                                            }

                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                            {
                                                                                                Out = clamp(In, Min, Max);
                                                                                            }

                                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                            {
                                                                                                Out = UV * Tiling + Offset;
                                                                                            }


                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                            {
                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                p = p % 289;
                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                            }

                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                            {
                                                                                                float2 p = UV * Scale;
                                                                                                float2 ip = floor(p);
                                                                                                float2 fp = frac(p);
                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                            }

                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Preview_float(float In, out float Out)
                                                                                            {
                                                                                                Out = In;
                                                                                            }

                                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                            {
                                                                                                RGBA = float4(R, G, B, A);
                                                                                                RGB = float3(R, G, B);
                                                                                                RG = float2(R, G);
                                                                                            }

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                                                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                                                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                                                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                                                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                                                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                                                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                                                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                                                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                                                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                                                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                                                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                                                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                                                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                                                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                                                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                                                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                                                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                                                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                                                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                                                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                                                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                                                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                                                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                                                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                                                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                                                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                                                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                                                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                                                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                                                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                                                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                                                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                                                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                                                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                                                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                                float3 NormalTS;
                                                                                                float Alpha;
                                                                                                float AlphaClipThreshold;
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                                                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                                                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                                                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                                                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                                                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                                                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                                                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                                                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                                                surface.AlphaClipThreshold = 0.5;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs

                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                                                output.uv0 = input.uv0;
                                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                                return output;
                                                                                            }

                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                output.uv0 = input.texCoord0;
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                return output;
                                                                                            }


                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                            ENDHLSL
                                                                                        }
                                                                                        Pass
                                                                                        {
                                                                                            Name "Meta"
                                                                                            Tags
                                                                                            {
                                                                                                "LightMode" = "Meta"
                                                                                            }

                                                                                                // Render State
                                                                                                Cull Off

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines
                                                                                                #define _AlphaClip 1
                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                struct Attributes
                                                                                                {
                                                                                                    float3 positionOS : POSITION;
                                                                                                    float3 normalOS : NORMAL;
                                                                                                    float4 tangentOS : TANGENT;
                                                                                                    float4 uv0 : TEXCOORD0;
                                                                                                    float4 uv1 : TEXCOORD1;
                                                                                                    float4 uv2 : TEXCOORD2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                    float4 positionCS : SV_POSITION;
                                                                                                    float4 texCoord0;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                    float4 uv0;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                    float3 ObjectSpaceNormal;
                                                                                                    float3 WorldSpaceNormal;
                                                                                                    float3 ObjectSpaceTangent;
                                                                                                    float3 WorldSpaceTangent;
                                                                                                    float3 ObjectSpaceBiTangent;
                                                                                                    float3 WorldSpaceBiTangent;
                                                                                                    float3 ObjectSpacePosition;
                                                                                                    float3 AbsoluteWorldSpacePosition;
                                                                                                    float4 uv0;
                                                                                                    float3 TimeParameters;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                    float4 positionCS : SV_POSITION;
                                                                                                    float4 interp0 : TEXCOORD0;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.interp0.xyzw = input.texCoord0;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }
                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.texCoord0 = input.interp0.xyzw;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float4 _MainTex_TexelSize;
                                                                                                float4 RimColor;
                                                                                                float4 _MaskTex_TexelSize;
                                                                                                float4 _NormalMap_TexelSize;
                                                                                                float2 Vector2_AB971143;
                                                                                                float Vector1_52D24AB4;
                                                                                                float Vector1_36BC0FD6;
                                                                                                float Vector1_3AEF5FB5;
                                                                                                float Vector1_7AA64B76;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    TEXTURE2D(_MainTex);
                                                                                                    SAMPLER(sampler_MainTex);
                                                                                                    TEXTURE2D(_MaskTex);
                                                                                                    SAMPLER(sampler_MaskTex);
                                                                                                    TEXTURE2D(_NormalMap);
                                                                                                    SAMPLER(sampler_NormalMap);
                                                                                                    SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                                                                    // Graph Functions

                                                                                                    void Unity_Absolute_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = abs(In);
                                                                                                    }

                                                                                                    void Unity_Power_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = pow(A, B);
                                                                                                    }

                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                    {
                                                                                                        Out = clamp(In, Min, Max);
                                                                                                    }

                                                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                    {
                                                                                                        Out = UV * Tiling + Offset;
                                                                                                    }


                                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                    {
                                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                        p = p % 289;
                                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                        x = (34 * x + 1) * x % 289;
                                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                    }

                                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                    {
                                                                                                        float2 p = UV * Scale;
                                                                                                        float2 ip = floor(p);
                                                                                                        float2 fp = frac(p);
                                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                    }

                                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Preview_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = In;
                                                                                                    }

                                                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                                    {
                                                                                                        RGBA = float4(R, G, B, A);
                                                                                                        RGB = float3(R, G, B);
                                                                                                        RG = float2(R, G);
                                                                                                    }

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                                                        float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                                                        float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                                                        Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                                                        float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                                                        float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                                                        Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                                                        float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                                                        Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                                                        float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                        float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                        float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                        float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                                                        float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                                                        float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                                                        float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                                                        Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                                                        float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                                                        float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                                                        Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                                                        float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                                                        Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                                                        float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                                                        float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                                                        Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                                                        float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                                                        Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                                                        float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                                                        float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                                                        Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                                                        float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                                                        float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                                                        Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                                                        float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                                                        Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                                                        float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                                                        float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                                                        float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                                                        Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                                                        float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                                                        description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                        float3 BaseColor;
                                                                                                        float3 Emission;
                                                                                                        float Alpha;
                                                                                                        float AlphaClipThreshold;
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                                                        float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                                                        float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                                                        Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                                                        float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                                                        float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                                                        Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                                                        float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                                                        float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                                                        float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                                                        Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                                                        float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                                                        surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                        surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                                                        surface.AlphaClipThreshold = 0.5;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs

                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                                                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                                                        output.uv0 = input.uv0;
                                                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                                                        return output;
                                                                                                    }

                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                                        output.uv0 = input.texCoord0;
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                        return output;
                                                                                                    }


                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                    ENDHLSL
                                                                                                }
                                                                                                Pass
                                                                                                {
                                                                                                        // Name: <None>
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "Universal2D"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Off
                                                                                                        Blend One Zero
                                                                                                        ZTest LEqual
                                                                                                        ZWrite On

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines
                                                                                                        #define _AlphaClip 1
                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                            float3 positionOS : POSITION;
                                                                                                            float3 normalOS : NORMAL;
                                                                                                            float4 tangentOS : TANGENT;
                                                                                                            float4 uv0 : TEXCOORD0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                            float4 positionCS : SV_POSITION;
                                                                                                            float4 texCoord0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                            float4 uv0;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                            float3 ObjectSpaceNormal;
                                                                                                            float3 WorldSpaceNormal;
                                                                                                            float3 ObjectSpaceTangent;
                                                                                                            float3 WorldSpaceTangent;
                                                                                                            float3 ObjectSpaceBiTangent;
                                                                                                            float3 WorldSpaceBiTangent;
                                                                                                            float3 ObjectSpacePosition;
                                                                                                            float3 AbsoluteWorldSpacePosition;
                                                                                                            float4 uv0;
                                                                                                            float3 TimeParameters;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                            float4 positionCS : SV_POSITION;
                                                                                                            float4 interp0 : TEXCOORD0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyzw = input.texCoord0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }
                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.texCoord0 = input.interp0.xyzw;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float4 _MainTex_TexelSize;
                                                                                                        float4 RimColor;
                                                                                                        float4 _MaskTex_TexelSize;
                                                                                                        float4 _NormalMap_TexelSize;
                                                                                                        float2 Vector2_AB971143;
                                                                                                        float Vector1_52D24AB4;
                                                                                                        float Vector1_36BC0FD6;
                                                                                                        float Vector1_3AEF5FB5;
                                                                                                        float Vector1_7AA64B76;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            TEXTURE2D(_MainTex);
                                                                                                            SAMPLER(sampler_MainTex);
                                                                                                            TEXTURE2D(_MaskTex);
                                                                                                            SAMPLER(sampler_MaskTex);
                                                                                                            TEXTURE2D(_NormalMap);
                                                                                                            SAMPLER(sampler_NormalMap);
                                                                                                            SAMPLER(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_Sampler_3_Linear_Repeat);

                                                                                                            // Graph Functions

                                                                                                            void Unity_Absolute_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = abs(In);
                                                                                                            }

                                                                                                            void Unity_Power_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = pow(A, B);
                                                                                                            }

                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                            {
                                                                                                                Out = clamp(In, Min, Max);
                                                                                                            }

                                                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                            {
                                                                                                                Out = UV * Tiling + Offset;
                                                                                                            }


                                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                            {
                                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                p = p % 289;
                                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                            }

                                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                            {
                                                                                                                float2 p = UV * Scale;
                                                                                                                float2 ip = floor(p);
                                                                                                                float2 fp = frac(p);
                                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                            }

                                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Preview_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = In;
                                                                                                            }

                                                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                                            {
                                                                                                                RGBA = float4(R, G, B, A);
                                                                                                                RGB = float3(R, G, B);
                                                                                                                RG = float2(R, G);
                                                                                                            }

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                float4 _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0 = IN.uv0;
                                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_R_1 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[0];
                                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_G_2 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[1];
                                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_B_3 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[2];
                                                                                                                float _Split_93fe061cfdd32c89b35672ab6dd51e46_A_4 = _UV_f84fc13b4736cd8d86c0f43dd3398b1f_Out_0[3];
                                                                                                                float _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1;
                                                                                                                Unity_Absolute_float(_Split_93fe061cfdd32c89b35672ab6dd51e46_G_2, _Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1);
                                                                                                                float _Property_42b4eda7a661758fac4e34911aac8b67_Out_0 = Vector1_7AA64B76;
                                                                                                                float _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2;
                                                                                                                Unity_Power_float(_Absolute_196fe4c35137718f8b844b0f02a831dd_Out_1, _Property_42b4eda7a661758fac4e34911aac8b67_Out_0, _Power_132f0ce0c327128bb4cd686c93d4197a_Out_2);
                                                                                                                float _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3;
                                                                                                                Unity_Clamp_float(_Power_132f0ce0c327128bb4cd686c93d4197a_Out_2, 0, 1, _Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3);
                                                                                                                float _Split_376158db90a1728e895006f299145aa0_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                                float _Split_376158db90a1728e895006f299145aa0_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                                float _Split_376158db90a1728e895006f299145aa0_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                                float _Split_376158db90a1728e895006f299145aa0_A_4 = 0;
                                                                                                                float2 _Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0 = float2(_Split_376158db90a1728e895006f299145aa0_R_1, _Split_376158db90a1728e895006f299145aa0_G_2);
                                                                                                                float _Property_6ad3cbb1947015818147d795e95bbb90_Out_0 = Vector1_3AEF5FB5;
                                                                                                                float _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2;
                                                                                                                Unity_Multiply_float(IN.TimeParameters.x, _Property_6ad3cbb1947015818147d795e95bbb90_Out_0, _Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2);
                                                                                                                float2 _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0 = Vector2_AB971143;
                                                                                                                float2 _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2;
                                                                                                                Unity_Multiply_float((_Multiply_4de7ae50b6a4728ca55df26ea8d305cd_Out_2.xx), _Property_891319dab4b0b48e8cefd71a8ab33944_Out_0, _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2);
                                                                                                                float2 _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3;
                                                                                                                Unity_TilingAndOffset_float(_Vector2_d6b7463ca992408ba118351d6a619eaf_Out_0, float2 (1, 1), _Multiply_ef93c24392b7ce8ab27383b7225ed640_Out_2, _TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3);
                                                                                                                float _Property_376796e282e766849e3e6707ea858261_Out_0 = Vector1_52D24AB4;
                                                                                                                float _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2;
                                                                                                                Unity_GradientNoise_float(_TilingAndOffset_fe4d9de49d94b68db27fbe9d78001db1_Out_3, _Property_376796e282e766849e3e6707ea858261_Out_0, _GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2);
                                                                                                                float _Add_b869f01fd2407a8093630d71cf87297b_Out_2;
                                                                                                                Unity_Add_float(_GradientNoise_556c74b6f5be8282bcd9bd17d50d8d72_Out_2, -0.5, _Add_b869f01fd2407a8093630d71cf87297b_Out_2);
                                                                                                                float _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0 = Vector1_36BC0FD6;
                                                                                                                float _Multiply_0a4f042f024e5b859b76810904df3903_Out_2;
                                                                                                                Unity_Multiply_float(_Add_b869f01fd2407a8093630d71cf87297b_Out_2, _Property_9f4720a90c7ed088b0ff1902a2b67635_Out_0, _Multiply_0a4f042f024e5b859b76810904df3903_Out_2);
                                                                                                                float2 _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0 = Vector2_AB971143;
                                                                                                                float2 _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2;
                                                                                                                Unity_Multiply_float((_Multiply_0a4f042f024e5b859b76810904df3903_Out_2.xx), _Property_e7fe8dec15c1f38d991ba5e45ff537d1_Out_0, _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2);
                                                                                                                float2 _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2;
                                                                                                                Unity_Multiply_float((_Clamp_09339f74b4af1f8b86c7d98587c18503_Out_3.xx), _Multiply_fd17ebc3512f9582befbd63bf8967625_Out_2, _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2);
                                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_R_1 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[0];
                                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_G_2 = _Multiply_e4e381a8f627708f8f917155fb292d58_Out_2[1];
                                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_B_3 = 0;
                                                                                                                float _Split_d193f76eb33d9283b7c9b6703f067529_A_4 = 0;
                                                                                                                float3 _Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0 = float3(_Split_d193f76eb33d9283b7c9b6703f067529_R_1, _Split_d193f76eb33d9283b7c9b6703f067529_G_2, 0);
                                                                                                                float3 _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2;
                                                                                                                Unity_Add_float3(_Vector3_da1dd3d2eeb13e8d9145117d7909642b_Out_0, IN.AbsoluteWorldSpacePosition, _Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2);
                                                                                                                float3 _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1 = TransformWorldToObject(_Add_d3dd81b0e0e34084b0cca03e6e3bfcda_Out_2.xyz);
                                                                                                                description.Position = _Transform_f63ff3d7df890c80acd27fb5eb02beb3_Out_1;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float3 BaseColor;
                                                                                                                float Alpha;
                                                                                                                float AlphaClipThreshold;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                float4 _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_R_4 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.r;
                                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_G_5 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.g;
                                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_B_6 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.b;
                                                                                                                float _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7 = _SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0.a;
                                                                                                                float4 _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2;
                                                                                                                Unity_Add_float4(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_RGBA_0, float4(0, 0, 0, 0), _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2);
                                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_R_1 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[0];
                                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_G_2 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[1];
                                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_B_3 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[2];
                                                                                                                float _Split_c7b02bf4299809828b7233560fa9ee28_A_4 = _Add_e7731c92dbeb358ea79c1461089b6bde_Out_2[3];
                                                                                                                float _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1;
                                                                                                                Unity_Preview_float(_SampleTexture2D_d88c8bec178ba181aab64ad1c909baad_A_7, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1);
                                                                                                                float4 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4;
                                                                                                                float3 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5;
                                                                                                                float2 _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6;
                                                                                                                Unity_Combine_float(_Split_c7b02bf4299809828b7233560fa9ee28_R_1, _Split_c7b02bf4299809828b7233560fa9ee28_G_2, _Split_c7b02bf4299809828b7233560fa9ee28_B_3, _Preview_f5536682e24dcd8ba6510c0407c3cbd5_Out_1, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGB_5, _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RG_6);
                                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_R_1 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[0];
                                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_G_2 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[1];
                                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_B_3 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[2];
                                                                                                                float _Split_ca71c7440f8f328d9981b7406bbf2375_A_4 = _Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4[3];
                                                                                                                surface.BaseColor = (_Combine_9cca62d7dd7aae89bbfdb4bf6fe110aa_RGBA_4.xyz);
                                                                                                                surface.Alpha = _Split_ca71c7440f8f328d9981b7406bbf2375_A_4;
                                                                                                                surface.AlphaClipThreshold = 0.5;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs

                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                                                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                                                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                                                                                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                                                                                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
                                                                                                                output.uv0 = input.uv0;
                                                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                                                return output;
                                                                                                            }

                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                                                output.uv0 = input.texCoord0;
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                return output;
                                                                                                            }


                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                            ENDHLSL
                                                                                                        }
                                                            }
                                                                CustomEditor "ShaderGraph.PBRMasterGUI"
                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}
