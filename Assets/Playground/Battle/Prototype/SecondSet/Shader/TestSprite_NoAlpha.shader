Shader "TestSpriteNoAlpha"
{
    Properties
    {
        [NoScaleOffset] _MainTex("_MainTex", 2D) = "white" {}
        [NoScaleOffset]_EmissionTex("_EmissionTex", 2D) = "white" {}
        _EmissionColor("_EmissionColor", Color) = (0, 0, 0, 0)
        Dissolve_Progress("Dissolve_Progress", Range(0, 1)) = 0
        Dissolve_Color("Dissolve_Color", Color) = (1, 0, 0, 1)
        [ToggleUI]Outline("Outline", Float) = 0
        Outline_Thickness("Outline_Thickness", Range(0, 0.1)) = 0.01
        Outline_Color("Outline_Color", Color) = (1, 1, 1, 1)
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB

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
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
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
            float4 color : COLOR;
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
            float4 color;
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
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float4 interp4 : TEXCOORD4;
            float3 interp5 : TEXCOORD5;
            #if defined(LIGHTMAP_ON)
            float2 interp6 : TEXCOORD6;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp7 : TEXCOORD7;
            #endif
            float4 interp8 : TEXCOORD8;
            float4 interp9 : TEXCOORD9;
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
            output.interp4.xyzw = input.color;
            output.interp5.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz = input.sh;
            #endif
            output.interp8.xyzw = input.fogFactorAndVertexLight;
            output.interp9.xyzw = input.shadowCoord;
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
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            output.shadowCoord = input.interp9.xyzw;
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
        float4 _EmissionTex_TexelSize;
        float4 _EmissionColor;
        float Dissolve_Progress;
        float4 Dissolve_Color;
        float Outline;
        float Outline_Thickness;
        float4 Outline_Color;
        CBUFFER_END

            // Object and Global properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_EmissionTex);
            SAMPLER(sampler_EmissionTex);
            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_Sampler_3_Linear_Repeat);

            // Graph Functions

            void Unity_Comparison_Equal_float(float A, float B, out float Out)
            {
                Out = A == B ? 1 : 0;
            }

            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
            {
                half4 uv0;
            };

            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
            {
                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
            {
                Out = Predicate ? True : False;
            }


            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }


            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
            {
                return (1.0 - t) * a + (t * b);
            }


            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3 - 0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3 - 1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3 - 2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                Out = t;
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }

            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = Predicate ? True : False;
            }

            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
            {
                half4 uv0;
            };

            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
            {
                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                description.Position = IN.ObjectSpacePosition;
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
                float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                float4 _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_R_4 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.r;
                float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_G_5 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.g;
                float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_B_6 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.b;
                float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_A_7 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.a;
                float4 _Property_5c228929dde8348096a6368505cc4057_Out_0 = _EmissionColor;
                float4 _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2;
                Unity_Multiply_float(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0, _Property_5c228929dde8348096a6368505cc4057_Out_0, _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2);
                surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = (_Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2.xyz);
                surface.Metallic = 0;
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                output.ObjectSpaceTangent = input.tangentOS;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
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
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

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
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _AlphaClip 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_COLOR
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_COLOR
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
                    float4 color : COLOR;
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
                    float4 color;
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
                    float4 VertexColor;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float4 interp4 : TEXCOORD4;
                    float3 interp5 : TEXCOORD5;
                    #if defined(LIGHTMAP_ON)
                    float2 interp6 : TEXCOORD6;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp7 : TEXCOORD7;
                    #endif
                    float4 interp8 : TEXCOORD8;
                    float4 interp9 : TEXCOORD9;
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
                    output.interp4.xyzw = input.color;
                    output.interp5.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp6.xy = input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz = input.sh;
                    #endif
                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                    output.interp9.xyzw = input.shadowCoord;
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
                    output.color = input.interp4.xyzw;
                    output.viewDirectionWS = input.interp5.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    output.shadowCoord = input.interp9.xyzw;
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
                float4 _EmissionTex_TexelSize;
                float4 _EmissionColor;
                float Dissolve_Progress;
                float4 Dissolve_Color;
                float Outline;
                float Outline_Thickness;
                float4 Outline_Color;
                CBUFFER_END

                    // Object and Global properties
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);
                    TEXTURE2D(_EmissionTex);
                    SAMPLER(sampler_EmissionTex);
                    SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_Sampler_3_Linear_Repeat);

                    // Graph Functions

                    void Unity_Comparison_Equal_float(float A, float B, out float Out)
                    {
                        Out = A == B ? 1 : 0;
                    }

                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Multiply_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                    {
                        half4 uv0;
                    };

                    void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                    {
                        float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                        float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                        float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                        float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                        float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                        float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                        float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                        float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                        Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                        float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                        Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                        float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                        float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                        float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                        float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                        float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                        float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                        float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                        Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                        float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                        Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                        float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                        Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                        float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                        float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                        Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                        float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                        float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                        Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                        Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                    {
                        Out = Predicate ? True : False;
                    }


                    inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                    {
                        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                    }


                    inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                    {
                        return (1.0 - t) * a + (t * b);
                    }


                    inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                    {
                        float2 i = floor(uv);
                        float2 f = frac(uv);
                        f = f * f * (3.0 - 2.0 * f);

                        uv = abs(frac(uv) - 0.5);
                        float2 c0 = i + float2(0.0, 0.0);
                        float2 c1 = i + float2(1.0, 0.0);
                        float2 c2 = i + float2(0.0, 1.0);
                        float2 c3 = i + float2(1.0, 1.0);
                        float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                        float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                        float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                        float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                        float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                        float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                        float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                        return t;
                    }

                    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float t = 0.0;

                        float freq = pow(2.0, float(0));
                        float amp = pow(0.5, float(3 - 0));
                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                        freq = pow(2.0, float(1));
                        amp = pow(0.5, float(3 - 1));
                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                        freq = pow(2.0, float(2));
                        amp = pow(0.5, float(3 - 2));
                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                        Out = t;
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Step_float(float Edge, float In, out float Out)
                    {
                        Out = step(Edge, In);
                    }

                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                    {
                        Out = Predicate ? True : False;
                    }

                    struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                    {
                        half4 uv0;
                    };

                    void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                    {
                        float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                        float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                        Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                        float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                        float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                        float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                        Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                        float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                        float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                        float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                        Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                        float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                        float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                        float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                        Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                        float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                        Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                        float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                        float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                        Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                        DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                        DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                        description.Position = IN.ObjectSpacePosition;
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
                        float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                        float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                        Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                        float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                        float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                        float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                        float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                        float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                        _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                        float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                        float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                        Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                        float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                        Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                        float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                        float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                        _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                        float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                        float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                        float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                        Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                        float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                        Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                        float4 _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_R_4 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.r;
                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_G_5 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.g;
                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_B_6 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.b;
                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_A_7 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.a;
                        float4 _Property_5c228929dde8348096a6368505cc4057_Out_0 = _EmissionColor;
                        float4 _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2;
                        Unity_Multiply_float(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0, _Property_5c228929dde8348096a6368505cc4057_Out_0, _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2);
                        surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = (_Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2.xyz);
                        surface.Metallic = 0;
                        surface.Smoothness = 0;
                        surface.Occlusion = 1;
                        surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                        output.ObjectSpaceTangent = input.tangentOS;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }

                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.uv0 = input.texCoord0;
                        output.VertexColor = input.color;
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
                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                        #define _SURFACE_TYPE_TRANSPARENT 1
                        #define _AlphaClip 1
                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_COLOR
                        #define VARYINGS_NEED_TEXCOORD0
                        #define VARYINGS_NEED_COLOR
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
                            float4 color : COLOR;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 texCoord0;
                            float4 color;
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
                            float4 VertexColor;
                        };
                        struct VertexDescriptionInputs
                        {
                            float3 ObjectSpaceNormal;
                            float3 ObjectSpaceTangent;
                            float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 interp0 : TEXCOORD0;
                            float4 interp1 : TEXCOORD1;
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
                            output.interp1.xyzw = input.color;
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
                            output.color = input.interp1.xyzw;
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
                        float4 _EmissionTex_TexelSize;
                        float4 _EmissionColor;
                        float Dissolve_Progress;
                        float4 Dissolve_Color;
                        float Outline;
                        float Outline_Thickness;
                        float4 Outline_Color;
                        CBUFFER_END

                            // Object and Global properties
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);
                            TEXTURE2D(_EmissionTex);
                            SAMPLER(sampler_EmissionTex);
                            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                            // Graph Functions

                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Multiply_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                            {
                                Out = clamp(In, Min, Max);
                            }

                            void Unity_Subtract_float(float A, float B, out float Out)
                            {
                                Out = A - B;
                            }

                            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                            {
                                half4 uv0;
                            };

                            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                            {
                                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                            }

                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                            {
                                Out = Predicate ? True : False;
                            }

                            void Unity_Comparison_Equal_float(float A, float B, out float Out)
                            {
                                Out = A == B ? 1 : 0;
                            }


                            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                            {
                                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                            }


                            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                            {
                                return (1.0 - t) * a + (t * b);
                            }


                            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                            {
                                float2 i = floor(uv);
                                float2 f = frac(uv);
                                f = f * f * (3.0 - 2.0 * f);

                                uv = abs(frac(uv) - 0.5);
                                float2 c0 = i + float2(0.0, 0.0);
                                float2 c1 = i + float2(1.0, 0.0);
                                float2 c2 = i + float2(0.0, 1.0);
                                float2 c3 = i + float2(1.0, 1.0);
                                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                return t;
                            }

                            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                            {
                                float t = 0.0;

                                float freq = pow(2.0, float(0));
                                float amp = pow(0.5, float(3 - 0));
                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                freq = pow(2.0, float(1));
                                amp = pow(0.5, float(3 - 1));
                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                freq = pow(2.0, float(2));
                                amp = pow(0.5, float(3 - 2));
                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                Out = t;
                            }

                            void Unity_OneMinus_float(float In, out float Out)
                            {
                                Out = 1 - In;
                            }

                            void Unity_Step_float(float Edge, float In, out float Out)
                            {
                                Out = step(Edge, In);
                            }

                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                            {
                                Out = Predicate ? True : False;
                            }

                            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                            {
                                half4 uv0;
                            };

                            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                            {
                                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                description.Position = IN.ObjectSpacePosition;
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
                                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                output.ObjectSpaceTangent = input.tangentOS;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }

                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                output.uv0 = input.texCoord0;
                                output.VertexColor = input.color;
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
                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                                #define _SURFACE_TYPE_TRANSPARENT 1
                                #define _AlphaClip 1
                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define ATTRIBUTES_NEED_COLOR
                                #define VARYINGS_NEED_TEXCOORD0
                                #define VARYINGS_NEED_COLOR
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
                                    float4 color : COLOR;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                    float4 positionCS : SV_POSITION;
                                    float4 texCoord0;
                                    float4 color;
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
                                    float4 VertexColor;
                                };
                                struct VertexDescriptionInputs
                                {
                                    float3 ObjectSpaceNormal;
                                    float3 ObjectSpaceTangent;
                                    float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                    float4 positionCS : SV_POSITION;
                                    float4 interp0 : TEXCOORD0;
                                    float4 interp1 : TEXCOORD1;
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
                                    output.interp1.xyzw = input.color;
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
                                    output.color = input.interp1.xyzw;
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
                                float4 _EmissionTex_TexelSize;
                                float4 _EmissionColor;
                                float Dissolve_Progress;
                                float4 Dissolve_Color;
                                float Outline;
                                float Outline_Thickness;
                                float4 Outline_Color;
                                CBUFFER_END

                                    // Object and Global properties
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);
                                    TEXTURE2D(_EmissionTex);
                                    SAMPLER(sampler_EmissionTex);
                                    SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                    SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                    SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                    SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                    SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                    SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                    // Graph Functions

                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Multiply_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                    {
                                        Out = clamp(In, Min, Max);
                                    }

                                    void Unity_Subtract_float(float A, float B, out float Out)
                                    {
                                        Out = A - B;
                                    }

                                    struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                    {
                                        half4 uv0;
                                    };

                                    void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                    {
                                        float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                        float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                        float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                        float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                        float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                        float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                        float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                        float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                        Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                        float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                        Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                        float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                        float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                        float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                        float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                        float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                        float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                        float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                        Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                        float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                        Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                        float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                        Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                        float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                        float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                        Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                        float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                        float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                        Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                        Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                    }

                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                    {
                                        Out = Predicate ? True : False;
                                    }

                                    void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                    {
                                        Out = A == B ? 1 : 0;
                                    }


                                    inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                    {
                                        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                    }


                                    inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                    {
                                        return (1.0 - t) * a + (t * b);
                                    }


                                    inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                    {
                                        float2 i = floor(uv);
                                        float2 f = frac(uv);
                                        f = f * f * (3.0 - 2.0 * f);

                                        uv = abs(frac(uv) - 0.5);
                                        float2 c0 = i + float2(0.0, 0.0);
                                        float2 c1 = i + float2(1.0, 0.0);
                                        float2 c2 = i + float2(0.0, 1.0);
                                        float2 c3 = i + float2(1.0, 1.0);
                                        float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                        float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                        float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                        float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                        float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                        float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                        float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                        return t;
                                    }

                                    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                    {
                                        float t = 0.0;

                                        float freq = pow(2.0, float(0));
                                        float amp = pow(0.5, float(3 - 0));
                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                        freq = pow(2.0, float(1));
                                        amp = pow(0.5, float(3 - 1));
                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                        freq = pow(2.0, float(2));
                                        amp = pow(0.5, float(3 - 2));
                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                        Out = t;
                                    }

                                    void Unity_OneMinus_float(float In, out float Out)
                                    {
                                        Out = 1 - In;
                                    }

                                    void Unity_Step_float(float Edge, float In, out float Out)
                                    {
                                        Out = step(Edge, In);
                                    }

                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                    {
                                        Out = Predicate ? True : False;
                                    }

                                    struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                    {
                                        half4 uv0;
                                    };

                                    void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                    {
                                        float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                        float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                        Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                        float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                        float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                        float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                        Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                        float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                        float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                        float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                        Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                        float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                        float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                        float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                        Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                        float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                        Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                        float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                        float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                        Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                        DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                        DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                        description.Position = IN.ObjectSpacePosition;
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
                                        float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                        float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                        float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                        float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                        float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                        _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                        float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                        float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                        Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                        float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                        Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                        float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                        float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                        _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                        float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                        float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                        surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                        output.ObjectSpaceTangent = input.tangentOS;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }

                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                        output.uv0 = input.texCoord0;
                                        output.VertexColor = input.color;
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
                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                        #define _AlphaClip 1
                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_COLOR
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_COLOR
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
                                            float4 color : COLOR;
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
                                            float4 color;
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
                                            float4 VertexColor;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                            float3 ObjectSpaceNormal;
                                            float3 ObjectSpaceTangent;
                                            float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                            float4 positionCS : SV_POSITION;
                                            float3 interp0 : TEXCOORD0;
                                            float4 interp1 : TEXCOORD1;
                                            float4 interp2 : TEXCOORD2;
                                            float4 interp3 : TEXCOORD3;
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
                                            output.interp3.xyzw = input.color;
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
                                            output.color = input.interp3.xyzw;
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
                                        float4 _EmissionTex_TexelSize;
                                        float4 _EmissionColor;
                                        float Dissolve_Progress;
                                        float4 Dissolve_Color;
                                        float Outline;
                                        float Outline_Thickness;
                                        float4 Outline_Color;
                                        CBUFFER_END

                                            // Object and Global properties
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);
                                            TEXTURE2D(_EmissionTex);
                                            SAMPLER(sampler_EmissionTex);
                                            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                            // Graph Functions

                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Multiply_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                            {
                                                Out = clamp(In, Min, Max);
                                            }

                                            void Unity_Subtract_float(float A, float B, out float Out)
                                            {
                                                Out = A - B;
                                            }

                                            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                            {
                                                half4 uv0;
                                            };

                                            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                            {
                                                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                            }

                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                            {
                                                Out = Predicate ? True : False;
                                            }

                                            void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                            {
                                                Out = A == B ? 1 : 0;
                                            }


                                            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                            {
                                                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                            }


                                            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                            {
                                                return (1.0 - t) * a + (t * b);
                                            }


                                            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                            {
                                                float2 i = floor(uv);
                                                float2 f = frac(uv);
                                                f = f * f * (3.0 - 2.0 * f);

                                                uv = abs(frac(uv) - 0.5);
                                                float2 c0 = i + float2(0.0, 0.0);
                                                float2 c1 = i + float2(1.0, 0.0);
                                                float2 c2 = i + float2(0.0, 1.0);
                                                float2 c3 = i + float2(1.0, 1.0);
                                                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                return t;
                                            }

                                            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                            {
                                                float t = 0.0;

                                                float freq = pow(2.0, float(0));
                                                float amp = pow(0.5, float(3 - 0));
                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                freq = pow(2.0, float(1));
                                                amp = pow(0.5, float(3 - 1));
                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                freq = pow(2.0, float(2));
                                                amp = pow(0.5, float(3 - 2));
                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                Out = t;
                                            }

                                            void Unity_OneMinus_float(float In, out float Out)
                                            {
                                                Out = 1 - In;
                                            }

                                            void Unity_Step_float(float Edge, float In, out float Out)
                                            {
                                                Out = step(Edge, In);
                                            }

                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                            {
                                                Out = Predicate ? True : False;
                                            }

                                            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                            {
                                                half4 uv0;
                                            };

                                            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                            {
                                                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                description.Position = IN.ObjectSpacePosition;
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
                                                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                output.ObjectSpaceTangent = input.tangentOS;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }

                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                output.uv0 = input.texCoord0;
                                                output.VertexColor = input.color;
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
                                                #define _SURFACE_TYPE_TRANSPARENT 1
                                                #define _AlphaClip 1
                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define ATTRIBUTES_NEED_COLOR
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_COLOR
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
                                                    float4 color : COLOR;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                    float4 positionCS : SV_POSITION;
                                                    float4 texCoord0;
                                                    float4 color;
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
                                                    float4 VertexColor;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                    float3 ObjectSpaceNormal;
                                                    float3 ObjectSpaceTangent;
                                                    float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                    float4 positionCS : SV_POSITION;
                                                    float4 interp0 : TEXCOORD0;
                                                    float4 interp1 : TEXCOORD1;
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
                                                    output.interp1.xyzw = input.color;
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
                                                    output.color = input.interp1.xyzw;
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
                                                float4 _EmissionTex_TexelSize;
                                                float4 _EmissionColor;
                                                float Dissolve_Progress;
                                                float4 Dissolve_Color;
                                                float Outline;
                                                float Outline_Thickness;
                                                float4 Outline_Color;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    TEXTURE2D(_MainTex);
                                                    SAMPLER(sampler_MainTex);
                                                    TEXTURE2D(_EmissionTex);
                                                    SAMPLER(sampler_EmissionTex);
                                                    SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                    SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                    SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                    SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                    SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                    SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);
                                                    SAMPLER(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_Sampler_3_Linear_Repeat);

                                                    // Graph Functions

                                                    void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                    {
                                                        Out = A == B ? 1 : 0;
                                                    }

                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                    {
                                                        Out = clamp(In, Min, Max);
                                                    }

                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                    {
                                                        half4 uv0;
                                                    };

                                                    void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                    {
                                                        float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                        float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                        float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                        float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                        float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                        float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                        float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                        float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                        Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                        float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                        Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                        float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                        float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                        float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                        float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                        float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                        float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                        float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                        Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                        float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                        Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                        float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                        Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                        float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                        float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                        Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                        float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                        float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                        Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                        Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                    {
                                                        Out = Predicate ? True : False;
                                                    }


                                                    inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                    {
                                                        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                    }


                                                    inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                    {
                                                        return (1.0 - t) * a + (t * b);
                                                    }


                                                    inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                    {
                                                        float2 i = floor(uv);
                                                        float2 f = frac(uv);
                                                        f = f * f * (3.0 - 2.0 * f);

                                                        uv = abs(frac(uv) - 0.5);
                                                        float2 c0 = i + float2(0.0, 0.0);
                                                        float2 c1 = i + float2(1.0, 0.0);
                                                        float2 c2 = i + float2(0.0, 1.0);
                                                        float2 c3 = i + float2(1.0, 1.0);
                                                        float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                        float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                        float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                        float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                        float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                        float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                        float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                        return t;
                                                    }

                                                    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                    {
                                                        float t = 0.0;

                                                        float freq = pow(2.0, float(0));
                                                        float amp = pow(0.5, float(3 - 0));
                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                        freq = pow(2.0, float(1));
                                                        amp = pow(0.5, float(3 - 1));
                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                        freq = pow(2.0, float(2));
                                                        amp = pow(0.5, float(3 - 2));
                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                        Out = t;
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                    {
                                                        Out = step(Edge, In);
                                                    }

                                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                    {
                                                        Out = Predicate ? True : False;
                                                    }

                                                    struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                    {
                                                        half4 uv0;
                                                    };

                                                    void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                    {
                                                        float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                        float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                        Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                        float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                        float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                        float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                        Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                        float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                        float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                        float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                        Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                        float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                        float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                        float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                        Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                        float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                        Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                        float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                        float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                        Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                        DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                        DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                        description.Position = IN.ObjectSpacePosition;
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
                                                        float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                                                        float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                                                        Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                                                        float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                        float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                        float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                        float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                        float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                        _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                        float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                        float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                        Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                        float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                        Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                        float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                        float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                        _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                        float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                        float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                        float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                                                        Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                                                        float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                                                        Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                                                        float4 _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_R_4 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.r;
                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_G_5 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.g;
                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_B_6 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.b;
                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_A_7 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.a;
                                                        float4 _Property_5c228929dde8348096a6368505cc4057_Out_0 = _EmissionColor;
                                                        float4 _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2;
                                                        Unity_Multiply_float(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0, _Property_5c228929dde8348096a6368505cc4057_Out_0, _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2);
                                                        surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                                                        surface.Emission = (_Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2.xyz);
                                                        surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }

                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                        output.uv0 = input.texCoord0;
                                                        output.VertexColor = input.color;
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
                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                        ZTest LEqual
                                                        ZWrite Off

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
                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                        #define _AlphaClip 1
                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define ATTRIBUTES_NEED_COLOR
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_COLOR
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
                                                            float4 color : COLOR;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                            float4 positionCS : SV_POSITION;
                                                            float4 texCoord0;
                                                            float4 color;
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
                                                            float4 VertexColor;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                            float3 ObjectSpaceNormal;
                                                            float3 ObjectSpaceTangent;
                                                            float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                            float4 positionCS : SV_POSITION;
                                                            float4 interp0 : TEXCOORD0;
                                                            float4 interp1 : TEXCOORD1;
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
                                                            output.interp1.xyzw = input.color;
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
                                                            output.color = input.interp1.xyzw;
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
                                                        float4 _EmissionTex_TexelSize;
                                                        float4 _EmissionColor;
                                                        float Dissolve_Progress;
                                                        float4 Dissolve_Color;
                                                        float Outline;
                                                        float Outline_Thickness;
                                                        float4 Outline_Color;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            TEXTURE2D(_MainTex);
                                                            SAMPLER(sampler_MainTex);
                                                            TEXTURE2D(_EmissionTex);
                                                            SAMPLER(sampler_EmissionTex);
                                                            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                                            // Graph Functions

                                                            void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                            {
                                                                Out = A == B ? 1 : 0;
                                                            }

                                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                            {
                                                                Out = clamp(In, Min, Max);
                                                            }

                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                            {
                                                                half4 uv0;
                                                            };

                                                            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                            {
                                                                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                            }

                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                            {
                                                                Out = Predicate ? True : False;
                                                            }


                                                            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                            {
                                                                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                            }


                                                            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                            {
                                                                return (1.0 - t) * a + (t * b);
                                                            }


                                                            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                            {
                                                                float2 i = floor(uv);
                                                                float2 f = frac(uv);
                                                                f = f * f * (3.0 - 2.0 * f);

                                                                uv = abs(frac(uv) - 0.5);
                                                                float2 c0 = i + float2(0.0, 0.0);
                                                                float2 c1 = i + float2(1.0, 0.0);
                                                                float2 c2 = i + float2(0.0, 1.0);
                                                                float2 c3 = i + float2(1.0, 1.0);
                                                                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                return t;
                                                            }

                                                            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                            {
                                                                float t = 0.0;

                                                                float freq = pow(2.0, float(0));
                                                                float amp = pow(0.5, float(3 - 0));
                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                freq = pow(2.0, float(1));
                                                                amp = pow(0.5, float(3 - 1));
                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                freq = pow(2.0, float(2));
                                                                amp = pow(0.5, float(3 - 2));
                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                Out = t;
                                                            }

                                                            void Unity_OneMinus_float(float In, out float Out)
                                                            {
                                                                Out = 1 - In;
                                                            }

                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                            {
                                                                Out = step(Edge, In);
                                                            }

                                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                            {
                                                                Out = Predicate ? True : False;
                                                            }

                                                            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                            {
                                                                half4 uv0;
                                                            };

                                                            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                            {
                                                                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                description.Position = IN.ObjectSpacePosition;
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
                                                                float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                                                                float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                                                                Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                                                                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                                                                Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                                                                float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                                                                Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                                                                surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                                                                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }

                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                output.uv0 = input.texCoord0;
                                                                output.VertexColor = input.color;
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
                                                                    "RenderType" = "Transparent"
                                                                    "UniversalMaterialType" = "Lit"
                                                                    "Queue" = "Transparent"
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
                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                ZTest LEqual
                                                                ZWrite Off

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
                                                                #define _SURFACE_TYPE_TRANSPARENT 1
                                                                #define _AlphaClip 1
                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                #define ATTRIBUTES_NEED_COLOR
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                #define VARYINGS_NEED_TANGENT_WS
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_COLOR
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
                                                                    float4 color : COLOR;
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
                                                                    float4 color;
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
                                                                    float4 VertexColor;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                    float3 ObjectSpaceNormal;
                                                                    float3 ObjectSpaceTangent;
                                                                    float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                    float4 positionCS : SV_POSITION;
                                                                    float3 interp0 : TEXCOORD0;
                                                                    float3 interp1 : TEXCOORD1;
                                                                    float4 interp2 : TEXCOORD2;
                                                                    float4 interp3 : TEXCOORD3;
                                                                    float4 interp4 : TEXCOORD4;
                                                                    float3 interp5 : TEXCOORD5;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    float2 interp6 : TEXCOORD6;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    float3 interp7 : TEXCOORD7;
                                                                    #endif
                                                                    float4 interp8 : TEXCOORD8;
                                                                    float4 interp9 : TEXCOORD9;
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
                                                                    output.interp4.xyzw = input.color;
                                                                    output.interp5.xyz = input.viewDirectionWS;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    output.interp6.xy = input.lightmapUV;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    output.interp7.xyz = input.sh;
                                                                    #endif
                                                                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                                                                    output.interp9.xyzw = input.shadowCoord;
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
                                                                    output.color = input.interp4.xyzw;
                                                                    output.viewDirectionWS = input.interp5.xyz;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    output.lightmapUV = input.interp6.xy;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    output.sh = input.interp7.xyz;
                                                                    #endif
                                                                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                                                                    output.shadowCoord = input.interp9.xyzw;
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
                                                                float4 _EmissionTex_TexelSize;
                                                                float4 _EmissionColor;
                                                                float Dissolve_Progress;
                                                                float4 Dissolve_Color;
                                                                float Outline;
                                                                float Outline_Thickness;
                                                                float4 Outline_Color;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    TEXTURE2D(_MainTex);
                                                                    SAMPLER(sampler_MainTex);
                                                                    TEXTURE2D(_EmissionTex);
                                                                    SAMPLER(sampler_EmissionTex);
                                                                    SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                                    SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                                    SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                                    SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                                    SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                                    SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);
                                                                    SAMPLER(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_Sampler_3_Linear_Repeat);

                                                                    // Graph Functions

                                                                    void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A == B ? 1 : 0;
                                                                    }

                                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }

                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                    {
                                                                        Out = clamp(In, Min, Max);
                                                                    }

                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A - B;
                                                                    }

                                                                    struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                                    {
                                                                        half4 uv0;
                                                                    };

                                                                    void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                                    {
                                                                        float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                        float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                        float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                        float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                        float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                        float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                        float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                        float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                        Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                        float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                        Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                        float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                        float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                        float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                        float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                        float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                        float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                        float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                        Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                        float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                        Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                        float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                        Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                        float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                        float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                        Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                        float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                        float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                        Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                        Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                    }

                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                    {
                                                                        Out = Predicate ? True : False;
                                                                    }


                                                                    inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                                    {
                                                                        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                                    }


                                                                    inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                                    {
                                                                        return (1.0 - t) * a + (t * b);
                                                                    }


                                                                    inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                                    {
                                                                        float2 i = floor(uv);
                                                                        float2 f = frac(uv);
                                                                        f = f * f * (3.0 - 2.0 * f);

                                                                        uv = abs(frac(uv) - 0.5);
                                                                        float2 c0 = i + float2(0.0, 0.0);
                                                                        float2 c1 = i + float2(1.0, 0.0);
                                                                        float2 c2 = i + float2(0.0, 1.0);
                                                                        float2 c3 = i + float2(1.0, 1.0);
                                                                        float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                        float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                        float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                        float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                        float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                        float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                        float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                        return t;
                                                                    }

                                                                    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                                    {
                                                                        float t = 0.0;

                                                                        float freq = pow(2.0, float(0));
                                                                        float amp = pow(0.5, float(3 - 0));
                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                        freq = pow(2.0, float(1));
                                                                        amp = pow(0.5, float(3 - 1));
                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                        freq = pow(2.0, float(2));
                                                                        amp = pow(0.5, float(3 - 2));
                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                        Out = t;
                                                                    }

                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                    {
                                                                        Out = 1 - In;
                                                                    }

                                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                                    {
                                                                        Out = step(Edge, In);
                                                                    }

                                                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                    {
                                                                        Out = Predicate ? True : False;
                                                                    }

                                                                    struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                                    {
                                                                        half4 uv0;
                                                                    };

                                                                    void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                                    {
                                                                        float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                        float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                        Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                        float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                        float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                        float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                        Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                        float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                        float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                        float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                        Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                        float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                        float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                        float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                        Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                        float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                        Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                        float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                        float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                        Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                        DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                        DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                        description.Position = IN.ObjectSpacePosition;
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
                                                                        float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                                                                        float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                                                                        Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                                                                        float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                        float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                        float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                        float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                        float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                        _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                        float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                        float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                        Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                        float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                        Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                        float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                        float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                        _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                        float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                        float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                        float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                                                                        Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                                                                        float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                                                                        Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                                                                        float4 _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_R_4 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.r;
                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_G_5 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.g;
                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_B_6 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.b;
                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_A_7 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.a;
                                                                        float4 _Property_5c228929dde8348096a6368505cc4057_Out_0 = _EmissionColor;
                                                                        float4 _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2;
                                                                        Unity_Multiply_float(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0, _Property_5c228929dde8348096a6368505cc4057_Out_0, _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2);
                                                                        surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                                                                        surface.NormalTS = IN.TangentSpaceNormal;
                                                                        surface.Emission = (_Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2.xyz);
                                                                        surface.Metallic = 0;
                                                                        surface.Smoothness = 0;
                                                                        surface.Occlusion = 1;
                                                                        surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }

                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                        output.uv0 = input.texCoord0;
                                                                        output.VertexColor = input.color;
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
                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                        #define _AlphaClip 1
                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_COLOR
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
                                                                            float4 color : COLOR;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                            float4 positionCS : SV_POSITION;
                                                                            float4 texCoord0;
                                                                            float4 color;
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
                                                                            float4 VertexColor;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                            float3 ObjectSpaceNormal;
                                                                            float3 ObjectSpaceTangent;
                                                                            float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                            float4 positionCS : SV_POSITION;
                                                                            float4 interp0 : TEXCOORD0;
                                                                            float4 interp1 : TEXCOORD1;
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
                                                                            output.interp1.xyzw = input.color;
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
                                                                            output.color = input.interp1.xyzw;
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
                                                                        float4 _EmissionTex_TexelSize;
                                                                        float4 _EmissionColor;
                                                                        float Dissolve_Progress;
                                                                        float4 Dissolve_Color;
                                                                        float Outline;
                                                                        float Outline_Thickness;
                                                                        float4 Outline_Color;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            TEXTURE2D(_MainTex);
                                                                            SAMPLER(sampler_MainTex);
                                                                            TEXTURE2D(_EmissionTex);
                                                                            SAMPLER(sampler_EmissionTex);
                                                                            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                                            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                                            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                                            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                                            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                                            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                                                            // Graph Functions

                                                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                            {
                                                                                Out = clamp(In, Min, Max);
                                                                            }

                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                                            {
                                                                                half4 uv0;
                                                                            };

                                                                            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                                            {
                                                                                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                            }

                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                            {
                                                                                Out = Predicate ? True : False;
                                                                            }

                                                                            void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A == B ? 1 : 0;
                                                                            }


                                                                            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                                            {
                                                                                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                                            }


                                                                            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                                            {
                                                                                return (1.0 - t) * a + (t * b);
                                                                            }


                                                                            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                                            {
                                                                                float2 i = floor(uv);
                                                                                float2 f = frac(uv);
                                                                                f = f * f * (3.0 - 2.0 * f);

                                                                                uv = abs(frac(uv) - 0.5);
                                                                                float2 c0 = i + float2(0.0, 0.0);
                                                                                float2 c1 = i + float2(1.0, 0.0);
                                                                                float2 c2 = i + float2(0.0, 1.0);
                                                                                float2 c3 = i + float2(1.0, 1.0);
                                                                                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                                return t;
                                                                            }

                                                                            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                                            {
                                                                                float t = 0.0;

                                                                                float freq = pow(2.0, float(0));
                                                                                float amp = pow(0.5, float(3 - 0));
                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                freq = pow(2.0, float(1));
                                                                                amp = pow(0.5, float(3 - 1));
                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                freq = pow(2.0, float(2));
                                                                                amp = pow(0.5, float(3 - 2));
                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                Out = t;
                                                                            }

                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                                            {
                                                                                Out = step(Edge, In);
                                                                            }

                                                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                            {
                                                                                Out = Predicate ? True : False;
                                                                            }

                                                                            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                                            {
                                                                                half4 uv0;
                                                                            };

                                                                            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                                            {
                                                                                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                                description.Position = IN.ObjectSpacePosition;
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
                                                                                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }

                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                output.uv0 = input.texCoord0;
                                                                                output.VertexColor = input.color;
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
                                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                                                                                #define _SURFACE_TYPE_TRANSPARENT 1
                                                                                #define _AlphaClip 1
                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define ATTRIBUTES_NEED_COLOR
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_COLOR
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
                                                                                    float4 color : COLOR;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                    float4 positionCS : SV_POSITION;
                                                                                    float4 texCoord0;
                                                                                    float4 color;
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
                                                                                    float4 VertexColor;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                    float3 ObjectSpaceNormal;
                                                                                    float3 ObjectSpaceTangent;
                                                                                    float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                    float4 positionCS : SV_POSITION;
                                                                                    float4 interp0 : TEXCOORD0;
                                                                                    float4 interp1 : TEXCOORD1;
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
                                                                                    output.interp1.xyzw = input.color;
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
                                                                                    output.color = input.interp1.xyzw;
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
                                                                                float4 _EmissionTex_TexelSize;
                                                                                float4 _EmissionColor;
                                                                                float Dissolve_Progress;
                                                                                float4 Dissolve_Color;
                                                                                float Outline;
                                                                                float Outline_Thickness;
                                                                                float4 Outline_Color;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    TEXTURE2D(_MainTex);
                                                                                    SAMPLER(sampler_MainTex);
                                                                                    TEXTURE2D(_EmissionTex);
                                                                                    SAMPLER(sampler_EmissionTex);
                                                                                    SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                                                    SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                                                    SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                                                    SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                                                    SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                                                    SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                                                                    // Graph Functions

                                                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }

                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                    {
                                                                                        Out = clamp(In, Min, Max);
                                                                                    }

                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A - B;
                                                                                    }

                                                                                    struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                                                    {
                                                                                        half4 uv0;
                                                                                    };

                                                                                    void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                                                    {
                                                                                        float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                                        float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                                        float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                        float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                                        float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                                        float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                        float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                                        float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                                        Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                                        float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                                        Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                        float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                                        float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                        float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                                        float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                        float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                        float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                                        float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                                        Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                                        float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                                        Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                                        float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                                        Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                                        float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                                        float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                                        Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                                        float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                                        float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                        Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                                        Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                    }

                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                    {
                                                                                        Out = Predicate ? True : False;
                                                                                    }

                                                                                    void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A == B ? 1 : 0;
                                                                                    }


                                                                                    inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                                                    {
                                                                                        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                                                    }


                                                                                    inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                                                    {
                                                                                        return (1.0 - t) * a + (t * b);
                                                                                    }


                                                                                    inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                                                    {
                                                                                        float2 i = floor(uv);
                                                                                        float2 f = frac(uv);
                                                                                        f = f * f * (3.0 - 2.0 * f);

                                                                                        uv = abs(frac(uv) - 0.5);
                                                                                        float2 c0 = i + float2(0.0, 0.0);
                                                                                        float2 c1 = i + float2(1.0, 0.0);
                                                                                        float2 c2 = i + float2(0.0, 1.0);
                                                                                        float2 c3 = i + float2(1.0, 1.0);
                                                                                        float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                                        float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                                        float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                                        float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                                        float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                                        float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                                        float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                                        return t;
                                                                                    }

                                                                                    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                                                    {
                                                                                        float t = 0.0;

                                                                                        float freq = pow(2.0, float(0));
                                                                                        float amp = pow(0.5, float(3 - 0));
                                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                        freq = pow(2.0, float(1));
                                                                                        amp = pow(0.5, float(3 - 1));
                                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                        freq = pow(2.0, float(2));
                                                                                        amp = pow(0.5, float(3 - 2));
                                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                        Out = t;
                                                                                    }

                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                                                    {
                                                                                        Out = step(Edge, In);
                                                                                    }

                                                                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                                    {
                                                                                        Out = Predicate ? True : False;
                                                                                    }

                                                                                    struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                                                    {
                                                                                        half4 uv0;
                                                                                    };

                                                                                    void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                                                    {
                                                                                        float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                                        float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                                        Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                                        float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                                        float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                                        float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                                        Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                                        float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                                        float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                                        float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                                        Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                                        float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                                        float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                                        float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                        Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                                        float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                                        Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                                        float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                                        float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                                        Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                                        DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                        DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                                        description.Position = IN.ObjectSpacePosition;
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
                                                                                        float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                                        float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                                        float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                                        float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                                        float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                                        _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                                        float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                                        float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                                        Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                                        float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                                        Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                                        float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                                        float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                                        _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                                        float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                                        float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                                        surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }

                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                        output.uv0 = input.texCoord0;
                                                                                        output.VertexColor = input.color;
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
                                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                                        #define _AlphaClip 1
                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                        #define VARYINGS_NEED_COLOR
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
                                                                                            float4 color : COLOR;
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
                                                                                            float4 color;
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
                                                                                            float4 VertexColor;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                            float3 ObjectSpaceNormal;
                                                                                            float3 ObjectSpaceTangent;
                                                                                            float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                            float4 positionCS : SV_POSITION;
                                                                                            float3 interp0 : TEXCOORD0;
                                                                                            float4 interp1 : TEXCOORD1;
                                                                                            float4 interp2 : TEXCOORD2;
                                                                                            float4 interp3 : TEXCOORD3;
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
                                                                                            output.interp3.xyzw = input.color;
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
                                                                                            output.color = input.interp3.xyzw;
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
                                                                                        float4 _EmissionTex_TexelSize;
                                                                                        float4 _EmissionColor;
                                                                                        float Dissolve_Progress;
                                                                                        float4 Dissolve_Color;
                                                                                        float Outline;
                                                                                        float Outline_Thickness;
                                                                                        float4 Outline_Color;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            TEXTURE2D(_MainTex);
                                                                                            SAMPLER(sampler_MainTex);
                                                                                            TEXTURE2D(_EmissionTex);
                                                                                            SAMPLER(sampler_EmissionTex);
                                                                                            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                                                            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                                                            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                                                            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                                                            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                                                            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                                                                            // Graph Functions

                                                                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                            {
                                                                                                Out = UV * Tiling + Offset;
                                                                                            }

                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                            {
                                                                                                Out = clamp(In, Min, Max);
                                                                                            }

                                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A - B;
                                                                                            }

                                                                                            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                                                            {
                                                                                                half4 uv0;
                                                                                            };

                                                                                            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                                                            {
                                                                                                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                                                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                                                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                                                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                                                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                                                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                                                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                                                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                                                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                                                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                                                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                                                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                                                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                                                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                                                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                                                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                                                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                                                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                                                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                                                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                                                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                                                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                                                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                            }

                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                            {
                                                                                                Out = Predicate ? True : False;
                                                                                            }

                                                                                            void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A == B ? 1 : 0;
                                                                                            }


                                                                                            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                                                            {
                                                                                                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                                                            }


                                                                                            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                                                            {
                                                                                                return (1.0 - t) * a + (t * b);
                                                                                            }


                                                                                            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                                                            {
                                                                                                float2 i = floor(uv);
                                                                                                float2 f = frac(uv);
                                                                                                f = f * f * (3.0 - 2.0 * f);

                                                                                                uv = abs(frac(uv) - 0.5);
                                                                                                float2 c0 = i + float2(0.0, 0.0);
                                                                                                float2 c1 = i + float2(1.0, 0.0);
                                                                                                float2 c2 = i + float2(0.0, 1.0);
                                                                                                float2 c3 = i + float2(1.0, 1.0);
                                                                                                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                                                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                                                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                                                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                                                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                                                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                                                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                                                return t;
                                                                                            }

                                                                                            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                                                            {
                                                                                                float t = 0.0;

                                                                                                float freq = pow(2.0, float(0));
                                                                                                float amp = pow(0.5, float(3 - 0));
                                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                freq = pow(2.0, float(1));
                                                                                                amp = pow(0.5, float(3 - 1));
                                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                freq = pow(2.0, float(2));
                                                                                                amp = pow(0.5, float(3 - 2));
                                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                Out = t;
                                                                                            }

                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                            {
                                                                                                Out = 1 - In;
                                                                                            }

                                                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                                                            {
                                                                                                Out = step(Edge, In);
                                                                                            }

                                                                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                                            {
                                                                                                Out = Predicate ? True : False;
                                                                                            }

                                                                                            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                                                            {
                                                                                                half4 uv0;
                                                                                            };

                                                                                            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                                                            {
                                                                                                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                                                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                                                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                                                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                                                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                                                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                                                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                                                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                                                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                                                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                                                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                                                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                                                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                                                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                                                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                                                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                                                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                                                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                                                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                                                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                                                description.Position = IN.ObjectSpacePosition;
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
                                                                                                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                                                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                                                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                                                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                                                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                                                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                                                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                                                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                                                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                                                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                                                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                                                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                                                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                                                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                                                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                                                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }

                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                output.uv0 = input.texCoord0;
                                                                                                output.VertexColor = input.color;
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
                                                                                                #define _SURFACE_TYPE_TRANSPARENT 1
                                                                                                #define _AlphaClip 1
                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                #define ATTRIBUTES_NEED_COLOR
                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                #define VARYINGS_NEED_COLOR
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
                                                                                                    float4 color : COLOR;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                    float4 positionCS : SV_POSITION;
                                                                                                    float4 texCoord0;
                                                                                                    float4 color;
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
                                                                                                    float4 VertexColor;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                    float3 ObjectSpaceNormal;
                                                                                                    float3 ObjectSpaceTangent;
                                                                                                    float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                    float4 positionCS : SV_POSITION;
                                                                                                    float4 interp0 : TEXCOORD0;
                                                                                                    float4 interp1 : TEXCOORD1;
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
                                                                                                    output.interp1.xyzw = input.color;
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
                                                                                                    output.color = input.interp1.xyzw;
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
                                                                                                float4 _EmissionTex_TexelSize;
                                                                                                float4 _EmissionColor;
                                                                                                float Dissolve_Progress;
                                                                                                float4 Dissolve_Color;
                                                                                                float Outline;
                                                                                                float Outline_Thickness;
                                                                                                float4 Outline_Color;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    TEXTURE2D(_MainTex);
                                                                                                    SAMPLER(sampler_MainTex);
                                                                                                    TEXTURE2D(_EmissionTex);
                                                                                                    SAMPLER(sampler_EmissionTex);
                                                                                                    SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                                                                    SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                                                                    SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                                                                    SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                                                                    SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                                                                    SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);
                                                                                                    SAMPLER(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_Sampler_3_Linear_Repeat);

                                                                                                    // Graph Functions

                                                                                                    void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A == B ? 1 : 0;
                                                                                                    }

                                                                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                    {
                                                                                                        Out = UV * Tiling + Offset;
                                                                                                    }

                                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                    {
                                                                                                        Out = clamp(In, Min, Max);
                                                                                                    }

                                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A - B;
                                                                                                    }

                                                                                                    struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                                                                    {
                                                                                                        half4 uv0;
                                                                                                    };

                                                                                                    void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                                                                    {
                                                                                                        float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                                                        float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                                                        float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                                        float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                                                        float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                                                        float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                                                        float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                                        float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                                                        float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                                                        float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                                                        Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                                                        float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                                                        Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                                        float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                                                        float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                                        float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                                                        float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                                                        float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                                        float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                                        float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                                                        float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                                                        float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                                                        Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                                                        float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                                                        Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                                                        float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                                                        Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                                                        float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                                                        float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                                                        float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                                                        Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                                                        float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                                                        float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                                        Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                                                        Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                                    }

                                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                    {
                                                                                                        Out = Predicate ? True : False;
                                                                                                    }


                                                                                                    inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                                                                    {
                                                                                                        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                                                                    }


                                                                                                    inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                                                                    {
                                                                                                        return (1.0 - t) * a + (t * b);
                                                                                                    }


                                                                                                    inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                                                                    {
                                                                                                        float2 i = floor(uv);
                                                                                                        float2 f = frac(uv);
                                                                                                        f = f * f * (3.0 - 2.0 * f);

                                                                                                        uv = abs(frac(uv) - 0.5);
                                                                                                        float2 c0 = i + float2(0.0, 0.0);
                                                                                                        float2 c1 = i + float2(1.0, 0.0);
                                                                                                        float2 c2 = i + float2(0.0, 1.0);
                                                                                                        float2 c3 = i + float2(1.0, 1.0);
                                                                                                        float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                                                        float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                                                        float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                                                        float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                                                        float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                                                        float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                                                        float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                                                        return t;
                                                                                                    }

                                                                                                    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                                                                    {
                                                                                                        float t = 0.0;

                                                                                                        float freq = pow(2.0, float(0));
                                                                                                        float amp = pow(0.5, float(3 - 0));
                                                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                        freq = pow(2.0, float(1));
                                                                                                        amp = pow(0.5, float(3 - 1));
                                                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                        freq = pow(2.0, float(2));
                                                                                                        amp = pow(0.5, float(3 - 2));
                                                                                                        t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                        Out = t;
                                                                                                    }

                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = 1 - In;
                                                                                                    }

                                                                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                                                                    {
                                                                                                        Out = step(Edge, In);
                                                                                                    }

                                                                                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                                                    {
                                                                                                        Out = Predicate ? True : False;
                                                                                                    }

                                                                                                    struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                                                                    {
                                                                                                        half4 uv0;
                                                                                                    };

                                                                                                    void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                                                                    {
                                                                                                        float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                                                        float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                                                        Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                                                        float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                                                        float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                                                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                                                        float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                                                        Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                                                        float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                                                        float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                                                        float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                                                        Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                                                        float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                                                        Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                                                        float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                                                        Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                                                        float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                                        Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                                                        float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                                                        Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                                                        float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                                                        float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                                                        Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                                                        DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                                        DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                                                        description.Position = IN.ObjectSpacePosition;
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
                                                                                                        float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                                                                                                        float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                                                                                                        Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                                                                                                        float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                                                        float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                                                        float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                                                        float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                                                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                                                        float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                                                        float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                                                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                                                        _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                                                        float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                                                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                                                        float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                                                        Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                                                        float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                                                        Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                                                        float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                                                        float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                                                        float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                                                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                                                        _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                                                        float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                                                        float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                                                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                                                        float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                                                                                                        Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                                                                                                        float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                                                                                                        Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                                                                                                        float4 _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                                                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_R_4 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.r;
                                                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_G_5 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.g;
                                                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_B_6 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.b;
                                                                                                        float _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_A_7 = _SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0.a;
                                                                                                        float4 _Property_5c228929dde8348096a6368505cc4057_Out_0 = _EmissionColor;
                                                                                                        float4 _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2;
                                                                                                        Unity_Multiply_float(_SampleTexture2D_73442fb52adb0f88961d9ba42619f026_RGBA_0, _Property_5c228929dde8348096a6368505cc4057_Out_0, _Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2);
                                                                                                        surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                                                                                                        surface.Emission = (_Multiply_69e2f90067a10e8cbd40fe33c93690b0_Out_2.xyz);
                                                                                                        surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                                                        output.ObjectSpaceTangent = input.tangentOS;
                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                        return output;
                                                                                                    }

                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                                        output.uv0 = input.texCoord0;
                                                                                                        output.VertexColor = input.color;
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
                                                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                                        ZTest LEqual
                                                                                                        ZWrite Off

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
                                                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                                                        #define _AlphaClip 1
                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                        #define VARYINGS_NEED_COLOR
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
                                                                                                            float4 color : COLOR;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                            float4 positionCS : SV_POSITION;
                                                                                                            float4 texCoord0;
                                                                                                            float4 color;
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
                                                                                                            float4 VertexColor;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                            float3 ObjectSpaceNormal;
                                                                                                            float3 ObjectSpaceTangent;
                                                                                                            float3 ObjectSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                            float4 positionCS : SV_POSITION;
                                                                                                            float4 interp0 : TEXCOORD0;
                                                                                                            float4 interp1 : TEXCOORD1;
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
                                                                                                            output.interp1.xyzw = input.color;
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
                                                                                                            output.color = input.interp1.xyzw;
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
                                                                                                        float4 _EmissionTex_TexelSize;
                                                                                                        float4 _EmissionColor;
                                                                                                        float Dissolve_Progress;
                                                                                                        float4 Dissolve_Color;
                                                                                                        float Outline;
                                                                                                        float Outline_Thickness;
                                                                                                        float4 Outline_Color;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            TEXTURE2D(_MainTex);
                                                                                                            SAMPLER(sampler_MainTex);
                                                                                                            TEXTURE2D(_EmissionTex);
                                                                                                            SAMPLER(sampler_EmissionTex);
                                                                                                            SAMPLER(_SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_Sampler_3_Linear_Repeat);
                                                                                                            SAMPLER(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_Sampler_3_Linear_Repeat);
                                                                                                            SAMPLER(_SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_Sampler_3_Linear_Repeat);
                                                                                                            SAMPLER(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_Sampler_3_Linear_Repeat);
                                                                                                            SAMPLER(_SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_Sampler_3_Linear_Repeat);
                                                                                                            SAMPLER(_SampleTexture2D_f25f75903e494180b5982cf65989b9c7_Sampler_3_Linear_Repeat);

                                                                                                            // Graph Functions

                                                                                                            void Unity_Comparison_Equal_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A == B ? 1 : 0;
                                                                                                            }

                                                                                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                            {
                                                                                                                Out = UV * Tiling + Offset;
                                                                                                            }

                                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                            {
                                                                                                                Out = clamp(In, Min, Max);
                                                                                                            }

                                                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A - B;
                                                                                                            }

                                                                                                            struct Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f
                                                                                                            {
                                                                                                                half4 uv0;
                                                                                                            };

                                                                                                            void SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_PARAM(Texture2D_C0198DFC, samplerTexture2D_C0198DFC), float4 Texture2D_C0198DFC_TexelSize, float Vector1_DE900D83, float4 Color_653B35F9, Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f IN, out float4 Color_0)
                                                                                                            {
                                                                                                                float _Property_90ef32564afbe380ac1a3b3315eac854_Out_0 = Vector1_DE900D83;
                                                                                                                float2 _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0 = float2(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, 0);
                                                                                                                float2 _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3;
                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_8c528d3a7e153d82a4ea546e3f8c3857_Out_0, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                                                float4 _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_b38a470b780c7b828a3d4176f81e61ec_Out_3);
                                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_R_4 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.r;
                                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_G_5 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.g;
                                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_B_6 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.b;
                                                                                                                float _SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7 = _SampleTexture2D_bce4054612eedc8d88fc868df7184891_RGBA_0.a;
                                                                                                                float2 _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0 = float2(0, _Property_90ef32564afbe380ac1a3b3315eac854_Out_0);
                                                                                                                float2 _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3;
                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_fe168be50c5b6685ad91e974af8df659_Out_0, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                                                float4 _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_fc0a76904316918980beb656e47b09da_Out_3);
                                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_R_4 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.r;
                                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_G_5 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.g;
                                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_B_6 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.b;
                                                                                                                float _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7 = _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_RGBA_0.a;
                                                                                                                float _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2;
                                                                                                                Unity_Add_float(_SampleTexture2D_bce4054612eedc8d88fc868df7184891_A_7, _SampleTexture2D_0dac62d125df91899d4a3c080d9502b6_A_7, _Add_07ff3fb49916ed86b0505d3d206848f9_Out_2);
                                                                                                                float _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2;
                                                                                                                Unity_Multiply_float(_Property_90ef32564afbe380ac1a3b3315eac854_Out_0, -1, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                                                float2 _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0 = float2(_Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2, 0);
                                                                                                                float2 _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3;
                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_2e4a97afc8b61d859ca11a0067ecca78_Out_0, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                                                float4 _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_ed5935c7d94e3286acdabf4083ecaf6d_Out_3);
                                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_R_4 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.r;
                                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_G_5 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.g;
                                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_B_6 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.b;
                                                                                                                float _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7 = _SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_RGBA_0.a;
                                                                                                                float2 _Vector2_573a85cc6042868e907def074303f6a1_Out_0 = float2(0, _Multiply_ce7c4a309df3a08ead14d2cd9bbede82_Out_2);
                                                                                                                float2 _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3;
                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_573a85cc6042868e907def074303f6a1_Out_0, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                                                float4 _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_a4894b43808c1c8a82445c78d99d4fea_Out_3);
                                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_R_4 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.r;
                                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_G_5 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.g;
                                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_B_6 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.b;
                                                                                                                float _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7 = _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_RGBA_0.a;
                                                                                                                float _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2;
                                                                                                                Unity_Add_float(_SampleTexture2D_fd5b51b26c41ce88930dca8afc53d5aa_A_7, _SampleTexture2D_6123bc6eb5fa068a9af7970930d17207_A_7, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2);
                                                                                                                float _Add_d483515c09c2e4849da7d7d6045f889c_Out_2;
                                                                                                                Unity_Add_float(_Add_07ff3fb49916ed86b0505d3d206848f9_Out_2, _Add_3d546dff4dad7a8faa06ee9c77efdcbe_Out_2, _Add_d483515c09c2e4849da7d7d6045f889c_Out_2);
                                                                                                                float _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3;
                                                                                                                Unity_Clamp_float(_Add_d483515c09c2e4849da7d7d6045f889c_Out_2, 0, 1, _Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3);
                                                                                                                float4 _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_R_4 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.r;
                                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_G_5 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.g;
                                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_B_6 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.b;
                                                                                                                float _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7 = _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_RGBA_0.a;
                                                                                                                float _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2;
                                                                                                                Unity_Subtract_float(_Clamp_e7b73744f9658b8991c554b41dc1cfe2_Out_3, _SampleTexture2D_f25f75903e494180b5982cf65989b9c7_A_7, _Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2);
                                                                                                                float4 _Property_a811223bbfeb40858d240911ef1eab2b_Out_0 = Color_653B35F9;
                                                                                                                float4 _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                                                Unity_Multiply_float((_Subtract_3455bfd36cac1486a3312ea80df093f1_Out_2.xxxx), _Property_a811223bbfeb40858d240911ef1eab2b_Out_0, _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2);
                                                                                                                Color_0 = _Multiply_55454ad55a2b9984b6ed2f1c6e8afbe4_Out_2;
                                                                                                            }

                                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                            {
                                                                                                                Out = Predicate ? True : False;
                                                                                                            }


                                                                                                            inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
                                                                                                            {
                                                                                                                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                                                                                                            }


                                                                                                            inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
                                                                                                            {
                                                                                                                return (1.0 - t) * a + (t * b);
                                                                                                            }


                                                                                                            inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
                                                                                                            {
                                                                                                                float2 i = floor(uv);
                                                                                                                float2 f = frac(uv);
                                                                                                                f = f * f * (3.0 - 2.0 * f);

                                                                                                                uv = abs(frac(uv) - 0.5);
                                                                                                                float2 c0 = i + float2(0.0, 0.0);
                                                                                                                float2 c1 = i + float2(1.0, 0.0);
                                                                                                                float2 c2 = i + float2(0.0, 1.0);
                                                                                                                float2 c3 = i + float2(1.0, 1.0);
                                                                                                                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                                                                                                                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                                                                                                                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                                                                                                                float r3 = Unity_SimpleNoise_RandomValue_float(c3);

                                                                                                                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                                                                                                                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                                                                                                                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                                                                                                                return t;
                                                                                                            }

                                                                                                            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
                                                                                                            {
                                                                                                                float t = 0.0;

                                                                                                                float freq = pow(2.0, float(0));
                                                                                                                float amp = pow(0.5, float(3 - 0));
                                                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                                freq = pow(2.0, float(1));
                                                                                                                amp = pow(0.5, float(3 - 1));
                                                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                                freq = pow(2.0, float(2));
                                                                                                                amp = pow(0.5, float(3 - 2));
                                                                                                                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                                                                                                                Out = t;
                                                                                                            }

                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = 1 - In;
                                                                                                            }

                                                                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                                                                            {
                                                                                                                Out = step(Edge, In);
                                                                                                            }

                                                                                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                                                            {
                                                                                                                Out = Predicate ? True : False;
                                                                                                            }

                                                                                                            struct Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f
                                                                                                            {
                                                                                                                half4 uv0;
                                                                                                            };

                                                                                                            void SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(float Vector1_EF774600, float Vector1_C843BF23, float4 Vector4_4DBD63, Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f IN, out float DissolvedAlpha_1, out float4 DissolvedColor_2)
                                                                                                            {
                                                                                                                float _Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0 = Vector1_C843BF23;
                                                                                                                float _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2;
                                                                                                                Unity_Comparison_Equal_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, 1, _Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2);
                                                                                                                float _Property_9e215833532d508591dab26d7f2c6197_Out_0 = Vector1_EF774600;
                                                                                                                float _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2;
                                                                                                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2);
                                                                                                                float _OneMinus_063a3413d281a684947c0662af65506f_Out_1;
                                                                                                                Unity_OneMinus_float(_Property_bcc0c6ec3533b781b0017665bfab45d0_Out_0, _OneMinus_063a3413d281a684947c0662af65506f_Out_1);
                                                                                                                float _Step_49ea235b18734c86939f2f808250c9bb_Out_2;
                                                                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _OneMinus_063a3413d281a684947c0662af65506f_Out_1, _Step_49ea235b18734c86939f2f808250c9bb_Out_2);
                                                                                                                float _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2;
                                                                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_49ea235b18734c86939f2f808250c9bb_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2);
                                                                                                                float _Add_900c414a66e4bf8893c32a3969384de7_Out_2;
                                                                                                                Unity_Add_float(_OneMinus_063a3413d281a684947c0662af65506f_Out_1, 0.1, _Add_900c414a66e4bf8893c32a3969384de7_Out_2);
                                                                                                                float _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2;
                                                                                                                Unity_Step_float(_SimpleNoise_6b72c1f2f9afb28c93401dfe1f4b3a69_Out_2, _Add_900c414a66e4bf8893c32a3969384de7_Out_2, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2);
                                                                                                                float _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2;
                                                                                                                Unity_Multiply_float(_Property_9e215833532d508591dab26d7f2c6197_Out_0, _Step_c3bb9975a3863c8fb5ca3c2c8dde6ce0_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2);
                                                                                                                float _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                                                Unity_Branch_float(_Comparison_bdcc52e5b1736d8488261dd79ab35ed0_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3);
                                                                                                                float _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2;
                                                                                                                Unity_Subtract_float(_Multiply_2bba022ec4c49d8da988ae935b37b532_Out_2, _Multiply_5e24c9e4df5f6689b593569dc9d96770_Out_2, _Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2);
                                                                                                                float4 _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0 = Vector4_4DBD63;
                                                                                                                float4 _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
                                                                                                                Unity_Multiply_float((_Subtract_3d64a9ec63df748a93109bc7f2ba848e_Out_2.xxxx), _Property_56ce9da27d6e0282bb3f7977e2d8d16c_Out_0, _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2);
                                                                                                                DissolvedAlpha_1 = _Branch_b54cb8baebbd9483ab02ddcb9faa77ec_Out_3;
                                                                                                                DissolvedColor_2 = _Multiply_bed8b717c1a2b18c9a64dc15889890e3_Out_2;
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
                                                                                                                description.Position = IN.ObjectSpacePosition;
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
                                                                                                                float _Property_9e32af99daff888bad09be061ff8148b_Out_0 = Dissolve_Progress;
                                                                                                                float _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2;
                                                                                                                Unity_Comparison_Equal_float(_Property_9e32af99daff888bad09be061ff8148b_Out_0, 0, _Comparison_7c9102603be9958aa48ea62f5813e781_Out_2);
                                                                                                                float _Property_3ea4aaa550bf028aba095f76335f3df9_Out_0 = Outline;
                                                                                                                float4 _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_R_4 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.r;
                                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_G_5 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.g;
                                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_B_6 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.b;
                                                                                                                float _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_A_7 = _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0.a;
                                                                                                                float4 _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2;
                                                                                                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_a5ec0cbe43b3918a99534795d8768ece_RGBA_0, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2);
                                                                                                                float _Property_08885129b465b886bb2da3c6ff8a2231_Out_0 = Outline_Thickness;
                                                                                                                float4 _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0 = Outline_Color;
                                                                                                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_32b26d644a2b3b87babcb7ffebeab832;
                                                                                                                _OutlineSub_32b26d644a2b3b87babcb7ffebeab832.uv0 = IN.uv0;
                                                                                                                float4 _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0;
                                                                                                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_08885129b465b886bb2da3c6ff8a2231_Out_0, _Property_cd591df59b05428eb5dcd9cb65e98d40_Out_0, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0);
                                                                                                                float4 _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2;
                                                                                                                Unity_Add_float4(_Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _OutlineSub_32b26d644a2b3b87babcb7ffebeab832_Color_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2);
                                                                                                                float4 _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3;
                                                                                                                Unity_Branch_float4(_Property_3ea4aaa550bf028aba095f76335f3df9_Out_0, _Add_fb06c11802f7bd8cbe696be6d85b88c4_Out_2, _Multiply_db11f6f1f102c384a2fed767aceb6a81_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3);
                                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_R_1 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[0];
                                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_G_2 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[1];
                                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_B_3 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[2];
                                                                                                                float _Split_0a5519a3d78ece86b190f7552e26e0ea_A_4 = _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3[3];
                                                                                                                float _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0 = Dissolve_Progress;
                                                                                                                float4 _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0 = Dissolve_Color;
                                                                                                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb;
                                                                                                                _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb.uv0 = IN.uv0;
                                                                                                                float _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
                                                                                                                float4 _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2;
                                                                                                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_0a5519a3d78ece86b190f7552e26e0ea_A_4, _Property_323fa113f7785480b8dd6cabe41f8b1b_Out_0, _Property_6bbf0038441b8f88b57d8543e89915eb_Out_0, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2);
                                                                                                                float4 _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2;
                                                                                                                Unity_Add_float4(_Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedColor_2, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2);
                                                                                                                float4 _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3;
                                                                                                                Unity_Branch_float4(_Comparison_7c9102603be9958aa48ea62f5813e781_Out_2, _Branch_37f08a461a960e8094d3f34f3fa26c37_Out_3, _Add_a6aa70761e39c189b6d2b9c05ee915d7_Out_2, _Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3);
                                                                                                                surface.BaseColor = (_Branch_6f2f7c1ec5f86c89b1fcf277be29efb2_Out_3.xyz);
                                                                                                                surface.Alpha = _DissolveSub_4e0ac2cd5164e48087ecc65048495cbb_DissolvedAlpha_1;
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
                                                                                                                output.ObjectSpaceTangent = input.tangentOS;
                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                return output;
                                                                                                            }

                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                output.VertexColor = input.color;
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
