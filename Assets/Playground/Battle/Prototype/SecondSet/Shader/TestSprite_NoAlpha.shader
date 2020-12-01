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
    }
        SubShader
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Transparent"
                "Queue" = "Transparent+0"
            }

            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }

            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite Off
            ColorMask RGB


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
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
            #define SHADERPASS_FORWARD

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _EmissionColor;
            float Dissolve_Progress;
            float4 Dissolve_Color;
            float Outline;
            float Outline_Thickness;
            float4 Outline_Color;
            CBUFFER_END
            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
            TEXTURE2D(_EmissionTex); SAMPLER(sampler_EmissionTex); float4 _EmissionTex_TexelSize;
            SAMPLER(_SampleTexture2D_8051FBC3_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_FA5A1291_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_89E84CC7_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_E095F33D_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_9BDB1C01_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_72537D31_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_55D129C0_Sampler_3_Linear_Repeat);

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
                float _Property_99BA41DA_Out_0 = Vector1_DE900D83;
                float2 _Vector2_FAFB8C83_Out_0 = float2(_Property_99BA41DA_Out_0, 0);
                float2 _TilingAndOffset_1A54AB_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_FAFB8C83_Out_0, _TilingAndOffset_1A54AB_Out_3);
                float4 _SampleTexture2D_FA5A1291_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_1A54AB_Out_3);
                float _SampleTexture2D_FA5A1291_R_4 = _SampleTexture2D_FA5A1291_RGBA_0.r;
                float _SampleTexture2D_FA5A1291_G_5 = _SampleTexture2D_FA5A1291_RGBA_0.g;
                float _SampleTexture2D_FA5A1291_B_6 = _SampleTexture2D_FA5A1291_RGBA_0.b;
                float _SampleTexture2D_FA5A1291_A_7 = _SampleTexture2D_FA5A1291_RGBA_0.a;
                float2 _Vector2_D1B88893_Out_0 = float2(0, _Property_99BA41DA_Out_0);
                float2 _TilingAndOffset_43B8A4DE_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_D1B88893_Out_0, _TilingAndOffset_43B8A4DE_Out_3);
                float4 _SampleTexture2D_89E84CC7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_43B8A4DE_Out_3);
                float _SampleTexture2D_89E84CC7_R_4 = _SampleTexture2D_89E84CC7_RGBA_0.r;
                float _SampleTexture2D_89E84CC7_G_5 = _SampleTexture2D_89E84CC7_RGBA_0.g;
                float _SampleTexture2D_89E84CC7_B_6 = _SampleTexture2D_89E84CC7_RGBA_0.b;
                float _SampleTexture2D_89E84CC7_A_7 = _SampleTexture2D_89E84CC7_RGBA_0.a;
                float _Add_2AA44941_Out_2;
                Unity_Add_float(_SampleTexture2D_FA5A1291_A_7, _SampleTexture2D_89E84CC7_A_7, _Add_2AA44941_Out_2);
                float _Multiply_1B9776DE_Out_2;
                Unity_Multiply_float(_Property_99BA41DA_Out_0, -1, _Multiply_1B9776DE_Out_2);
                float2 _Vector2_443E006E_Out_0 = float2(_Multiply_1B9776DE_Out_2, 0);
                float2 _TilingAndOffset_64C6259E_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_443E006E_Out_0, _TilingAndOffset_64C6259E_Out_3);
                float4 _SampleTexture2D_E095F33D_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_64C6259E_Out_3);
                float _SampleTexture2D_E095F33D_R_4 = _SampleTexture2D_E095F33D_RGBA_0.r;
                float _SampleTexture2D_E095F33D_G_5 = _SampleTexture2D_E095F33D_RGBA_0.g;
                float _SampleTexture2D_E095F33D_B_6 = _SampleTexture2D_E095F33D_RGBA_0.b;
                float _SampleTexture2D_E095F33D_A_7 = _SampleTexture2D_E095F33D_RGBA_0.a;
                float2 _Vector2_7443A6E2_Out_0 = float2(0, _Multiply_1B9776DE_Out_2);
                float2 _TilingAndOffset_C4C0A44A_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_7443A6E2_Out_0, _TilingAndOffset_C4C0A44A_Out_3);
                float4 _SampleTexture2D_9BDB1C01_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_C4C0A44A_Out_3);
                float _SampleTexture2D_9BDB1C01_R_4 = _SampleTexture2D_9BDB1C01_RGBA_0.r;
                float _SampleTexture2D_9BDB1C01_G_5 = _SampleTexture2D_9BDB1C01_RGBA_0.g;
                float _SampleTexture2D_9BDB1C01_B_6 = _SampleTexture2D_9BDB1C01_RGBA_0.b;
                float _SampleTexture2D_9BDB1C01_A_7 = _SampleTexture2D_9BDB1C01_RGBA_0.a;
                float _Add_D8C8A234_Out_2;
                Unity_Add_float(_SampleTexture2D_E095F33D_A_7, _SampleTexture2D_9BDB1C01_A_7, _Add_D8C8A234_Out_2);
                float _Add_BC4F6FAC_Out_2;
                Unity_Add_float(_Add_2AA44941_Out_2, _Add_D8C8A234_Out_2, _Add_BC4F6FAC_Out_2);
                float _Clamp_BAC055DD_Out_3;
                Unity_Clamp_float(_Add_BC4F6FAC_Out_2, 0, 1, _Clamp_BAC055DD_Out_3);
                float4 _SampleTexture2D_72537D31_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                float _SampleTexture2D_72537D31_R_4 = _SampleTexture2D_72537D31_RGBA_0.r;
                float _SampleTexture2D_72537D31_G_5 = _SampleTexture2D_72537D31_RGBA_0.g;
                float _SampleTexture2D_72537D31_B_6 = _SampleTexture2D_72537D31_RGBA_0.b;
                float _SampleTexture2D_72537D31_A_7 = _SampleTexture2D_72537D31_RGBA_0.a;
                float _Subtract_8EB4E9AA_Out_2;
                Unity_Subtract_float(_Clamp_BAC055DD_Out_3, _SampleTexture2D_72537D31_A_7, _Subtract_8EB4E9AA_Out_2);
                float4 _Property_4D4E88B3_Out_0 = Color_653B35F9;
                float4 _Multiply_B8705920_Out_2;
                Unity_Multiply_float((_Subtract_8EB4E9AA_Out_2.xxxx), _Property_4D4E88B3_Out_0, _Multiply_B8705920_Out_2);
                Color_0 = _Multiply_B8705920_Out_2;
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
                float _Property_41D3B152_Out_0 = Vector1_C843BF23;
                float _Comparison_E8B59246_Out_2;
                Unity_Comparison_Equal_float(_Property_41D3B152_Out_0, 1, _Comparison_E8B59246_Out_2);
                float _Property_40D88250_Out_0 = Vector1_EF774600;
                float _SimpleNoise_5B537726_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_5B537726_Out_2);
                float _OneMinus_1FA41B08_Out_1;
                Unity_OneMinus_float(_Property_41D3B152_Out_0, _OneMinus_1FA41B08_Out_1);
                float _Step_36A488B1_Out_2;
                Unity_Step_float(_SimpleNoise_5B537726_Out_2, _OneMinus_1FA41B08_Out_1, _Step_36A488B1_Out_2);
                float _Multiply_EAFAFAEC_Out_2;
                Unity_Multiply_float(_Property_40D88250_Out_0, _Step_36A488B1_Out_2, _Multiply_EAFAFAEC_Out_2);
                float _Add_3516D411_Out_2;
                Unity_Add_float(_OneMinus_1FA41B08_Out_1, 0.1, _Add_3516D411_Out_2);
                float _Step_9D0829F0_Out_2;
                Unity_Step_float(_SimpleNoise_5B537726_Out_2, _Add_3516D411_Out_2, _Step_9D0829F0_Out_2);
                float _Multiply_E1967D7B_Out_2;
                Unity_Multiply_float(_Property_40D88250_Out_0, _Step_9D0829F0_Out_2, _Multiply_E1967D7B_Out_2);
                float _Branch_92037443_Out_3;
                Unity_Branch_float(_Comparison_E8B59246_Out_2, _Multiply_EAFAFAEC_Out_2, _Multiply_E1967D7B_Out_2, _Branch_92037443_Out_3);
                float _Subtract_52DE93D2_Out_2;
                Unity_Subtract_float(_Multiply_E1967D7B_Out_2, _Multiply_EAFAFAEC_Out_2, _Subtract_52DE93D2_Out_2);
                float4 _Property_A0CC82B_Out_0 = Vector4_4DBD63;
                float4 _Multiply_51618D24_Out_2;
                Unity_Multiply_float((_Subtract_52DE93D2_Out_2.xxxx), _Property_A0CC82B_Out_0, _Multiply_51618D24_Out_2);
                DissolvedAlpha_1 = _Branch_92037443_Out_3;
                DissolvedColor_2 = _Multiply_51618D24_Out_2;
            }

            // Graph Vertex
            // GraphVertex: <None>

            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float4 uv0;
                float4 VertexColor;
            };

            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Normal;
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
                float _Property_6B778FE2_Out_0 = Dissolve_Progress;
                float _Comparison_4EC89164_Out_2;
                Unity_Comparison_Equal_float(_Property_6B778FE2_Out_0, 0, _Comparison_4EC89164_Out_2);
                float _Property_AABC97FA_Out_0 = Outline;
                float4 _SampleTexture2D_8051FBC3_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                float _SampleTexture2D_8051FBC3_R_4 = _SampleTexture2D_8051FBC3_RGBA_0.r;
                float _SampleTexture2D_8051FBC3_G_5 = _SampleTexture2D_8051FBC3_RGBA_0.g;
                float _SampleTexture2D_8051FBC3_B_6 = _SampleTexture2D_8051FBC3_RGBA_0.b;
                float _SampleTexture2D_8051FBC3_A_7 = _SampleTexture2D_8051FBC3_RGBA_0.a;
                float4 _Multiply_B4A66C10_Out_2;
                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_8051FBC3_RGBA_0, _Multiply_B4A66C10_Out_2);
                float _Property_877A111A_Out_0 = Outline_Thickness;
                float4 _Property_2A7725AB_Out_0 = Outline_Color;
                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_F7A72801;
                _OutlineSub_F7A72801.uv0 = IN.uv0;
                float4 _OutlineSub_F7A72801_Color_0;
                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_877A111A_Out_0, _Property_2A7725AB_Out_0, _OutlineSub_F7A72801, _OutlineSub_F7A72801_Color_0);
                float4 _Add_6CCBA0EE_Out_2;
                Unity_Add_float4(_Multiply_B4A66C10_Out_2, _OutlineSub_F7A72801_Color_0, _Add_6CCBA0EE_Out_2);
                float4 _Branch_9DA8DF8_Out_3;
                Unity_Branch_float4(_Property_AABC97FA_Out_0, _Add_6CCBA0EE_Out_2, _Multiply_B4A66C10_Out_2, _Branch_9DA8DF8_Out_3);
                float _Split_3586B177_R_1 = _Branch_9DA8DF8_Out_3[0];
                float _Split_3586B177_G_2 = _Branch_9DA8DF8_Out_3[1];
                float _Split_3586B177_B_3 = _Branch_9DA8DF8_Out_3[2];
                float _Split_3586B177_A_4 = _Branch_9DA8DF8_Out_3[3];
                float _Property_96D859E1_Out_0 = Dissolve_Progress;
                float4 _Property_ECC6743E_Out_0 = Dissolve_Color;
                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_D2F824E7;
                _DissolveSub_D2F824E7.uv0 = IN.uv0;
                float _DissolveSub_D2F824E7_DissolvedAlpha_1;
                float4 _DissolveSub_D2F824E7_DissolvedColor_2;
                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_3586B177_A_4, _Property_96D859E1_Out_0, _Property_ECC6743E_Out_0, _DissolveSub_D2F824E7, _DissolveSub_D2F824E7_DissolvedAlpha_1, _DissolveSub_D2F824E7_DissolvedColor_2);
                float4 _Add_35D8B386_Out_2;
                Unity_Add_float4(_Branch_9DA8DF8_Out_3, _DissolveSub_D2F824E7_DissolvedColor_2, _Add_35D8B386_Out_2);
                float4 _Branch_8686AB9C_Out_3;
                Unity_Branch_float4(_Comparison_4EC89164_Out_2, _Branch_9DA8DF8_Out_3, _Add_35D8B386_Out_2, _Branch_8686AB9C_Out_3);
                float4 _SampleTexture2D_55D129C0_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                float _SampleTexture2D_55D129C0_R_4 = _SampleTexture2D_55D129C0_RGBA_0.r;
                float _SampleTexture2D_55D129C0_G_5 = _SampleTexture2D_55D129C0_RGBA_0.g;
                float _SampleTexture2D_55D129C0_B_6 = _SampleTexture2D_55D129C0_RGBA_0.b;
                float _SampleTexture2D_55D129C0_A_7 = _SampleTexture2D_55D129C0_RGBA_0.a;
                float4 _Property_757F56F2_Out_0 = _EmissionColor;
                float4 _Multiply_7771456A_Out_2;
                Unity_Multiply_float(_SampleTexture2D_55D129C0_RGBA_0, _Property_757F56F2_Out_0, _Multiply_7771456A_Out_2);
                surface.Albedo = (_Branch_8686AB9C_Out_3.xyz);
                surface.Normal = IN.TangentSpaceNormal;
                surface.Emission = (_Multiply_7771456A_Out_2.xyz);
                surface.Metallic = 0;
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = _DissolveSub_D2F824E7_DissolvedAlpha_1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }

            // --------------------------------------------------
            // Structs and Packing

            // Generated Type: Attributes
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

            // Generated Type: Varyings
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
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if defined(LIGHTMAP_ON)
                #endif
                #if !defined(LIGHTMAP_ON)
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
                float4 interp04 : TEXCOORD4;
                float3 interp05 : TEXCOORD5;
                float2 interp06 : TEXCOORD6;
                float3 interp07 : TEXCOORD7;
                float4 interp08 : TEXCOORD8;
                float4 interp09 : TEXCOORD9;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.normalWS;
                output.interp02.xyzw = input.tangentWS;
                output.interp03.xyzw = input.texCoord0;
                output.interp04.xyzw = input.color;
                output.interp05.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp06.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp07.xyz = input.sh;
                #endif
                output.interp08.xyzw = input.fogFactorAndVertexLight;
                output.interp09.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.normalWS = input.interp01.xyz;
                output.tangentWS = input.interp02.xyzw;
                output.texCoord0 = input.interp03.xyzw;
                output.color = input.interp04.xyzw;
                output.viewDirectionWS = input.interp05.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp06.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp07.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp08.xyzw;
                output.shadowCoord = input.interp09.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            // --------------------------------------------------
            // Build Graph Inputs

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
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                Cull Off
                ZTest LEqual
                ZWrite On
                // ColorMask: <None>


                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                // Pragmas
                #pragma prefer_hlslcc gles
                #pragma exclude_renderers d3d11_9x
                #pragma target 2.0
                #pragma multi_compile_instancing

                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>

                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _AlphaClip 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_COLOR
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_COLOR
                #define SHADERPASS_SHADOWCASTER

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _EmissionColor;
                float Dissolve_Progress;
                float4 Dissolve_Color;
                float Outline;
                float Outline_Thickness;
                float4 Outline_Color;
                CBUFFER_END
                TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                TEXTURE2D(_EmissionTex); SAMPLER(sampler_EmissionTex); float4 _EmissionTex_TexelSize;
                SAMPLER(_SampleTexture2D_8051FBC3_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_FA5A1291_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_89E84CC7_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_E095F33D_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_9BDB1C01_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_72537D31_Sampler_3_Linear_Repeat);

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
                    float _Property_99BA41DA_Out_0 = Vector1_DE900D83;
                    float2 _Vector2_FAFB8C83_Out_0 = float2(_Property_99BA41DA_Out_0, 0);
                    float2 _TilingAndOffset_1A54AB_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_FAFB8C83_Out_0, _TilingAndOffset_1A54AB_Out_3);
                    float4 _SampleTexture2D_FA5A1291_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_1A54AB_Out_3);
                    float _SampleTexture2D_FA5A1291_R_4 = _SampleTexture2D_FA5A1291_RGBA_0.r;
                    float _SampleTexture2D_FA5A1291_G_5 = _SampleTexture2D_FA5A1291_RGBA_0.g;
                    float _SampleTexture2D_FA5A1291_B_6 = _SampleTexture2D_FA5A1291_RGBA_0.b;
                    float _SampleTexture2D_FA5A1291_A_7 = _SampleTexture2D_FA5A1291_RGBA_0.a;
                    float2 _Vector2_D1B88893_Out_0 = float2(0, _Property_99BA41DA_Out_0);
                    float2 _TilingAndOffset_43B8A4DE_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_D1B88893_Out_0, _TilingAndOffset_43B8A4DE_Out_3);
                    float4 _SampleTexture2D_89E84CC7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_43B8A4DE_Out_3);
                    float _SampleTexture2D_89E84CC7_R_4 = _SampleTexture2D_89E84CC7_RGBA_0.r;
                    float _SampleTexture2D_89E84CC7_G_5 = _SampleTexture2D_89E84CC7_RGBA_0.g;
                    float _SampleTexture2D_89E84CC7_B_6 = _SampleTexture2D_89E84CC7_RGBA_0.b;
                    float _SampleTexture2D_89E84CC7_A_7 = _SampleTexture2D_89E84CC7_RGBA_0.a;
                    float _Add_2AA44941_Out_2;
                    Unity_Add_float(_SampleTexture2D_FA5A1291_A_7, _SampleTexture2D_89E84CC7_A_7, _Add_2AA44941_Out_2);
                    float _Multiply_1B9776DE_Out_2;
                    Unity_Multiply_float(_Property_99BA41DA_Out_0, -1, _Multiply_1B9776DE_Out_2);
                    float2 _Vector2_443E006E_Out_0 = float2(_Multiply_1B9776DE_Out_2, 0);
                    float2 _TilingAndOffset_64C6259E_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_443E006E_Out_0, _TilingAndOffset_64C6259E_Out_3);
                    float4 _SampleTexture2D_E095F33D_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_64C6259E_Out_3);
                    float _SampleTexture2D_E095F33D_R_4 = _SampleTexture2D_E095F33D_RGBA_0.r;
                    float _SampleTexture2D_E095F33D_G_5 = _SampleTexture2D_E095F33D_RGBA_0.g;
                    float _SampleTexture2D_E095F33D_B_6 = _SampleTexture2D_E095F33D_RGBA_0.b;
                    float _SampleTexture2D_E095F33D_A_7 = _SampleTexture2D_E095F33D_RGBA_0.a;
                    float2 _Vector2_7443A6E2_Out_0 = float2(0, _Multiply_1B9776DE_Out_2);
                    float2 _TilingAndOffset_C4C0A44A_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_7443A6E2_Out_0, _TilingAndOffset_C4C0A44A_Out_3);
                    float4 _SampleTexture2D_9BDB1C01_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_C4C0A44A_Out_3);
                    float _SampleTexture2D_9BDB1C01_R_4 = _SampleTexture2D_9BDB1C01_RGBA_0.r;
                    float _SampleTexture2D_9BDB1C01_G_5 = _SampleTexture2D_9BDB1C01_RGBA_0.g;
                    float _SampleTexture2D_9BDB1C01_B_6 = _SampleTexture2D_9BDB1C01_RGBA_0.b;
                    float _SampleTexture2D_9BDB1C01_A_7 = _SampleTexture2D_9BDB1C01_RGBA_0.a;
                    float _Add_D8C8A234_Out_2;
                    Unity_Add_float(_SampleTexture2D_E095F33D_A_7, _SampleTexture2D_9BDB1C01_A_7, _Add_D8C8A234_Out_2);
                    float _Add_BC4F6FAC_Out_2;
                    Unity_Add_float(_Add_2AA44941_Out_2, _Add_D8C8A234_Out_2, _Add_BC4F6FAC_Out_2);
                    float _Clamp_BAC055DD_Out_3;
                    Unity_Clamp_float(_Add_BC4F6FAC_Out_2, 0, 1, _Clamp_BAC055DD_Out_3);
                    float4 _SampleTexture2D_72537D31_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                    float _SampleTexture2D_72537D31_R_4 = _SampleTexture2D_72537D31_RGBA_0.r;
                    float _SampleTexture2D_72537D31_G_5 = _SampleTexture2D_72537D31_RGBA_0.g;
                    float _SampleTexture2D_72537D31_B_6 = _SampleTexture2D_72537D31_RGBA_0.b;
                    float _SampleTexture2D_72537D31_A_7 = _SampleTexture2D_72537D31_RGBA_0.a;
                    float _Subtract_8EB4E9AA_Out_2;
                    Unity_Subtract_float(_Clamp_BAC055DD_Out_3, _SampleTexture2D_72537D31_A_7, _Subtract_8EB4E9AA_Out_2);
                    float4 _Property_4D4E88B3_Out_0 = Color_653B35F9;
                    float4 _Multiply_B8705920_Out_2;
                    Unity_Multiply_float((_Subtract_8EB4E9AA_Out_2.xxxx), _Property_4D4E88B3_Out_0, _Multiply_B8705920_Out_2);
                    Color_0 = _Multiply_B8705920_Out_2;
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
                    float _Property_41D3B152_Out_0 = Vector1_C843BF23;
                    float _Comparison_E8B59246_Out_2;
                    Unity_Comparison_Equal_float(_Property_41D3B152_Out_0, 1, _Comparison_E8B59246_Out_2);
                    float _Property_40D88250_Out_0 = Vector1_EF774600;
                    float _SimpleNoise_5B537726_Out_2;
                    Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_5B537726_Out_2);
                    float _OneMinus_1FA41B08_Out_1;
                    Unity_OneMinus_float(_Property_41D3B152_Out_0, _OneMinus_1FA41B08_Out_1);
                    float _Step_36A488B1_Out_2;
                    Unity_Step_float(_SimpleNoise_5B537726_Out_2, _OneMinus_1FA41B08_Out_1, _Step_36A488B1_Out_2);
                    float _Multiply_EAFAFAEC_Out_2;
                    Unity_Multiply_float(_Property_40D88250_Out_0, _Step_36A488B1_Out_2, _Multiply_EAFAFAEC_Out_2);
                    float _Add_3516D411_Out_2;
                    Unity_Add_float(_OneMinus_1FA41B08_Out_1, 0.1, _Add_3516D411_Out_2);
                    float _Step_9D0829F0_Out_2;
                    Unity_Step_float(_SimpleNoise_5B537726_Out_2, _Add_3516D411_Out_2, _Step_9D0829F0_Out_2);
                    float _Multiply_E1967D7B_Out_2;
                    Unity_Multiply_float(_Property_40D88250_Out_0, _Step_9D0829F0_Out_2, _Multiply_E1967D7B_Out_2);
                    float _Branch_92037443_Out_3;
                    Unity_Branch_float(_Comparison_E8B59246_Out_2, _Multiply_EAFAFAEC_Out_2, _Multiply_E1967D7B_Out_2, _Branch_92037443_Out_3);
                    float _Subtract_52DE93D2_Out_2;
                    Unity_Subtract_float(_Multiply_E1967D7B_Out_2, _Multiply_EAFAFAEC_Out_2, _Subtract_52DE93D2_Out_2);
                    float4 _Property_A0CC82B_Out_0 = Vector4_4DBD63;
                    float4 _Multiply_51618D24_Out_2;
                    Unity_Multiply_float((_Subtract_52DE93D2_Out_2.xxxx), _Property_A0CC82B_Out_0, _Multiply_51618D24_Out_2);
                    DissolvedAlpha_1 = _Branch_92037443_Out_3;
                    DissolvedColor_2 = _Multiply_51618D24_Out_2;
                }

                // Graph Vertex
                // GraphVertex: <None>

                // Graph Pixel
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float4 uv0;
                    float4 VertexColor;
                };

                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_AABC97FA_Out_0 = Outline;
                    float4 _SampleTexture2D_8051FBC3_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                    float _SampleTexture2D_8051FBC3_R_4 = _SampleTexture2D_8051FBC3_RGBA_0.r;
                    float _SampleTexture2D_8051FBC3_G_5 = _SampleTexture2D_8051FBC3_RGBA_0.g;
                    float _SampleTexture2D_8051FBC3_B_6 = _SampleTexture2D_8051FBC3_RGBA_0.b;
                    float _SampleTexture2D_8051FBC3_A_7 = _SampleTexture2D_8051FBC3_RGBA_0.a;
                    float4 _Multiply_B4A66C10_Out_2;
                    Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_8051FBC3_RGBA_0, _Multiply_B4A66C10_Out_2);
                    float _Property_877A111A_Out_0 = Outline_Thickness;
                    float4 _Property_2A7725AB_Out_0 = Outline_Color;
                    Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_F7A72801;
                    _OutlineSub_F7A72801.uv0 = IN.uv0;
                    float4 _OutlineSub_F7A72801_Color_0;
                    SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_877A111A_Out_0, _Property_2A7725AB_Out_0, _OutlineSub_F7A72801, _OutlineSub_F7A72801_Color_0);
                    float4 _Add_6CCBA0EE_Out_2;
                    Unity_Add_float4(_Multiply_B4A66C10_Out_2, _OutlineSub_F7A72801_Color_0, _Add_6CCBA0EE_Out_2);
                    float4 _Branch_9DA8DF8_Out_3;
                    Unity_Branch_float4(_Property_AABC97FA_Out_0, _Add_6CCBA0EE_Out_2, _Multiply_B4A66C10_Out_2, _Branch_9DA8DF8_Out_3);
                    float _Split_3586B177_R_1 = _Branch_9DA8DF8_Out_3[0];
                    float _Split_3586B177_G_2 = _Branch_9DA8DF8_Out_3[1];
                    float _Split_3586B177_B_3 = _Branch_9DA8DF8_Out_3[2];
                    float _Split_3586B177_A_4 = _Branch_9DA8DF8_Out_3[3];
                    float _Property_96D859E1_Out_0 = Dissolve_Progress;
                    float4 _Property_ECC6743E_Out_0 = Dissolve_Color;
                    Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_D2F824E7;
                    _DissolveSub_D2F824E7.uv0 = IN.uv0;
                    float _DissolveSub_D2F824E7_DissolvedAlpha_1;
                    float4 _DissolveSub_D2F824E7_DissolvedColor_2;
                    SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_3586B177_A_4, _Property_96D859E1_Out_0, _Property_ECC6743E_Out_0, _DissolveSub_D2F824E7, _DissolveSub_D2F824E7_DissolvedAlpha_1, _DissolveSub_D2F824E7_DissolvedColor_2);
                    surface.Alpha = _DissolveSub_D2F824E7_DissolvedAlpha_1;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }

                // --------------------------------------------------
                // Structs and Packing

                // Generated Type: Attributes
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

                // Generated Type: Varyings
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float4 texCoord0;
                    float4 color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                // Generated Type: PackedVaryings
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    float4 interp00 : TEXCOORD0;
                    float4 interp01 : TEXCOORD1;
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                // Packed Type: Varyings
                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output = (PackedVaryings)0;
                    output.positionCS = input.positionCS;
                    output.interp00.xyzw = input.texCoord0;
                    output.interp01.xyzw = input.color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                // Unpacked Type: Varyings
                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output = (Varyings)0;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.interp00.xyzw;
                    output.color = input.interp01.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                // --------------------------------------------------
                // Build Graph Inputs

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
                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                    Cull Off
                    ZTest LEqual
                    ZWrite On
                    ColorMask 0


                    HLSLPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    // Pragmas
                    #pragma prefer_hlslcc gles
                    #pragma exclude_renderers d3d11_9x
                    #pragma target 2.0
                    #pragma multi_compile_instancing

                    // Keywords
                    // PassKeywords: <None>
                    // GraphKeywords: <None>

                    // Defines
                    #define _SURFACE_TYPE_TRANSPARENT 1
                    #define _AlphaClip 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define ATTRIBUTES_NEED_TEXCOORD0
                    #define ATTRIBUTES_NEED_COLOR
                    #define VARYINGS_NEED_TEXCOORD0
                    #define VARYINGS_NEED_COLOR
                    #define SHADERPASS_DEPTHONLY

                    // Includes
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float4 _EmissionColor;
                    float Dissolve_Progress;
                    float4 Dissolve_Color;
                    float Outline;
                    float Outline_Thickness;
                    float4 Outline_Color;
                    CBUFFER_END
                    TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                    TEXTURE2D(_EmissionTex); SAMPLER(sampler_EmissionTex); float4 _EmissionTex_TexelSize;
                    SAMPLER(_SampleTexture2D_8051FBC3_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_FA5A1291_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_89E84CC7_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_E095F33D_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_9BDB1C01_Sampler_3_Linear_Repeat);
                    SAMPLER(_SampleTexture2D_72537D31_Sampler_3_Linear_Repeat);

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
                        float _Property_99BA41DA_Out_0 = Vector1_DE900D83;
                        float2 _Vector2_FAFB8C83_Out_0 = float2(_Property_99BA41DA_Out_0, 0);
                        float2 _TilingAndOffset_1A54AB_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_FAFB8C83_Out_0, _TilingAndOffset_1A54AB_Out_3);
                        float4 _SampleTexture2D_FA5A1291_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_1A54AB_Out_3);
                        float _SampleTexture2D_FA5A1291_R_4 = _SampleTexture2D_FA5A1291_RGBA_0.r;
                        float _SampleTexture2D_FA5A1291_G_5 = _SampleTexture2D_FA5A1291_RGBA_0.g;
                        float _SampleTexture2D_FA5A1291_B_6 = _SampleTexture2D_FA5A1291_RGBA_0.b;
                        float _SampleTexture2D_FA5A1291_A_7 = _SampleTexture2D_FA5A1291_RGBA_0.a;
                        float2 _Vector2_D1B88893_Out_0 = float2(0, _Property_99BA41DA_Out_0);
                        float2 _TilingAndOffset_43B8A4DE_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_D1B88893_Out_0, _TilingAndOffset_43B8A4DE_Out_3);
                        float4 _SampleTexture2D_89E84CC7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_43B8A4DE_Out_3);
                        float _SampleTexture2D_89E84CC7_R_4 = _SampleTexture2D_89E84CC7_RGBA_0.r;
                        float _SampleTexture2D_89E84CC7_G_5 = _SampleTexture2D_89E84CC7_RGBA_0.g;
                        float _SampleTexture2D_89E84CC7_B_6 = _SampleTexture2D_89E84CC7_RGBA_0.b;
                        float _SampleTexture2D_89E84CC7_A_7 = _SampleTexture2D_89E84CC7_RGBA_0.a;
                        float _Add_2AA44941_Out_2;
                        Unity_Add_float(_SampleTexture2D_FA5A1291_A_7, _SampleTexture2D_89E84CC7_A_7, _Add_2AA44941_Out_2);
                        float _Multiply_1B9776DE_Out_2;
                        Unity_Multiply_float(_Property_99BA41DA_Out_0, -1, _Multiply_1B9776DE_Out_2);
                        float2 _Vector2_443E006E_Out_0 = float2(_Multiply_1B9776DE_Out_2, 0);
                        float2 _TilingAndOffset_64C6259E_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_443E006E_Out_0, _TilingAndOffset_64C6259E_Out_3);
                        float4 _SampleTexture2D_E095F33D_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_64C6259E_Out_3);
                        float _SampleTexture2D_E095F33D_R_4 = _SampleTexture2D_E095F33D_RGBA_0.r;
                        float _SampleTexture2D_E095F33D_G_5 = _SampleTexture2D_E095F33D_RGBA_0.g;
                        float _SampleTexture2D_E095F33D_B_6 = _SampleTexture2D_E095F33D_RGBA_0.b;
                        float _SampleTexture2D_E095F33D_A_7 = _SampleTexture2D_E095F33D_RGBA_0.a;
                        float2 _Vector2_7443A6E2_Out_0 = float2(0, _Multiply_1B9776DE_Out_2);
                        float2 _TilingAndOffset_C4C0A44A_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_7443A6E2_Out_0, _TilingAndOffset_C4C0A44A_Out_3);
                        float4 _SampleTexture2D_9BDB1C01_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_C4C0A44A_Out_3);
                        float _SampleTexture2D_9BDB1C01_R_4 = _SampleTexture2D_9BDB1C01_RGBA_0.r;
                        float _SampleTexture2D_9BDB1C01_G_5 = _SampleTexture2D_9BDB1C01_RGBA_0.g;
                        float _SampleTexture2D_9BDB1C01_B_6 = _SampleTexture2D_9BDB1C01_RGBA_0.b;
                        float _SampleTexture2D_9BDB1C01_A_7 = _SampleTexture2D_9BDB1C01_RGBA_0.a;
                        float _Add_D8C8A234_Out_2;
                        Unity_Add_float(_SampleTexture2D_E095F33D_A_7, _SampleTexture2D_9BDB1C01_A_7, _Add_D8C8A234_Out_2);
                        float _Add_BC4F6FAC_Out_2;
                        Unity_Add_float(_Add_2AA44941_Out_2, _Add_D8C8A234_Out_2, _Add_BC4F6FAC_Out_2);
                        float _Clamp_BAC055DD_Out_3;
                        Unity_Clamp_float(_Add_BC4F6FAC_Out_2, 0, 1, _Clamp_BAC055DD_Out_3);
                        float4 _SampleTexture2D_72537D31_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                        float _SampleTexture2D_72537D31_R_4 = _SampleTexture2D_72537D31_RGBA_0.r;
                        float _SampleTexture2D_72537D31_G_5 = _SampleTexture2D_72537D31_RGBA_0.g;
                        float _SampleTexture2D_72537D31_B_6 = _SampleTexture2D_72537D31_RGBA_0.b;
                        float _SampleTexture2D_72537D31_A_7 = _SampleTexture2D_72537D31_RGBA_0.a;
                        float _Subtract_8EB4E9AA_Out_2;
                        Unity_Subtract_float(_Clamp_BAC055DD_Out_3, _SampleTexture2D_72537D31_A_7, _Subtract_8EB4E9AA_Out_2);
                        float4 _Property_4D4E88B3_Out_0 = Color_653B35F9;
                        float4 _Multiply_B8705920_Out_2;
                        Unity_Multiply_float((_Subtract_8EB4E9AA_Out_2.xxxx), _Property_4D4E88B3_Out_0, _Multiply_B8705920_Out_2);
                        Color_0 = _Multiply_B8705920_Out_2;
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
                        float _Property_41D3B152_Out_0 = Vector1_C843BF23;
                        float _Comparison_E8B59246_Out_2;
                        Unity_Comparison_Equal_float(_Property_41D3B152_Out_0, 1, _Comparison_E8B59246_Out_2);
                        float _Property_40D88250_Out_0 = Vector1_EF774600;
                        float _SimpleNoise_5B537726_Out_2;
                        Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_5B537726_Out_2);
                        float _OneMinus_1FA41B08_Out_1;
                        Unity_OneMinus_float(_Property_41D3B152_Out_0, _OneMinus_1FA41B08_Out_1);
                        float _Step_36A488B1_Out_2;
                        Unity_Step_float(_SimpleNoise_5B537726_Out_2, _OneMinus_1FA41B08_Out_1, _Step_36A488B1_Out_2);
                        float _Multiply_EAFAFAEC_Out_2;
                        Unity_Multiply_float(_Property_40D88250_Out_0, _Step_36A488B1_Out_2, _Multiply_EAFAFAEC_Out_2);
                        float _Add_3516D411_Out_2;
                        Unity_Add_float(_OneMinus_1FA41B08_Out_1, 0.1, _Add_3516D411_Out_2);
                        float _Step_9D0829F0_Out_2;
                        Unity_Step_float(_SimpleNoise_5B537726_Out_2, _Add_3516D411_Out_2, _Step_9D0829F0_Out_2);
                        float _Multiply_E1967D7B_Out_2;
                        Unity_Multiply_float(_Property_40D88250_Out_0, _Step_9D0829F0_Out_2, _Multiply_E1967D7B_Out_2);
                        float _Branch_92037443_Out_3;
                        Unity_Branch_float(_Comparison_E8B59246_Out_2, _Multiply_EAFAFAEC_Out_2, _Multiply_E1967D7B_Out_2, _Branch_92037443_Out_3);
                        float _Subtract_52DE93D2_Out_2;
                        Unity_Subtract_float(_Multiply_E1967D7B_Out_2, _Multiply_EAFAFAEC_Out_2, _Subtract_52DE93D2_Out_2);
                        float4 _Property_A0CC82B_Out_0 = Vector4_4DBD63;
                        float4 _Multiply_51618D24_Out_2;
                        Unity_Multiply_float((_Subtract_52DE93D2_Out_2.xxxx), _Property_A0CC82B_Out_0, _Multiply_51618D24_Out_2);
                        DissolvedAlpha_1 = _Branch_92037443_Out_3;
                        DissolvedColor_2 = _Multiply_51618D24_Out_2;
                    }

                    // Graph Vertex
                    // GraphVertex: <None>

                    // Graph Pixel
                    struct SurfaceDescriptionInputs
                    {
                        float3 TangentSpaceNormal;
                        float4 uv0;
                        float4 VertexColor;
                    };

                    struct SurfaceDescription
                    {
                        float Alpha;
                        float AlphaClipThreshold;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _Property_AABC97FA_Out_0 = Outline;
                        float4 _SampleTexture2D_8051FBC3_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                        float _SampleTexture2D_8051FBC3_R_4 = _SampleTexture2D_8051FBC3_RGBA_0.r;
                        float _SampleTexture2D_8051FBC3_G_5 = _SampleTexture2D_8051FBC3_RGBA_0.g;
                        float _SampleTexture2D_8051FBC3_B_6 = _SampleTexture2D_8051FBC3_RGBA_0.b;
                        float _SampleTexture2D_8051FBC3_A_7 = _SampleTexture2D_8051FBC3_RGBA_0.a;
                        float4 _Multiply_B4A66C10_Out_2;
                        Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_8051FBC3_RGBA_0, _Multiply_B4A66C10_Out_2);
                        float _Property_877A111A_Out_0 = Outline_Thickness;
                        float4 _Property_2A7725AB_Out_0 = Outline_Color;
                        Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_F7A72801;
                        _OutlineSub_F7A72801.uv0 = IN.uv0;
                        float4 _OutlineSub_F7A72801_Color_0;
                        SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_877A111A_Out_0, _Property_2A7725AB_Out_0, _OutlineSub_F7A72801, _OutlineSub_F7A72801_Color_0);
                        float4 _Add_6CCBA0EE_Out_2;
                        Unity_Add_float4(_Multiply_B4A66C10_Out_2, _OutlineSub_F7A72801_Color_0, _Add_6CCBA0EE_Out_2);
                        float4 _Branch_9DA8DF8_Out_3;
                        Unity_Branch_float4(_Property_AABC97FA_Out_0, _Add_6CCBA0EE_Out_2, _Multiply_B4A66C10_Out_2, _Branch_9DA8DF8_Out_3);
                        float _Split_3586B177_R_1 = _Branch_9DA8DF8_Out_3[0];
                        float _Split_3586B177_G_2 = _Branch_9DA8DF8_Out_3[1];
                        float _Split_3586B177_B_3 = _Branch_9DA8DF8_Out_3[2];
                        float _Split_3586B177_A_4 = _Branch_9DA8DF8_Out_3[3];
                        float _Property_96D859E1_Out_0 = Dissolve_Progress;
                        float4 _Property_ECC6743E_Out_0 = Dissolve_Color;
                        Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_D2F824E7;
                        _DissolveSub_D2F824E7.uv0 = IN.uv0;
                        float _DissolveSub_D2F824E7_DissolvedAlpha_1;
                        float4 _DissolveSub_D2F824E7_DissolvedColor_2;
                        SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_3586B177_A_4, _Property_96D859E1_Out_0, _Property_ECC6743E_Out_0, _DissolveSub_D2F824E7, _DissolveSub_D2F824E7_DissolvedAlpha_1, _DissolveSub_D2F824E7_DissolvedColor_2);
                        surface.Alpha = _DissolveSub_D2F824E7_DissolvedAlpha_1;
                        surface.AlphaClipThreshold = 0.5;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Structs and Packing

                    // Generated Type: Attributes
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

                    // Generated Type: Varyings
                    struct Varyings
                    {
                        float4 positionCS : SV_POSITION;
                        float4 texCoord0;
                        float4 color;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    // Generated Type: PackedVaryings
                    struct PackedVaryings
                    {
                        float4 positionCS : SV_POSITION;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        float4 interp00 : TEXCOORD0;
                        float4 interp01 : TEXCOORD1;
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    // Packed Type: Varyings
                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output = (PackedVaryings)0;
                        output.positionCS = input.positionCS;
                        output.interp00.xyzw = input.texCoord0;
                        output.interp01.xyzw = input.color;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    // Unpacked Type: Varyings
                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output = (Varyings)0;
                        output.positionCS = input.positionCS;
                        output.texCoord0 = input.interp00.xyzw;
                        output.color = input.interp01.xyzw;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs

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

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

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
                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                        Cull Off
                        ZTest LEqual
                        ZWrite On
                        // ColorMask: <None>


                        HLSLPROGRAM
                        #pragma vertex vert
                        #pragma fragment frag

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        // Pragmas
                        #pragma prefer_hlslcc gles
                        #pragma exclude_renderers d3d11_9x
                        #pragma target 2.0

                        // Keywords
                        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                        // GraphKeywords: <None>

                        // Defines
                        #define _SURFACE_TYPE_TRANSPARENT 1
                        #define _AlphaClip 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define ATTRIBUTES_NEED_TEXCOORD2
                        #define ATTRIBUTES_NEED_COLOR
                        #define VARYINGS_NEED_TEXCOORD0
                        #define VARYINGS_NEED_COLOR
                        #define SHADERPASS_META

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                        #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _EmissionColor;
                        float Dissolve_Progress;
                        float4 Dissolve_Color;
                        float Outline;
                        float Outline_Thickness;
                        float4 Outline_Color;
                        CBUFFER_END
                        TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                        TEXTURE2D(_EmissionTex); SAMPLER(sampler_EmissionTex); float4 _EmissionTex_TexelSize;
                        SAMPLER(_SampleTexture2D_8051FBC3_Sampler_3_Linear_Repeat);
                        SAMPLER(_SampleTexture2D_FA5A1291_Sampler_3_Linear_Repeat);
                        SAMPLER(_SampleTexture2D_89E84CC7_Sampler_3_Linear_Repeat);
                        SAMPLER(_SampleTexture2D_E095F33D_Sampler_3_Linear_Repeat);
                        SAMPLER(_SampleTexture2D_9BDB1C01_Sampler_3_Linear_Repeat);
                        SAMPLER(_SampleTexture2D_72537D31_Sampler_3_Linear_Repeat);
                        SAMPLER(_SampleTexture2D_55D129C0_Sampler_3_Linear_Repeat);

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
                            float _Property_99BA41DA_Out_0 = Vector1_DE900D83;
                            float2 _Vector2_FAFB8C83_Out_0 = float2(_Property_99BA41DA_Out_0, 0);
                            float2 _TilingAndOffset_1A54AB_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_FAFB8C83_Out_0, _TilingAndOffset_1A54AB_Out_3);
                            float4 _SampleTexture2D_FA5A1291_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_1A54AB_Out_3);
                            float _SampleTexture2D_FA5A1291_R_4 = _SampleTexture2D_FA5A1291_RGBA_0.r;
                            float _SampleTexture2D_FA5A1291_G_5 = _SampleTexture2D_FA5A1291_RGBA_0.g;
                            float _SampleTexture2D_FA5A1291_B_6 = _SampleTexture2D_FA5A1291_RGBA_0.b;
                            float _SampleTexture2D_FA5A1291_A_7 = _SampleTexture2D_FA5A1291_RGBA_0.a;
                            float2 _Vector2_D1B88893_Out_0 = float2(0, _Property_99BA41DA_Out_0);
                            float2 _TilingAndOffset_43B8A4DE_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_D1B88893_Out_0, _TilingAndOffset_43B8A4DE_Out_3);
                            float4 _SampleTexture2D_89E84CC7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_43B8A4DE_Out_3);
                            float _SampleTexture2D_89E84CC7_R_4 = _SampleTexture2D_89E84CC7_RGBA_0.r;
                            float _SampleTexture2D_89E84CC7_G_5 = _SampleTexture2D_89E84CC7_RGBA_0.g;
                            float _SampleTexture2D_89E84CC7_B_6 = _SampleTexture2D_89E84CC7_RGBA_0.b;
                            float _SampleTexture2D_89E84CC7_A_7 = _SampleTexture2D_89E84CC7_RGBA_0.a;
                            float _Add_2AA44941_Out_2;
                            Unity_Add_float(_SampleTexture2D_FA5A1291_A_7, _SampleTexture2D_89E84CC7_A_7, _Add_2AA44941_Out_2);
                            float _Multiply_1B9776DE_Out_2;
                            Unity_Multiply_float(_Property_99BA41DA_Out_0, -1, _Multiply_1B9776DE_Out_2);
                            float2 _Vector2_443E006E_Out_0 = float2(_Multiply_1B9776DE_Out_2, 0);
                            float2 _TilingAndOffset_64C6259E_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_443E006E_Out_0, _TilingAndOffset_64C6259E_Out_3);
                            float4 _SampleTexture2D_E095F33D_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_64C6259E_Out_3);
                            float _SampleTexture2D_E095F33D_R_4 = _SampleTexture2D_E095F33D_RGBA_0.r;
                            float _SampleTexture2D_E095F33D_G_5 = _SampleTexture2D_E095F33D_RGBA_0.g;
                            float _SampleTexture2D_E095F33D_B_6 = _SampleTexture2D_E095F33D_RGBA_0.b;
                            float _SampleTexture2D_E095F33D_A_7 = _SampleTexture2D_E095F33D_RGBA_0.a;
                            float2 _Vector2_7443A6E2_Out_0 = float2(0, _Multiply_1B9776DE_Out_2);
                            float2 _TilingAndOffset_C4C0A44A_Out_3;
                            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_7443A6E2_Out_0, _TilingAndOffset_C4C0A44A_Out_3);
                            float4 _SampleTexture2D_9BDB1C01_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_C4C0A44A_Out_3);
                            float _SampleTexture2D_9BDB1C01_R_4 = _SampleTexture2D_9BDB1C01_RGBA_0.r;
                            float _SampleTexture2D_9BDB1C01_G_5 = _SampleTexture2D_9BDB1C01_RGBA_0.g;
                            float _SampleTexture2D_9BDB1C01_B_6 = _SampleTexture2D_9BDB1C01_RGBA_0.b;
                            float _SampleTexture2D_9BDB1C01_A_7 = _SampleTexture2D_9BDB1C01_RGBA_0.a;
                            float _Add_D8C8A234_Out_2;
                            Unity_Add_float(_SampleTexture2D_E095F33D_A_7, _SampleTexture2D_9BDB1C01_A_7, _Add_D8C8A234_Out_2);
                            float _Add_BC4F6FAC_Out_2;
                            Unity_Add_float(_Add_2AA44941_Out_2, _Add_D8C8A234_Out_2, _Add_BC4F6FAC_Out_2);
                            float _Clamp_BAC055DD_Out_3;
                            Unity_Clamp_float(_Add_BC4F6FAC_Out_2, 0, 1, _Clamp_BAC055DD_Out_3);
                            float4 _SampleTexture2D_72537D31_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                            float _SampleTexture2D_72537D31_R_4 = _SampleTexture2D_72537D31_RGBA_0.r;
                            float _SampleTexture2D_72537D31_G_5 = _SampleTexture2D_72537D31_RGBA_0.g;
                            float _SampleTexture2D_72537D31_B_6 = _SampleTexture2D_72537D31_RGBA_0.b;
                            float _SampleTexture2D_72537D31_A_7 = _SampleTexture2D_72537D31_RGBA_0.a;
                            float _Subtract_8EB4E9AA_Out_2;
                            Unity_Subtract_float(_Clamp_BAC055DD_Out_3, _SampleTexture2D_72537D31_A_7, _Subtract_8EB4E9AA_Out_2);
                            float4 _Property_4D4E88B3_Out_0 = Color_653B35F9;
                            float4 _Multiply_B8705920_Out_2;
                            Unity_Multiply_float((_Subtract_8EB4E9AA_Out_2.xxxx), _Property_4D4E88B3_Out_0, _Multiply_B8705920_Out_2);
                            Color_0 = _Multiply_B8705920_Out_2;
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
                            float _Property_41D3B152_Out_0 = Vector1_C843BF23;
                            float _Comparison_E8B59246_Out_2;
                            Unity_Comparison_Equal_float(_Property_41D3B152_Out_0, 1, _Comparison_E8B59246_Out_2);
                            float _Property_40D88250_Out_0 = Vector1_EF774600;
                            float _SimpleNoise_5B537726_Out_2;
                            Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_5B537726_Out_2);
                            float _OneMinus_1FA41B08_Out_1;
                            Unity_OneMinus_float(_Property_41D3B152_Out_0, _OneMinus_1FA41B08_Out_1);
                            float _Step_36A488B1_Out_2;
                            Unity_Step_float(_SimpleNoise_5B537726_Out_2, _OneMinus_1FA41B08_Out_1, _Step_36A488B1_Out_2);
                            float _Multiply_EAFAFAEC_Out_2;
                            Unity_Multiply_float(_Property_40D88250_Out_0, _Step_36A488B1_Out_2, _Multiply_EAFAFAEC_Out_2);
                            float _Add_3516D411_Out_2;
                            Unity_Add_float(_OneMinus_1FA41B08_Out_1, 0.1, _Add_3516D411_Out_2);
                            float _Step_9D0829F0_Out_2;
                            Unity_Step_float(_SimpleNoise_5B537726_Out_2, _Add_3516D411_Out_2, _Step_9D0829F0_Out_2);
                            float _Multiply_E1967D7B_Out_2;
                            Unity_Multiply_float(_Property_40D88250_Out_0, _Step_9D0829F0_Out_2, _Multiply_E1967D7B_Out_2);
                            float _Branch_92037443_Out_3;
                            Unity_Branch_float(_Comparison_E8B59246_Out_2, _Multiply_EAFAFAEC_Out_2, _Multiply_E1967D7B_Out_2, _Branch_92037443_Out_3);
                            float _Subtract_52DE93D2_Out_2;
                            Unity_Subtract_float(_Multiply_E1967D7B_Out_2, _Multiply_EAFAFAEC_Out_2, _Subtract_52DE93D2_Out_2);
                            float4 _Property_A0CC82B_Out_0 = Vector4_4DBD63;
                            float4 _Multiply_51618D24_Out_2;
                            Unity_Multiply_float((_Subtract_52DE93D2_Out_2.xxxx), _Property_A0CC82B_Out_0, _Multiply_51618D24_Out_2);
                            DissolvedAlpha_1 = _Branch_92037443_Out_3;
                            DissolvedColor_2 = _Multiply_51618D24_Out_2;
                        }

                        // Graph Vertex
                        // GraphVertex: <None>

                        // Graph Pixel
                        struct SurfaceDescriptionInputs
                        {
                            float3 TangentSpaceNormal;
                            float4 uv0;
                            float4 VertexColor;
                        };

                        struct SurfaceDescription
                        {
                            float3 Albedo;
                            float3 Emission;
                            float Alpha;
                            float AlphaClipThreshold;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            float _Property_6B778FE2_Out_0 = Dissolve_Progress;
                            float _Comparison_4EC89164_Out_2;
                            Unity_Comparison_Equal_float(_Property_6B778FE2_Out_0, 0, _Comparison_4EC89164_Out_2);
                            float _Property_AABC97FA_Out_0 = Outline;
                            float4 _SampleTexture2D_8051FBC3_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                            float _SampleTexture2D_8051FBC3_R_4 = _SampleTexture2D_8051FBC3_RGBA_0.r;
                            float _SampleTexture2D_8051FBC3_G_5 = _SampleTexture2D_8051FBC3_RGBA_0.g;
                            float _SampleTexture2D_8051FBC3_B_6 = _SampleTexture2D_8051FBC3_RGBA_0.b;
                            float _SampleTexture2D_8051FBC3_A_7 = _SampleTexture2D_8051FBC3_RGBA_0.a;
                            float4 _Multiply_B4A66C10_Out_2;
                            Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_8051FBC3_RGBA_0, _Multiply_B4A66C10_Out_2);
                            float _Property_877A111A_Out_0 = Outline_Thickness;
                            float4 _Property_2A7725AB_Out_0 = Outline_Color;
                            Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_F7A72801;
                            _OutlineSub_F7A72801.uv0 = IN.uv0;
                            float4 _OutlineSub_F7A72801_Color_0;
                            SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_877A111A_Out_0, _Property_2A7725AB_Out_0, _OutlineSub_F7A72801, _OutlineSub_F7A72801_Color_0);
                            float4 _Add_6CCBA0EE_Out_2;
                            Unity_Add_float4(_Multiply_B4A66C10_Out_2, _OutlineSub_F7A72801_Color_0, _Add_6CCBA0EE_Out_2);
                            float4 _Branch_9DA8DF8_Out_3;
                            Unity_Branch_float4(_Property_AABC97FA_Out_0, _Add_6CCBA0EE_Out_2, _Multiply_B4A66C10_Out_2, _Branch_9DA8DF8_Out_3);
                            float _Split_3586B177_R_1 = _Branch_9DA8DF8_Out_3[0];
                            float _Split_3586B177_G_2 = _Branch_9DA8DF8_Out_3[1];
                            float _Split_3586B177_B_3 = _Branch_9DA8DF8_Out_3[2];
                            float _Split_3586B177_A_4 = _Branch_9DA8DF8_Out_3[3];
                            float _Property_96D859E1_Out_0 = Dissolve_Progress;
                            float4 _Property_ECC6743E_Out_0 = Dissolve_Color;
                            Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_D2F824E7;
                            _DissolveSub_D2F824E7.uv0 = IN.uv0;
                            float _DissolveSub_D2F824E7_DissolvedAlpha_1;
                            float4 _DissolveSub_D2F824E7_DissolvedColor_2;
                            SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_3586B177_A_4, _Property_96D859E1_Out_0, _Property_ECC6743E_Out_0, _DissolveSub_D2F824E7, _DissolveSub_D2F824E7_DissolvedAlpha_1, _DissolveSub_D2F824E7_DissolvedColor_2);
                            float4 _Add_35D8B386_Out_2;
                            Unity_Add_float4(_Branch_9DA8DF8_Out_3, _DissolveSub_D2F824E7_DissolvedColor_2, _Add_35D8B386_Out_2);
                            float4 _Branch_8686AB9C_Out_3;
                            Unity_Branch_float4(_Comparison_4EC89164_Out_2, _Branch_9DA8DF8_Out_3, _Add_35D8B386_Out_2, _Branch_8686AB9C_Out_3);
                            float4 _SampleTexture2D_55D129C0_RGBA_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, IN.uv0.xy);
                            float _SampleTexture2D_55D129C0_R_4 = _SampleTexture2D_55D129C0_RGBA_0.r;
                            float _SampleTexture2D_55D129C0_G_5 = _SampleTexture2D_55D129C0_RGBA_0.g;
                            float _SampleTexture2D_55D129C0_B_6 = _SampleTexture2D_55D129C0_RGBA_0.b;
                            float _SampleTexture2D_55D129C0_A_7 = _SampleTexture2D_55D129C0_RGBA_0.a;
                            float4 _Property_757F56F2_Out_0 = _EmissionColor;
                            float4 _Multiply_7771456A_Out_2;
                            Unity_Multiply_float(_SampleTexture2D_55D129C0_RGBA_0, _Property_757F56F2_Out_0, _Multiply_7771456A_Out_2);
                            surface.Albedo = (_Branch_8686AB9C_Out_3.xyz);
                            surface.Emission = (_Multiply_7771456A_Out_2.xyz);
                            surface.Alpha = _DissolveSub_D2F824E7_DissolvedAlpha_1;
                            surface.AlphaClipThreshold = 0.5;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Structs and Packing

                        // Generated Type: Attributes
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

                        // Generated Type: Varyings
                        struct Varyings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 texCoord0;
                            float4 color;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        // Generated Type: PackedVaryings
                        struct PackedVaryings
                        {
                            float4 positionCS : SV_POSITION;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            float4 interp00 : TEXCOORD0;
                            float4 interp01 : TEXCOORD1;
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        // Packed Type: Varyings
                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output = (PackedVaryings)0;
                            output.positionCS = input.positionCS;
                            output.interp00.xyzw = input.texCoord0;
                            output.interp01.xyzw = input.color;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        // Unpacked Type: Varyings
                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output = (Varyings)0;
                            output.positionCS = input.positionCS;
                            output.texCoord0 = input.interp00.xyzw;
                            output.color = input.interp01.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs

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
                            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                            Cull Off
                            ZTest LEqual
                            ZWrite Off
                            // ColorMask: <None>


                            HLSLPROGRAM
                            #pragma vertex vert
                            #pragma fragment frag

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            // Pragmas
                            #pragma prefer_hlslcc gles
                            #pragma exclude_renderers d3d11_9x
                            #pragma target 2.0
                            #pragma multi_compile_instancing

                            // Keywords
                            // PassKeywords: <None>
                            // GraphKeywords: <None>

                            // Defines
                            #define _SURFACE_TYPE_TRANSPARENT 1
                            #define _AlphaClip 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD0
                            #define ATTRIBUTES_NEED_COLOR
                            #define VARYINGS_NEED_TEXCOORD0
                            #define VARYINGS_NEED_COLOR
                            #define SHADERPASS_2D

                            // Includes
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float4 _EmissionColor;
                            float Dissolve_Progress;
                            float4 Dissolve_Color;
                            float Outline;
                            float Outline_Thickness;
                            float4 Outline_Color;
                            CBUFFER_END
                            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                            TEXTURE2D(_EmissionTex); SAMPLER(sampler_EmissionTex); float4 _EmissionTex_TexelSize;
                            SAMPLER(_SampleTexture2D_8051FBC3_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_FA5A1291_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_89E84CC7_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_E095F33D_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_9BDB1C01_Sampler_3_Linear_Repeat);
                            SAMPLER(_SampleTexture2D_72537D31_Sampler_3_Linear_Repeat);

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
                                float _Property_99BA41DA_Out_0 = Vector1_DE900D83;
                                float2 _Vector2_FAFB8C83_Out_0 = float2(_Property_99BA41DA_Out_0, 0);
                                float2 _TilingAndOffset_1A54AB_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_FAFB8C83_Out_0, _TilingAndOffset_1A54AB_Out_3);
                                float4 _SampleTexture2D_FA5A1291_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_1A54AB_Out_3);
                                float _SampleTexture2D_FA5A1291_R_4 = _SampleTexture2D_FA5A1291_RGBA_0.r;
                                float _SampleTexture2D_FA5A1291_G_5 = _SampleTexture2D_FA5A1291_RGBA_0.g;
                                float _SampleTexture2D_FA5A1291_B_6 = _SampleTexture2D_FA5A1291_RGBA_0.b;
                                float _SampleTexture2D_FA5A1291_A_7 = _SampleTexture2D_FA5A1291_RGBA_0.a;
                                float2 _Vector2_D1B88893_Out_0 = float2(0, _Property_99BA41DA_Out_0);
                                float2 _TilingAndOffset_43B8A4DE_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_D1B88893_Out_0, _TilingAndOffset_43B8A4DE_Out_3);
                                float4 _SampleTexture2D_89E84CC7_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_43B8A4DE_Out_3);
                                float _SampleTexture2D_89E84CC7_R_4 = _SampleTexture2D_89E84CC7_RGBA_0.r;
                                float _SampleTexture2D_89E84CC7_G_5 = _SampleTexture2D_89E84CC7_RGBA_0.g;
                                float _SampleTexture2D_89E84CC7_B_6 = _SampleTexture2D_89E84CC7_RGBA_0.b;
                                float _SampleTexture2D_89E84CC7_A_7 = _SampleTexture2D_89E84CC7_RGBA_0.a;
                                float _Add_2AA44941_Out_2;
                                Unity_Add_float(_SampleTexture2D_FA5A1291_A_7, _SampleTexture2D_89E84CC7_A_7, _Add_2AA44941_Out_2);
                                float _Multiply_1B9776DE_Out_2;
                                Unity_Multiply_float(_Property_99BA41DA_Out_0, -1, _Multiply_1B9776DE_Out_2);
                                float2 _Vector2_443E006E_Out_0 = float2(_Multiply_1B9776DE_Out_2, 0);
                                float2 _TilingAndOffset_64C6259E_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_443E006E_Out_0, _TilingAndOffset_64C6259E_Out_3);
                                float4 _SampleTexture2D_E095F33D_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_64C6259E_Out_3);
                                float _SampleTexture2D_E095F33D_R_4 = _SampleTexture2D_E095F33D_RGBA_0.r;
                                float _SampleTexture2D_E095F33D_G_5 = _SampleTexture2D_E095F33D_RGBA_0.g;
                                float _SampleTexture2D_E095F33D_B_6 = _SampleTexture2D_E095F33D_RGBA_0.b;
                                float _SampleTexture2D_E095F33D_A_7 = _SampleTexture2D_E095F33D_RGBA_0.a;
                                float2 _Vector2_7443A6E2_Out_0 = float2(0, _Multiply_1B9776DE_Out_2);
                                float2 _TilingAndOffset_C4C0A44A_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_7443A6E2_Out_0, _TilingAndOffset_C4C0A44A_Out_3);
                                float4 _SampleTexture2D_9BDB1C01_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, _TilingAndOffset_C4C0A44A_Out_3);
                                float _SampleTexture2D_9BDB1C01_R_4 = _SampleTexture2D_9BDB1C01_RGBA_0.r;
                                float _SampleTexture2D_9BDB1C01_G_5 = _SampleTexture2D_9BDB1C01_RGBA_0.g;
                                float _SampleTexture2D_9BDB1C01_B_6 = _SampleTexture2D_9BDB1C01_RGBA_0.b;
                                float _SampleTexture2D_9BDB1C01_A_7 = _SampleTexture2D_9BDB1C01_RGBA_0.a;
                                float _Add_D8C8A234_Out_2;
                                Unity_Add_float(_SampleTexture2D_E095F33D_A_7, _SampleTexture2D_9BDB1C01_A_7, _Add_D8C8A234_Out_2);
                                float _Add_BC4F6FAC_Out_2;
                                Unity_Add_float(_Add_2AA44941_Out_2, _Add_D8C8A234_Out_2, _Add_BC4F6FAC_Out_2);
                                float _Clamp_BAC055DD_Out_3;
                                Unity_Clamp_float(_Add_BC4F6FAC_Out_2, 0, 1, _Clamp_BAC055DD_Out_3);
                                float4 _SampleTexture2D_72537D31_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_C0198DFC, samplerTexture2D_C0198DFC, IN.uv0.xy);
                                float _SampleTexture2D_72537D31_R_4 = _SampleTexture2D_72537D31_RGBA_0.r;
                                float _SampleTexture2D_72537D31_G_5 = _SampleTexture2D_72537D31_RGBA_0.g;
                                float _SampleTexture2D_72537D31_B_6 = _SampleTexture2D_72537D31_RGBA_0.b;
                                float _SampleTexture2D_72537D31_A_7 = _SampleTexture2D_72537D31_RGBA_0.a;
                                float _Subtract_8EB4E9AA_Out_2;
                                Unity_Subtract_float(_Clamp_BAC055DD_Out_3, _SampleTexture2D_72537D31_A_7, _Subtract_8EB4E9AA_Out_2);
                                float4 _Property_4D4E88B3_Out_0 = Color_653B35F9;
                                float4 _Multiply_B8705920_Out_2;
                                Unity_Multiply_float((_Subtract_8EB4E9AA_Out_2.xxxx), _Property_4D4E88B3_Out_0, _Multiply_B8705920_Out_2);
                                Color_0 = _Multiply_B8705920_Out_2;
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
                                float _Property_41D3B152_Out_0 = Vector1_C843BF23;
                                float _Comparison_E8B59246_Out_2;
                                Unity_Comparison_Equal_float(_Property_41D3B152_Out_0, 1, _Comparison_E8B59246_Out_2);
                                float _Property_40D88250_Out_0 = Vector1_EF774600;
                                float _SimpleNoise_5B537726_Out_2;
                                Unity_SimpleNoise_float(IN.uv0.xy, 100, _SimpleNoise_5B537726_Out_2);
                                float _OneMinus_1FA41B08_Out_1;
                                Unity_OneMinus_float(_Property_41D3B152_Out_0, _OneMinus_1FA41B08_Out_1);
                                float _Step_36A488B1_Out_2;
                                Unity_Step_float(_SimpleNoise_5B537726_Out_2, _OneMinus_1FA41B08_Out_1, _Step_36A488B1_Out_2);
                                float _Multiply_EAFAFAEC_Out_2;
                                Unity_Multiply_float(_Property_40D88250_Out_0, _Step_36A488B1_Out_2, _Multiply_EAFAFAEC_Out_2);
                                float _Add_3516D411_Out_2;
                                Unity_Add_float(_OneMinus_1FA41B08_Out_1, 0.1, _Add_3516D411_Out_2);
                                float _Step_9D0829F0_Out_2;
                                Unity_Step_float(_SimpleNoise_5B537726_Out_2, _Add_3516D411_Out_2, _Step_9D0829F0_Out_2);
                                float _Multiply_E1967D7B_Out_2;
                                Unity_Multiply_float(_Property_40D88250_Out_0, _Step_9D0829F0_Out_2, _Multiply_E1967D7B_Out_2);
                                float _Branch_92037443_Out_3;
                                Unity_Branch_float(_Comparison_E8B59246_Out_2, _Multiply_EAFAFAEC_Out_2, _Multiply_E1967D7B_Out_2, _Branch_92037443_Out_3);
                                float _Subtract_52DE93D2_Out_2;
                                Unity_Subtract_float(_Multiply_E1967D7B_Out_2, _Multiply_EAFAFAEC_Out_2, _Subtract_52DE93D2_Out_2);
                                float4 _Property_A0CC82B_Out_0 = Vector4_4DBD63;
                                float4 _Multiply_51618D24_Out_2;
                                Unity_Multiply_float((_Subtract_52DE93D2_Out_2.xxxx), _Property_A0CC82B_Out_0, _Multiply_51618D24_Out_2);
                                DissolvedAlpha_1 = _Branch_92037443_Out_3;
                                DissolvedColor_2 = _Multiply_51618D24_Out_2;
                            }

                            // Graph Vertex
                            // GraphVertex: <None>

                            // Graph Pixel
                            struct SurfaceDescriptionInputs
                            {
                                float3 TangentSpaceNormal;
                                float4 uv0;
                                float4 VertexColor;
                            };

                            struct SurfaceDescription
                            {
                                float3 Albedo;
                                float Alpha;
                                float AlphaClipThreshold;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _Property_6B778FE2_Out_0 = Dissolve_Progress;
                                float _Comparison_4EC89164_Out_2;
                                Unity_Comparison_Equal_float(_Property_6B778FE2_Out_0, 0, _Comparison_4EC89164_Out_2);
                                float _Property_AABC97FA_Out_0 = Outline;
                                float4 _SampleTexture2D_8051FBC3_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                float _SampleTexture2D_8051FBC3_R_4 = _SampleTexture2D_8051FBC3_RGBA_0.r;
                                float _SampleTexture2D_8051FBC3_G_5 = _SampleTexture2D_8051FBC3_RGBA_0.g;
                                float _SampleTexture2D_8051FBC3_B_6 = _SampleTexture2D_8051FBC3_RGBA_0.b;
                                float _SampleTexture2D_8051FBC3_A_7 = _SampleTexture2D_8051FBC3_RGBA_0.a;
                                float4 _Multiply_B4A66C10_Out_2;
                                Unity_Multiply_float(IN.VertexColor, _SampleTexture2D_8051FBC3_RGBA_0, _Multiply_B4A66C10_Out_2);
                                float _Property_877A111A_Out_0 = Outline_Thickness;
                                float4 _Property_2A7725AB_Out_0 = Outline_Color;
                                Bindings_OutlineSub_608d64742e5c8034387f3c815a335e7f _OutlineSub_F7A72801;
                                _OutlineSub_F7A72801.uv0 = IN.uv0;
                                float4 _OutlineSub_F7A72801_Color_0;
                                SG_OutlineSub_608d64742e5c8034387f3c815a335e7f(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), _MainTex_TexelSize, _Property_877A111A_Out_0, _Property_2A7725AB_Out_0, _OutlineSub_F7A72801, _OutlineSub_F7A72801_Color_0);
                                float4 _Add_6CCBA0EE_Out_2;
                                Unity_Add_float4(_Multiply_B4A66C10_Out_2, _OutlineSub_F7A72801_Color_0, _Add_6CCBA0EE_Out_2);
                                float4 _Branch_9DA8DF8_Out_3;
                                Unity_Branch_float4(_Property_AABC97FA_Out_0, _Add_6CCBA0EE_Out_2, _Multiply_B4A66C10_Out_2, _Branch_9DA8DF8_Out_3);
                                float _Split_3586B177_R_1 = _Branch_9DA8DF8_Out_3[0];
                                float _Split_3586B177_G_2 = _Branch_9DA8DF8_Out_3[1];
                                float _Split_3586B177_B_3 = _Branch_9DA8DF8_Out_3[2];
                                float _Split_3586B177_A_4 = _Branch_9DA8DF8_Out_3[3];
                                float _Property_96D859E1_Out_0 = Dissolve_Progress;
                                float4 _Property_ECC6743E_Out_0 = Dissolve_Color;
                                Bindings_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f _DissolveSub_D2F824E7;
                                _DissolveSub_D2F824E7.uv0 = IN.uv0;
                                float _DissolveSub_D2F824E7_DissolvedAlpha_1;
                                float4 _DissolveSub_D2F824E7_DissolvedColor_2;
                                SG_DissolveSub_a59f3d9efbb2d8b43b64709db4ffcf4f(_Split_3586B177_A_4, _Property_96D859E1_Out_0, _Property_ECC6743E_Out_0, _DissolveSub_D2F824E7, _DissolveSub_D2F824E7_DissolvedAlpha_1, _DissolveSub_D2F824E7_DissolvedColor_2);
                                float4 _Add_35D8B386_Out_2;
                                Unity_Add_float4(_Branch_9DA8DF8_Out_3, _DissolveSub_D2F824E7_DissolvedColor_2, _Add_35D8B386_Out_2);
                                float4 _Branch_8686AB9C_Out_3;
                                Unity_Branch_float4(_Comparison_4EC89164_Out_2, _Branch_9DA8DF8_Out_3, _Add_35D8B386_Out_2, _Branch_8686AB9C_Out_3);
                                surface.Albedo = (_Branch_8686AB9C_Out_3.xyz);
                                surface.Alpha = _DissolveSub_D2F824E7_DissolvedAlpha_1;
                                surface.AlphaClipThreshold = 0.5;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Structs and Packing

                            // Generated Type: Attributes
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

                            // Generated Type: Varyings
                            struct Varyings
                            {
                                float4 positionCS : SV_POSITION;
                                float4 texCoord0;
                                float4 color;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            // Generated Type: PackedVaryings
                            struct PackedVaryings
                            {
                                float4 positionCS : SV_POSITION;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                float4 interp00 : TEXCOORD0;
                                float4 interp01 : TEXCOORD1;
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            // Packed Type: Varyings
                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output = (PackedVaryings)0;
                                output.positionCS = input.positionCS;
                                output.interp00.xyzw = input.texCoord0;
                                output.interp01.xyzw = input.color;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            // Unpacked Type: Varyings
                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output = (Varyings)0;
                                output.positionCS = input.positionCS;
                                output.texCoord0 = input.interp00.xyzw;
                                output.color = input.interp01.xyzw;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs

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

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                            ENDHLSL
                        }

        }
            CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
                                FallBack "Hidden/Shader Graph/FallbackError"
}
