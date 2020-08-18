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
    }
        SubShader
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
                "Queue" = "Geometry+0"
            }

            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }

            // Render State
            Blend One Zero, One Zero
            Cull Off
            ZTest LEqual
            ZWrite On
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
            #define _AlphaClip 1
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
            #pragma multi_compile_instancing
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
            float4 RimColor;
            float2 Vector2_AB971143;
            float Vector1_52D24AB4;
            float Vector1_36BC0FD6;
            float Vector1_3AEF5FB5;
            float Vector1_7AA64B76;
            CBUFFER_END
            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
            TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex); float4 _MaskTex_TexelSize;
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap); float4 _NormalMap_TexelSize;
            SAMPLER(_SampleTexture2D_C96E94F2_Sampler_3_Linear_Repeat);

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
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
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
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 WorldSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 WorldSpaceTangent;
                float3 ObjectSpaceBiTangent;
                float3 WorldSpaceBiTangent;
                float3 AbsoluteWorldSpacePosition;
                float4 uv0;
                float3 TimeParameters;
            };

            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float4 _UV_D7B50B15_Out_0 = IN.uv0;
                float _Split_8531AB0A_R_1 = _UV_D7B50B15_Out_0[0];
                float _Split_8531AB0A_G_2 = _UV_D7B50B15_Out_0[1];
                float _Split_8531AB0A_B_3 = _UV_D7B50B15_Out_0[2];
                float _Split_8531AB0A_A_4 = _UV_D7B50B15_Out_0[3];
                float _Absolute_7380A83F_Out_1;
                Unity_Absolute_float(_Split_8531AB0A_G_2, _Absolute_7380A83F_Out_1);
                float _Property_662546E5_Out_0 = Vector1_7AA64B76;
                float _Power_B71166DE_Out_2;
                Unity_Power_float(_Absolute_7380A83F_Out_1, _Property_662546E5_Out_0, _Power_B71166DE_Out_2);
                float _Clamp_E1D4DAAC_Out_3;
                Unity_Clamp_float(_Power_B71166DE_Out_2, 0, 1, _Clamp_E1D4DAAC_Out_3);
                float _Split_2009256D_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_2009256D_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_2009256D_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_2009256D_A_4 = 0;
                float2 _Vector2_CC34729D_Out_0 = float2(_Split_2009256D_R_1, _Split_2009256D_G_2);
                float _Property_9E14CE56_Out_0 = Vector1_3AEF5FB5;
                float _Multiply_345227B7_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_9E14CE56_Out_0, _Multiply_345227B7_Out_2);
                float2 _Property_327BCBBA_Out_0 = Vector2_AB971143;
                float2 _Multiply_AF73FD34_Out_2;
                Unity_Multiply_float((_Multiply_345227B7_Out_2.xx), _Property_327BCBBA_Out_0, _Multiply_AF73FD34_Out_2);
                float2 _TilingAndOffset_F9992348_Out_3;
                Unity_TilingAndOffset_float(_Vector2_CC34729D_Out_0, float2 (1, 1), _Multiply_AF73FD34_Out_2, _TilingAndOffset_F9992348_Out_3);
                float _Property_5FB49BF2_Out_0 = Vector1_52D24AB4;
                float _GradientNoise_38A389D_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_F9992348_Out_3, _Property_5FB49BF2_Out_0, _GradientNoise_38A389D_Out_2);
                float _Add_4D83CB4A_Out_2;
                Unity_Add_float(_GradientNoise_38A389D_Out_2, -0.5, _Add_4D83CB4A_Out_2);
                float _Property_15B8DDD8_Out_0 = Vector1_36BC0FD6;
                float _Multiply_79477563_Out_2;
                Unity_Multiply_float(_Add_4D83CB4A_Out_2, _Property_15B8DDD8_Out_0, _Multiply_79477563_Out_2);
                float2 _Property_990C9E3C_Out_0 = Vector2_AB971143;
                float2 _Multiply_4B3FCBD_Out_2;
                Unity_Multiply_float((_Multiply_79477563_Out_2.xx), _Property_990C9E3C_Out_0, _Multiply_4B3FCBD_Out_2);
                float2 _Multiply_60657008_Out_2;
                Unity_Multiply_float((_Clamp_E1D4DAAC_Out_3.xx), _Multiply_4B3FCBD_Out_2, _Multiply_60657008_Out_2);
                float _Split_9E78B1A2_R_1 = _Multiply_60657008_Out_2[0];
                float _Split_9E78B1A2_G_2 = _Multiply_60657008_Out_2[1];
                float _Split_9E78B1A2_B_3 = 0;
                float _Split_9E78B1A2_A_4 = 0;
                float3 _Vector3_38BD9621_Out_0 = float3(_Split_9E78B1A2_R_1, _Split_9E78B1A2_G_2, 0);
                float3 _Add_FDF7547E_Out_2;
                Unity_Add_float3(_Vector3_38BD9621_Out_0, IN.AbsoluteWorldSpacePosition, _Add_FDF7547E_Out_2);
                float3 _Transform_D353B0C2_Out_1 = TransformWorldToObject(_Add_FDF7547E_Out_2.xyz);
                description.VertexPosition = _Transform_D353B0C2_Out_1;
                description.VertexNormal = IN.ObjectSpaceNormal;
                description.VertexTangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float4 uv0;
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
                float4 _SampleTexture2D_C96E94F2_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                float _SampleTexture2D_C96E94F2_R_4 = _SampleTexture2D_C96E94F2_RGBA_0.r;
                float _SampleTexture2D_C96E94F2_G_5 = _SampleTexture2D_C96E94F2_RGBA_0.g;
                float _SampleTexture2D_C96E94F2_B_6 = _SampleTexture2D_C96E94F2_RGBA_0.b;
                float _SampleTexture2D_C96E94F2_A_7 = _SampleTexture2D_C96E94F2_RGBA_0.a;
                float4 _Add_3C3A7912_Out_2;
                Unity_Add_float4(_SampleTexture2D_C96E94F2_RGBA_0, float4(0, 0, 0, 0), _Add_3C3A7912_Out_2);
                float _Split_24F15CEB_R_1 = _Add_3C3A7912_Out_2[0];
                float _Split_24F15CEB_G_2 = _Add_3C3A7912_Out_2[1];
                float _Split_24F15CEB_B_3 = _Add_3C3A7912_Out_2[2];
                float _Split_24F15CEB_A_4 = _Add_3C3A7912_Out_2[3];
                float _Preview_737C03B4_Out_1;
                Unity_Preview_float(_SampleTexture2D_C96E94F2_A_7, _Preview_737C03B4_Out_1);
                float4 _Combine_2F284CDB_RGBA_4;
                float3 _Combine_2F284CDB_RGB_5;
                float2 _Combine_2F284CDB_RG_6;
                Unity_Combine_float(_Split_24F15CEB_R_1, _Split_24F15CEB_G_2, _Split_24F15CEB_B_3, _Preview_737C03B4_Out_1, _Combine_2F284CDB_RGBA_4, _Combine_2F284CDB_RGB_5, _Combine_2F284CDB_RG_6);
                float _Split_9831879D_R_1 = _Combine_2F284CDB_RGBA_4[0];
                float _Split_9831879D_G_2 = _Combine_2F284CDB_RGBA_4[1];
                float _Split_9831879D_B_3 = _Combine_2F284CDB_RGBA_4[2];
                float _Split_9831879D_A_4 = _Combine_2F284CDB_RGBA_4[3];
                surface.Albedo = (_Combine_2F284CDB_RGBA_4.xyz);
                surface.Normal = IN.TangentSpaceNormal;
                surface.Emission = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = _Split_9831879D_A_4;
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
                float3 interp04 : TEXCOORD4;
                float2 interp05 : TEXCOORD5;
                float3 interp06 : TEXCOORD6;
                float4 interp07 : TEXCOORD7;
                float4 interp08 : TEXCOORD8;
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
                output.interp04.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp05.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp06.xyz = input.sh;
                #endif
                output.interp07.xyzw = input.fogFactorAndVertexLight;
                output.interp08.xyzw = input.shadowCoord;
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
                output.viewDirectionWS = input.interp04.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp05.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp06.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp07.xyzw;
                output.shadowCoord = input.interp08.xyzw;
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
                Blend One Zero, One Zero
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
                #define _AlphaClip 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                #pragma multi_compile_instancing
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
                float4 RimColor;
                float2 Vector2_AB971143;
                float Vector1_52D24AB4;
                float Vector1_36BC0FD6;
                float Vector1_3AEF5FB5;
                float Vector1_7AA64B76;
                CBUFFER_END
                TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex); float4 _MaskTex_TexelSize;
                TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap); float4 _NormalMap_TexelSize;
                SAMPLER(_SampleTexture2D_C96E94F2_Sampler_3_Linear_Repeat);

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
                    float x = (34 * p.x + 1) * p.x % 289 + p.y;
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
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 AbsoluteWorldSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };

                struct VertexDescription
                {
                    float3 VertexPosition;
                    float3 VertexNormal;
                    float3 VertexTangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float4 _UV_D7B50B15_Out_0 = IN.uv0;
                    float _Split_8531AB0A_R_1 = _UV_D7B50B15_Out_0[0];
                    float _Split_8531AB0A_G_2 = _UV_D7B50B15_Out_0[1];
                    float _Split_8531AB0A_B_3 = _UV_D7B50B15_Out_0[2];
                    float _Split_8531AB0A_A_4 = _UV_D7B50B15_Out_0[3];
                    float _Absolute_7380A83F_Out_1;
                    Unity_Absolute_float(_Split_8531AB0A_G_2, _Absolute_7380A83F_Out_1);
                    float _Property_662546E5_Out_0 = Vector1_7AA64B76;
                    float _Power_B71166DE_Out_2;
                    Unity_Power_float(_Absolute_7380A83F_Out_1, _Property_662546E5_Out_0, _Power_B71166DE_Out_2);
                    float _Clamp_E1D4DAAC_Out_3;
                    Unity_Clamp_float(_Power_B71166DE_Out_2, 0, 1, _Clamp_E1D4DAAC_Out_3);
                    float _Split_2009256D_R_1 = IN.AbsoluteWorldSpacePosition[0];
                    float _Split_2009256D_G_2 = IN.AbsoluteWorldSpacePosition[1];
                    float _Split_2009256D_B_3 = IN.AbsoluteWorldSpacePosition[2];
                    float _Split_2009256D_A_4 = 0;
                    float2 _Vector2_CC34729D_Out_0 = float2(_Split_2009256D_R_1, _Split_2009256D_G_2);
                    float _Property_9E14CE56_Out_0 = Vector1_3AEF5FB5;
                    float _Multiply_345227B7_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_9E14CE56_Out_0, _Multiply_345227B7_Out_2);
                    float2 _Property_327BCBBA_Out_0 = Vector2_AB971143;
                    float2 _Multiply_AF73FD34_Out_2;
                    Unity_Multiply_float((_Multiply_345227B7_Out_2.xx), _Property_327BCBBA_Out_0, _Multiply_AF73FD34_Out_2);
                    float2 _TilingAndOffset_F9992348_Out_3;
                    Unity_TilingAndOffset_float(_Vector2_CC34729D_Out_0, float2 (1, 1), _Multiply_AF73FD34_Out_2, _TilingAndOffset_F9992348_Out_3);
                    float _Property_5FB49BF2_Out_0 = Vector1_52D24AB4;
                    float _GradientNoise_38A389D_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_F9992348_Out_3, _Property_5FB49BF2_Out_0, _GradientNoise_38A389D_Out_2);
                    float _Add_4D83CB4A_Out_2;
                    Unity_Add_float(_GradientNoise_38A389D_Out_2, -0.5, _Add_4D83CB4A_Out_2);
                    float _Property_15B8DDD8_Out_0 = Vector1_36BC0FD6;
                    float _Multiply_79477563_Out_2;
                    Unity_Multiply_float(_Add_4D83CB4A_Out_2, _Property_15B8DDD8_Out_0, _Multiply_79477563_Out_2);
                    float2 _Property_990C9E3C_Out_0 = Vector2_AB971143;
                    float2 _Multiply_4B3FCBD_Out_2;
                    Unity_Multiply_float((_Multiply_79477563_Out_2.xx), _Property_990C9E3C_Out_0, _Multiply_4B3FCBD_Out_2);
                    float2 _Multiply_60657008_Out_2;
                    Unity_Multiply_float((_Clamp_E1D4DAAC_Out_3.xx), _Multiply_4B3FCBD_Out_2, _Multiply_60657008_Out_2);
                    float _Split_9E78B1A2_R_1 = _Multiply_60657008_Out_2[0];
                    float _Split_9E78B1A2_G_2 = _Multiply_60657008_Out_2[1];
                    float _Split_9E78B1A2_B_3 = 0;
                    float _Split_9E78B1A2_A_4 = 0;
                    float3 _Vector3_38BD9621_Out_0 = float3(_Split_9E78B1A2_R_1, _Split_9E78B1A2_G_2, 0);
                    float3 _Add_FDF7547E_Out_2;
                    Unity_Add_float3(_Vector3_38BD9621_Out_0, IN.AbsoluteWorldSpacePosition, _Add_FDF7547E_Out_2);
                    float3 _Transform_D353B0C2_Out_1 = TransformWorldToObject(_Add_FDF7547E_Out_2.xyz);
                    description.VertexPosition = _Transform_D353B0C2_Out_1;
                    description.VertexNormal = IN.ObjectSpaceNormal;
                    description.VertexTangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Graph Pixel
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float4 uv0;
                };

                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _SampleTexture2D_C96E94F2_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                    float _SampleTexture2D_C96E94F2_R_4 = _SampleTexture2D_C96E94F2_RGBA_0.r;
                    float _SampleTexture2D_C96E94F2_G_5 = _SampleTexture2D_C96E94F2_RGBA_0.g;
                    float _SampleTexture2D_C96E94F2_B_6 = _SampleTexture2D_C96E94F2_RGBA_0.b;
                    float _SampleTexture2D_C96E94F2_A_7 = _SampleTexture2D_C96E94F2_RGBA_0.a;
                    float4 _Add_3C3A7912_Out_2;
                    Unity_Add_float4(_SampleTexture2D_C96E94F2_RGBA_0, float4(0, 0, 0, 0), _Add_3C3A7912_Out_2);
                    float _Split_24F15CEB_R_1 = _Add_3C3A7912_Out_2[0];
                    float _Split_24F15CEB_G_2 = _Add_3C3A7912_Out_2[1];
                    float _Split_24F15CEB_B_3 = _Add_3C3A7912_Out_2[2];
                    float _Split_24F15CEB_A_4 = _Add_3C3A7912_Out_2[3];
                    float _Preview_737C03B4_Out_1;
                    Unity_Preview_float(_SampleTexture2D_C96E94F2_A_7, _Preview_737C03B4_Out_1);
                    float4 _Combine_2F284CDB_RGBA_4;
                    float3 _Combine_2F284CDB_RGB_5;
                    float2 _Combine_2F284CDB_RG_6;
                    Unity_Combine_float(_Split_24F15CEB_R_1, _Split_24F15CEB_G_2, _Split_24F15CEB_B_3, _Preview_737C03B4_Out_1, _Combine_2F284CDB_RGBA_4, _Combine_2F284CDB_RGB_5, _Combine_2F284CDB_RG_6);
                    float _Split_9831879D_R_1 = _Combine_2F284CDB_RGBA_4[0];
                    float _Split_9831879D_G_2 = _Combine_2F284CDB_RGBA_4[1];
                    float _Split_9831879D_B_3 = _Combine_2F284CDB_RGBA_4[2];
                    float _Split_9831879D_A_4 = _Combine_2F284CDB_RGBA_4[3];
                    surface.Alpha = _Split_9831879D_A_4;
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
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };

                // Generated Type: Varyings
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float4 texCoord0;
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
                    Blend One Zero, One Zero
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
                    #define _AlphaClip 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define ATTRIBUTES_NEED_TEXCOORD0
                    #define VARYINGS_NEED_TEXCOORD0
                    #define FEATURES_GRAPH_VERTEX
                    #pragma multi_compile_instancing
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
                    float4 RimColor;
                    float2 Vector2_AB971143;
                    float Vector1_52D24AB4;
                    float Vector1_36BC0FD6;
                    float Vector1_3AEF5FB5;
                    float Vector1_7AA64B76;
                    CBUFFER_END
                    TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                    TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex); float4 _MaskTex_TexelSize;
                    TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap); float4 _NormalMap_TexelSize;
                    SAMPLER(_SampleTexture2D_C96E94F2_Sampler_3_Linear_Repeat);

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
                        float x = (34 * p.x + 1) * p.x % 289 + p.y;
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
                    struct VertexDescriptionInputs
                    {
                        float3 ObjectSpaceNormal;
                        float3 WorldSpaceNormal;
                        float3 ObjectSpaceTangent;
                        float3 WorldSpaceTangent;
                        float3 ObjectSpaceBiTangent;
                        float3 WorldSpaceBiTangent;
                        float3 AbsoluteWorldSpacePosition;
                        float4 uv0;
                        float3 TimeParameters;
                    };

                    struct VertexDescription
                    {
                        float3 VertexPosition;
                        float3 VertexNormal;
                        float3 VertexTangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float4 _UV_D7B50B15_Out_0 = IN.uv0;
                        float _Split_8531AB0A_R_1 = _UV_D7B50B15_Out_0[0];
                        float _Split_8531AB0A_G_2 = _UV_D7B50B15_Out_0[1];
                        float _Split_8531AB0A_B_3 = _UV_D7B50B15_Out_0[2];
                        float _Split_8531AB0A_A_4 = _UV_D7B50B15_Out_0[3];
                        float _Absolute_7380A83F_Out_1;
                        Unity_Absolute_float(_Split_8531AB0A_G_2, _Absolute_7380A83F_Out_1);
                        float _Property_662546E5_Out_0 = Vector1_7AA64B76;
                        float _Power_B71166DE_Out_2;
                        Unity_Power_float(_Absolute_7380A83F_Out_1, _Property_662546E5_Out_0, _Power_B71166DE_Out_2);
                        float _Clamp_E1D4DAAC_Out_3;
                        Unity_Clamp_float(_Power_B71166DE_Out_2, 0, 1, _Clamp_E1D4DAAC_Out_3);
                        float _Split_2009256D_R_1 = IN.AbsoluteWorldSpacePosition[0];
                        float _Split_2009256D_G_2 = IN.AbsoluteWorldSpacePosition[1];
                        float _Split_2009256D_B_3 = IN.AbsoluteWorldSpacePosition[2];
                        float _Split_2009256D_A_4 = 0;
                        float2 _Vector2_CC34729D_Out_0 = float2(_Split_2009256D_R_1, _Split_2009256D_G_2);
                        float _Property_9E14CE56_Out_0 = Vector1_3AEF5FB5;
                        float _Multiply_345227B7_Out_2;
                        Unity_Multiply_float(IN.TimeParameters.x, _Property_9E14CE56_Out_0, _Multiply_345227B7_Out_2);
                        float2 _Property_327BCBBA_Out_0 = Vector2_AB971143;
                        float2 _Multiply_AF73FD34_Out_2;
                        Unity_Multiply_float((_Multiply_345227B7_Out_2.xx), _Property_327BCBBA_Out_0, _Multiply_AF73FD34_Out_2);
                        float2 _TilingAndOffset_F9992348_Out_3;
                        Unity_TilingAndOffset_float(_Vector2_CC34729D_Out_0, float2 (1, 1), _Multiply_AF73FD34_Out_2, _TilingAndOffset_F9992348_Out_3);
                        float _Property_5FB49BF2_Out_0 = Vector1_52D24AB4;
                        float _GradientNoise_38A389D_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_F9992348_Out_3, _Property_5FB49BF2_Out_0, _GradientNoise_38A389D_Out_2);
                        float _Add_4D83CB4A_Out_2;
                        Unity_Add_float(_GradientNoise_38A389D_Out_2, -0.5, _Add_4D83CB4A_Out_2);
                        float _Property_15B8DDD8_Out_0 = Vector1_36BC0FD6;
                        float _Multiply_79477563_Out_2;
                        Unity_Multiply_float(_Add_4D83CB4A_Out_2, _Property_15B8DDD8_Out_0, _Multiply_79477563_Out_2);
                        float2 _Property_990C9E3C_Out_0 = Vector2_AB971143;
                        float2 _Multiply_4B3FCBD_Out_2;
                        Unity_Multiply_float((_Multiply_79477563_Out_2.xx), _Property_990C9E3C_Out_0, _Multiply_4B3FCBD_Out_2);
                        float2 _Multiply_60657008_Out_2;
                        Unity_Multiply_float((_Clamp_E1D4DAAC_Out_3.xx), _Multiply_4B3FCBD_Out_2, _Multiply_60657008_Out_2);
                        float _Split_9E78B1A2_R_1 = _Multiply_60657008_Out_2[0];
                        float _Split_9E78B1A2_G_2 = _Multiply_60657008_Out_2[1];
                        float _Split_9E78B1A2_B_3 = 0;
                        float _Split_9E78B1A2_A_4 = 0;
                        float3 _Vector3_38BD9621_Out_0 = float3(_Split_9E78B1A2_R_1, _Split_9E78B1A2_G_2, 0);
                        float3 _Add_FDF7547E_Out_2;
                        Unity_Add_float3(_Vector3_38BD9621_Out_0, IN.AbsoluteWorldSpacePosition, _Add_FDF7547E_Out_2);
                        float3 _Transform_D353B0C2_Out_1 = TransformWorldToObject(_Add_FDF7547E_Out_2.xyz);
                        description.VertexPosition = _Transform_D353B0C2_Out_1;
                        description.VertexNormal = IN.ObjectSpaceNormal;
                        description.VertexTangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Graph Pixel
                    struct SurfaceDescriptionInputs
                    {
                        float3 TangentSpaceNormal;
                        float4 uv0;
                    };

                    struct SurfaceDescription
                    {
                        float Alpha;
                        float AlphaClipThreshold;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float4 _SampleTexture2D_C96E94F2_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                        float _SampleTexture2D_C96E94F2_R_4 = _SampleTexture2D_C96E94F2_RGBA_0.r;
                        float _SampleTexture2D_C96E94F2_G_5 = _SampleTexture2D_C96E94F2_RGBA_0.g;
                        float _SampleTexture2D_C96E94F2_B_6 = _SampleTexture2D_C96E94F2_RGBA_0.b;
                        float _SampleTexture2D_C96E94F2_A_7 = _SampleTexture2D_C96E94F2_RGBA_0.a;
                        float4 _Add_3C3A7912_Out_2;
                        Unity_Add_float4(_SampleTexture2D_C96E94F2_RGBA_0, float4(0, 0, 0, 0), _Add_3C3A7912_Out_2);
                        float _Split_24F15CEB_R_1 = _Add_3C3A7912_Out_2[0];
                        float _Split_24F15CEB_G_2 = _Add_3C3A7912_Out_2[1];
                        float _Split_24F15CEB_B_3 = _Add_3C3A7912_Out_2[2];
                        float _Split_24F15CEB_A_4 = _Add_3C3A7912_Out_2[3];
                        float _Preview_737C03B4_Out_1;
                        Unity_Preview_float(_SampleTexture2D_C96E94F2_A_7, _Preview_737C03B4_Out_1);
                        float4 _Combine_2F284CDB_RGBA_4;
                        float3 _Combine_2F284CDB_RGB_5;
                        float2 _Combine_2F284CDB_RG_6;
                        Unity_Combine_float(_Split_24F15CEB_R_1, _Split_24F15CEB_G_2, _Split_24F15CEB_B_3, _Preview_737C03B4_Out_1, _Combine_2F284CDB_RGBA_4, _Combine_2F284CDB_RGB_5, _Combine_2F284CDB_RG_6);
                        float _Split_9831879D_R_1 = _Combine_2F284CDB_RGBA_4[0];
                        float _Split_9831879D_G_2 = _Combine_2F284CDB_RGBA_4[1];
                        float _Split_9831879D_B_3 = _Combine_2F284CDB_RGBA_4[2];
                        float _Split_9831879D_A_4 = _Combine_2F284CDB_RGBA_4[3];
                        surface.Alpha = _Split_9831879D_A_4;
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
                        #if UNITY_ANY_INSTANCING_ENABLED
                        uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };

                    // Generated Type: Varyings
                    struct Varyings
                    {
                        float4 positionCS : SV_POSITION;
                        float4 texCoord0;
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
                        Blend One Zero, One Zero
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
                        #define _AlphaClip 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define ATTRIBUTES_NEED_TEXCOORD2
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        #pragma multi_compile_instancing
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
                        float4 RimColor;
                        float2 Vector2_AB971143;
                        float Vector1_52D24AB4;
                        float Vector1_36BC0FD6;
                        float Vector1_3AEF5FB5;
                        float Vector1_7AA64B76;
                        CBUFFER_END
                        TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                        TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex); float4 _MaskTex_TexelSize;
                        TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap); float4 _NormalMap_TexelSize;
                        SAMPLER(_SampleTexture2D_C96E94F2_Sampler_3_Linear_Repeat);

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
                            float x = (34 * p.x + 1) * p.x % 289 + p.y;
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
                        struct VertexDescriptionInputs
                        {
                            float3 ObjectSpaceNormal;
                            float3 WorldSpaceNormal;
                            float3 ObjectSpaceTangent;
                            float3 WorldSpaceTangent;
                            float3 ObjectSpaceBiTangent;
                            float3 WorldSpaceBiTangent;
                            float3 AbsoluteWorldSpacePosition;
                            float4 uv0;
                            float3 TimeParameters;
                        };

                        struct VertexDescription
                        {
                            float3 VertexPosition;
                            float3 VertexNormal;
                            float3 VertexTangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            float4 _UV_D7B50B15_Out_0 = IN.uv0;
                            float _Split_8531AB0A_R_1 = _UV_D7B50B15_Out_0[0];
                            float _Split_8531AB0A_G_2 = _UV_D7B50B15_Out_0[1];
                            float _Split_8531AB0A_B_3 = _UV_D7B50B15_Out_0[2];
                            float _Split_8531AB0A_A_4 = _UV_D7B50B15_Out_0[3];
                            float _Absolute_7380A83F_Out_1;
                            Unity_Absolute_float(_Split_8531AB0A_G_2, _Absolute_7380A83F_Out_1);
                            float _Property_662546E5_Out_0 = Vector1_7AA64B76;
                            float _Power_B71166DE_Out_2;
                            Unity_Power_float(_Absolute_7380A83F_Out_1, _Property_662546E5_Out_0, _Power_B71166DE_Out_2);
                            float _Clamp_E1D4DAAC_Out_3;
                            Unity_Clamp_float(_Power_B71166DE_Out_2, 0, 1, _Clamp_E1D4DAAC_Out_3);
                            float _Split_2009256D_R_1 = IN.AbsoluteWorldSpacePosition[0];
                            float _Split_2009256D_G_2 = IN.AbsoluteWorldSpacePosition[1];
                            float _Split_2009256D_B_3 = IN.AbsoluteWorldSpacePosition[2];
                            float _Split_2009256D_A_4 = 0;
                            float2 _Vector2_CC34729D_Out_0 = float2(_Split_2009256D_R_1, _Split_2009256D_G_2);
                            float _Property_9E14CE56_Out_0 = Vector1_3AEF5FB5;
                            float _Multiply_345227B7_Out_2;
                            Unity_Multiply_float(IN.TimeParameters.x, _Property_9E14CE56_Out_0, _Multiply_345227B7_Out_2);
                            float2 _Property_327BCBBA_Out_0 = Vector2_AB971143;
                            float2 _Multiply_AF73FD34_Out_2;
                            Unity_Multiply_float((_Multiply_345227B7_Out_2.xx), _Property_327BCBBA_Out_0, _Multiply_AF73FD34_Out_2);
                            float2 _TilingAndOffset_F9992348_Out_3;
                            Unity_TilingAndOffset_float(_Vector2_CC34729D_Out_0, float2 (1, 1), _Multiply_AF73FD34_Out_2, _TilingAndOffset_F9992348_Out_3);
                            float _Property_5FB49BF2_Out_0 = Vector1_52D24AB4;
                            float _GradientNoise_38A389D_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_F9992348_Out_3, _Property_5FB49BF2_Out_0, _GradientNoise_38A389D_Out_2);
                            float _Add_4D83CB4A_Out_2;
                            Unity_Add_float(_GradientNoise_38A389D_Out_2, -0.5, _Add_4D83CB4A_Out_2);
                            float _Property_15B8DDD8_Out_0 = Vector1_36BC0FD6;
                            float _Multiply_79477563_Out_2;
                            Unity_Multiply_float(_Add_4D83CB4A_Out_2, _Property_15B8DDD8_Out_0, _Multiply_79477563_Out_2);
                            float2 _Property_990C9E3C_Out_0 = Vector2_AB971143;
                            float2 _Multiply_4B3FCBD_Out_2;
                            Unity_Multiply_float((_Multiply_79477563_Out_2.xx), _Property_990C9E3C_Out_0, _Multiply_4B3FCBD_Out_2);
                            float2 _Multiply_60657008_Out_2;
                            Unity_Multiply_float((_Clamp_E1D4DAAC_Out_3.xx), _Multiply_4B3FCBD_Out_2, _Multiply_60657008_Out_2);
                            float _Split_9E78B1A2_R_1 = _Multiply_60657008_Out_2[0];
                            float _Split_9E78B1A2_G_2 = _Multiply_60657008_Out_2[1];
                            float _Split_9E78B1A2_B_3 = 0;
                            float _Split_9E78B1A2_A_4 = 0;
                            float3 _Vector3_38BD9621_Out_0 = float3(_Split_9E78B1A2_R_1, _Split_9E78B1A2_G_2, 0);
                            float3 _Add_FDF7547E_Out_2;
                            Unity_Add_float3(_Vector3_38BD9621_Out_0, IN.AbsoluteWorldSpacePosition, _Add_FDF7547E_Out_2);
                            float3 _Transform_D353B0C2_Out_1 = TransformWorldToObject(_Add_FDF7547E_Out_2.xyz);
                            description.VertexPosition = _Transform_D353B0C2_Out_1;
                            description.VertexNormal = IN.ObjectSpaceNormal;
                            description.VertexTangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Graph Pixel
                        struct SurfaceDescriptionInputs
                        {
                            float3 TangentSpaceNormal;
                            float4 uv0;
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
                            float4 _SampleTexture2D_C96E94F2_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                            float _SampleTexture2D_C96E94F2_R_4 = _SampleTexture2D_C96E94F2_RGBA_0.r;
                            float _SampleTexture2D_C96E94F2_G_5 = _SampleTexture2D_C96E94F2_RGBA_0.g;
                            float _SampleTexture2D_C96E94F2_B_6 = _SampleTexture2D_C96E94F2_RGBA_0.b;
                            float _SampleTexture2D_C96E94F2_A_7 = _SampleTexture2D_C96E94F2_RGBA_0.a;
                            float4 _Add_3C3A7912_Out_2;
                            Unity_Add_float4(_SampleTexture2D_C96E94F2_RGBA_0, float4(0, 0, 0, 0), _Add_3C3A7912_Out_2);
                            float _Split_24F15CEB_R_1 = _Add_3C3A7912_Out_2[0];
                            float _Split_24F15CEB_G_2 = _Add_3C3A7912_Out_2[1];
                            float _Split_24F15CEB_B_3 = _Add_3C3A7912_Out_2[2];
                            float _Split_24F15CEB_A_4 = _Add_3C3A7912_Out_2[3];
                            float _Preview_737C03B4_Out_1;
                            Unity_Preview_float(_SampleTexture2D_C96E94F2_A_7, _Preview_737C03B4_Out_1);
                            float4 _Combine_2F284CDB_RGBA_4;
                            float3 _Combine_2F284CDB_RGB_5;
                            float2 _Combine_2F284CDB_RG_6;
                            Unity_Combine_float(_Split_24F15CEB_R_1, _Split_24F15CEB_G_2, _Split_24F15CEB_B_3, _Preview_737C03B4_Out_1, _Combine_2F284CDB_RGBA_4, _Combine_2F284CDB_RGB_5, _Combine_2F284CDB_RG_6);
                            float _Split_9831879D_R_1 = _Combine_2F284CDB_RGBA_4[0];
                            float _Split_9831879D_G_2 = _Combine_2F284CDB_RGBA_4[1];
                            float _Split_9831879D_B_3 = _Combine_2F284CDB_RGBA_4[2];
                            float _Split_9831879D_A_4 = _Combine_2F284CDB_RGBA_4[3];
                            surface.Albedo = (_Combine_2F284CDB_RGBA_4.xyz);
                            surface.Emission = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                            surface.Alpha = _Split_9831879D_A_4;
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
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };

                        // Generated Type: Varyings
                        struct Varyings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 texCoord0;
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
                            Blend One Zero, One Zero
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
                            #define _AlphaClip 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD0
                            #define VARYINGS_NEED_TEXCOORD0
                            #define FEATURES_GRAPH_VERTEX
                            #pragma multi_compile_instancing
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
                            float4 RimColor;
                            float2 Vector2_AB971143;
                            float Vector1_52D24AB4;
                            float Vector1_36BC0FD6;
                            float Vector1_3AEF5FB5;
                            float Vector1_7AA64B76;
                            CBUFFER_END
                            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_TexelSize;
                            TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex); float4 _MaskTex_TexelSize;
                            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap); float4 _NormalMap_TexelSize;
                            SAMPLER(_SampleTexture2D_C96E94F2_Sampler_3_Linear_Repeat);

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
                                float x = (34 * p.x + 1) * p.x % 289 + p.y;
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
                            struct VertexDescriptionInputs
                            {
                                float3 ObjectSpaceNormal;
                                float3 WorldSpaceNormal;
                                float3 ObjectSpaceTangent;
                                float3 WorldSpaceTangent;
                                float3 ObjectSpaceBiTangent;
                                float3 WorldSpaceBiTangent;
                                float3 AbsoluteWorldSpacePosition;
                                float4 uv0;
                                float3 TimeParameters;
                            };

                            struct VertexDescription
                            {
                                float3 VertexPosition;
                                float3 VertexNormal;
                                float3 VertexTangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float4 _UV_D7B50B15_Out_0 = IN.uv0;
                                float _Split_8531AB0A_R_1 = _UV_D7B50B15_Out_0[0];
                                float _Split_8531AB0A_G_2 = _UV_D7B50B15_Out_0[1];
                                float _Split_8531AB0A_B_3 = _UV_D7B50B15_Out_0[2];
                                float _Split_8531AB0A_A_4 = _UV_D7B50B15_Out_0[3];
                                float _Absolute_7380A83F_Out_1;
                                Unity_Absolute_float(_Split_8531AB0A_G_2, _Absolute_7380A83F_Out_1);
                                float _Property_662546E5_Out_0 = Vector1_7AA64B76;
                                float _Power_B71166DE_Out_2;
                                Unity_Power_float(_Absolute_7380A83F_Out_1, _Property_662546E5_Out_0, _Power_B71166DE_Out_2);
                                float _Clamp_E1D4DAAC_Out_3;
                                Unity_Clamp_float(_Power_B71166DE_Out_2, 0, 1, _Clamp_E1D4DAAC_Out_3);
                                float _Split_2009256D_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                float _Split_2009256D_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                float _Split_2009256D_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                float _Split_2009256D_A_4 = 0;
                                float2 _Vector2_CC34729D_Out_0 = float2(_Split_2009256D_R_1, _Split_2009256D_G_2);
                                float _Property_9E14CE56_Out_0 = Vector1_3AEF5FB5;
                                float _Multiply_345227B7_Out_2;
                                Unity_Multiply_float(IN.TimeParameters.x, _Property_9E14CE56_Out_0, _Multiply_345227B7_Out_2);
                                float2 _Property_327BCBBA_Out_0 = Vector2_AB971143;
                                float2 _Multiply_AF73FD34_Out_2;
                                Unity_Multiply_float((_Multiply_345227B7_Out_2.xx), _Property_327BCBBA_Out_0, _Multiply_AF73FD34_Out_2);
                                float2 _TilingAndOffset_F9992348_Out_3;
                                Unity_TilingAndOffset_float(_Vector2_CC34729D_Out_0, float2 (1, 1), _Multiply_AF73FD34_Out_2, _TilingAndOffset_F9992348_Out_3);
                                float _Property_5FB49BF2_Out_0 = Vector1_52D24AB4;
                                float _GradientNoise_38A389D_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_F9992348_Out_3, _Property_5FB49BF2_Out_0, _GradientNoise_38A389D_Out_2);
                                float _Add_4D83CB4A_Out_2;
                                Unity_Add_float(_GradientNoise_38A389D_Out_2, -0.5, _Add_4D83CB4A_Out_2);
                                float _Property_15B8DDD8_Out_0 = Vector1_36BC0FD6;
                                float _Multiply_79477563_Out_2;
                                Unity_Multiply_float(_Add_4D83CB4A_Out_2, _Property_15B8DDD8_Out_0, _Multiply_79477563_Out_2);
                                float2 _Property_990C9E3C_Out_0 = Vector2_AB971143;
                                float2 _Multiply_4B3FCBD_Out_2;
                                Unity_Multiply_float((_Multiply_79477563_Out_2.xx), _Property_990C9E3C_Out_0, _Multiply_4B3FCBD_Out_2);
                                float2 _Multiply_60657008_Out_2;
                                Unity_Multiply_float((_Clamp_E1D4DAAC_Out_3.xx), _Multiply_4B3FCBD_Out_2, _Multiply_60657008_Out_2);
                                float _Split_9E78B1A2_R_1 = _Multiply_60657008_Out_2[0];
                                float _Split_9E78B1A2_G_2 = _Multiply_60657008_Out_2[1];
                                float _Split_9E78B1A2_B_3 = 0;
                                float _Split_9E78B1A2_A_4 = 0;
                                float3 _Vector3_38BD9621_Out_0 = float3(_Split_9E78B1A2_R_1, _Split_9E78B1A2_G_2, 0);
                                float3 _Add_FDF7547E_Out_2;
                                Unity_Add_float3(_Vector3_38BD9621_Out_0, IN.AbsoluteWorldSpacePosition, _Add_FDF7547E_Out_2);
                                float3 _Transform_D353B0C2_Out_1 = TransformWorldToObject(_Add_FDF7547E_Out_2.xyz);
                                description.VertexPosition = _Transform_D353B0C2_Out_1;
                                description.VertexNormal = IN.ObjectSpaceNormal;
                                description.VertexTangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Graph Pixel
                            struct SurfaceDescriptionInputs
                            {
                                float3 TangentSpaceNormal;
                                float4 uv0;
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
                                float4 _SampleTexture2D_C96E94F2_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
                                float _SampleTexture2D_C96E94F2_R_4 = _SampleTexture2D_C96E94F2_RGBA_0.r;
                                float _SampleTexture2D_C96E94F2_G_5 = _SampleTexture2D_C96E94F2_RGBA_0.g;
                                float _SampleTexture2D_C96E94F2_B_6 = _SampleTexture2D_C96E94F2_RGBA_0.b;
                                float _SampleTexture2D_C96E94F2_A_7 = _SampleTexture2D_C96E94F2_RGBA_0.a;
                                float4 _Add_3C3A7912_Out_2;
                                Unity_Add_float4(_SampleTexture2D_C96E94F2_RGBA_0, float4(0, 0, 0, 0), _Add_3C3A7912_Out_2);
                                float _Split_24F15CEB_R_1 = _Add_3C3A7912_Out_2[0];
                                float _Split_24F15CEB_G_2 = _Add_3C3A7912_Out_2[1];
                                float _Split_24F15CEB_B_3 = _Add_3C3A7912_Out_2[2];
                                float _Split_24F15CEB_A_4 = _Add_3C3A7912_Out_2[3];
                                float _Preview_737C03B4_Out_1;
                                Unity_Preview_float(_SampleTexture2D_C96E94F2_A_7, _Preview_737C03B4_Out_1);
                                float4 _Combine_2F284CDB_RGBA_4;
                                float3 _Combine_2F284CDB_RGB_5;
                                float2 _Combine_2F284CDB_RG_6;
                                Unity_Combine_float(_Split_24F15CEB_R_1, _Split_24F15CEB_G_2, _Split_24F15CEB_B_3, _Preview_737C03B4_Out_1, _Combine_2F284CDB_RGBA_4, _Combine_2F284CDB_RGB_5, _Combine_2F284CDB_RG_6);
                                float _Split_9831879D_R_1 = _Combine_2F284CDB_RGBA_4[0];
                                float _Split_9831879D_G_2 = _Combine_2F284CDB_RGBA_4[1];
                                float _Split_9831879D_B_3 = _Combine_2F284CDB_RGBA_4[2];
                                float _Split_9831879D_A_4 = _Combine_2F284CDB_RGBA_4[3];
                                surface.Albedo = (_Combine_2F284CDB_RGBA_4.xyz);
                                surface.Alpha = _Split_9831879D_A_4;
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
                                #if UNITY_ANY_INSTANCING_ENABLED
                                uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };

                            // Generated Type: Varyings
                            struct Varyings
                            {
                                float4 positionCS : SV_POSITION;
                                float4 texCoord0;
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

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                            ENDHLSL
                        }

        }
            CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
                                FallBack "Hidden/Shader Graph/FallbackError"
}
