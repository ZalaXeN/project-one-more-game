Shader "Custom/Blood_NoAlpha"
{
    Properties
    {
        [HDR] Color_3C818018("Color", Color) = (2, 2, 2, 1)
        [NoScaleOffset]Texture2D_78672357("MainTexture", 2D) = "white" {}
        Vector1_E1B5B4BB("Power", Float) = 2
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
        #define VARYINGS_NEED_TEXCOORD1
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
            float4 texCoord1;
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
            float4 uv1;
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
            float4 interp5 : TEXCOORD5;
            float3 interp6 : TEXCOORD6;
            #if defined(LIGHTMAP_ON)
            float2 interp7 : TEXCOORD7;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp8 : TEXCOORD8;
            #endif
            float4 interp9 : TEXCOORD9;
            float4 interp10 : TEXCOORD10;
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
            output.interp4.xyzw = input.texCoord1;
            output.interp5.xyzw = input.color;
            output.interp6.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp7.xy = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp8.xyz = input.sh;
            #endif
            output.interp9.xyzw = input.fogFactorAndVertexLight;
            output.interp10.xyzw = input.shadowCoord;
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
            output.texCoord1 = input.interp4.xyzw;
            output.color = input.interp5.xyzw;
            output.viewDirectionWS = input.interp6.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp7.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp8.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp9.xyzw;
            output.shadowCoord = input.interp10.xyzw;
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
        float4 Color_3C818018;
        float4 Texture2D_78672357_TexelSize;
        float Vector1_E1B5B4BB;
        CBUFFER_END

            // Object and Global properties
            TEXTURE2D(Texture2D_78672357);
            SAMPLER(samplerTexture2D_78672357);
            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

            // Graph Functions

            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
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
                float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                output.uv1 = input.texCoord1;
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
                #define VARYINGS_NEED_TEXCOORD1
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
                    float4 texCoord1;
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
                    float4 uv1;
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
                    float4 interp5 : TEXCOORD5;
                    float3 interp6 : TEXCOORD6;
                    #if defined(LIGHTMAP_ON)
                    float2 interp7 : TEXCOORD7;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp8 : TEXCOORD8;
                    #endif
                    float4 interp9 : TEXCOORD9;
                    float4 interp10 : TEXCOORD10;
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
                    output.interp4.xyzw = input.texCoord1;
                    output.interp5.xyzw = input.color;
                    output.interp6.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp7.xy = input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp8.xyz = input.sh;
                    #endif
                    output.interp9.xyzw = input.fogFactorAndVertexLight;
                    output.interp10.xyzw = input.shadowCoord;
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
                    output.texCoord1 = input.interp4.xyzw;
                    output.color = input.interp5.xyzw;
                    output.viewDirectionWS = input.interp6.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp7.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp8.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp9.xyzw;
                    output.shadowCoord = input.interp10.xyzw;
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
                float4 Color_3C818018;
                float4 Texture2D_78672357_TexelSize;
                float Vector1_E1B5B4BB;
                CBUFFER_END

                    // Object and Global properties
                    TEXTURE2D(Texture2D_78672357);
                    SAMPLER(samplerTexture2D_78672357);
                    SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                    // Graph Functions

                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Multiply_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Power_float(float A, float B, out float Out)
                    {
                        Out = pow(A, B);
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
                        float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                        float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                        float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                        Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                        float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                        Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                        float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                        float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                        float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                        float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                        float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                        float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                        Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                        float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                        Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                        float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                        Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                        float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                        float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                        Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                        surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = 0.5;
                        surface.Occlusion = 1;
                        surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                        surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                        output.uv1 = input.texCoord1;
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
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define VARYINGS_NEED_TEXCOORD0
                        #define VARYINGS_NEED_TEXCOORD1
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
                            float4 uv1 : TEXCOORD1;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                            float4 positionCS : SV_POSITION;
                            float4 texCoord0;
                            float4 texCoord1;
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
                            float4 uv1;
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
                            output.interp1.xyzw = input.texCoord1;
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
                            output.texCoord1 = input.interp1.xyzw;
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
                        float4 Color_3C818018;
                        float4 Texture2D_78672357_TexelSize;
                        float Vector1_E1B5B4BB;
                        CBUFFER_END

                            // Object and Global properties
                            TEXTURE2D(Texture2D_78672357);
                            SAMPLER(samplerTexture2D_78672357);
                            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                            // Graph Functions

                            void Unity_OneMinus_float(float In, out float Out)
                            {
                                Out = 1 - In;
                            }

                            void Unity_Multiply_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Power_float(float A, float B, out float Out)
                            {
                                Out = pow(A, B);
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
                                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                output.uv1 = input.texCoord1;
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
                                #define ATTRIBUTES_NEED_TEXCOORD1
                                #define VARYINGS_NEED_TEXCOORD0
                                #define VARYINGS_NEED_TEXCOORD1
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
                                    float4 uv1 : TEXCOORD1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                    float4 positionCS : SV_POSITION;
                                    float4 texCoord0;
                                    float4 texCoord1;
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
                                    float4 uv1;
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
                                    output.interp1.xyzw = input.texCoord1;
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
                                    output.texCoord1 = input.interp1.xyzw;
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
                                float4 Color_3C818018;
                                float4 Texture2D_78672357_TexelSize;
                                float Vector1_E1B5B4BB;
                                CBUFFER_END

                                    // Object and Global properties
                                    TEXTURE2D(Texture2D_78672357);
                                    SAMPLER(samplerTexture2D_78672357);
                                    SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                    // Graph Functions

                                    void Unity_OneMinus_float(float In, out float Out)
                                    {
                                        Out = 1 - In;
                                    }

                                    void Unity_Multiply_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Power_float(float A, float B, out float Out)
                                    {
                                        Out = pow(A, B);
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
                                        float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                        float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                        float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                        float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                        float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                        float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                        float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                        Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                        float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                        Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                        float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                        Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                        float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                        float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                        Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                        surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                        surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                        output.uv1 = input.texCoord1;
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
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_TEXCOORD1
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
                                            float4 texCoord1;
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
                                            float4 uv1;
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
                                            output.interp3.xyzw = input.texCoord1;
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
                                            output.texCoord1 = input.interp3.xyzw;
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
                                        float4 Color_3C818018;
                                        float4 Texture2D_78672357_TexelSize;
                                        float Vector1_E1B5B4BB;
                                        CBUFFER_END

                                            // Object and Global properties
                                            TEXTURE2D(Texture2D_78672357);
                                            SAMPLER(samplerTexture2D_78672357);
                                            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                            // Graph Functions

                                            void Unity_OneMinus_float(float In, out float Out)
                                            {
                                                Out = 1 - In;
                                            }

                                            void Unity_Multiply_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Power_float(float A, float B, out float Out)
                                            {
                                                Out = pow(A, B);
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
                                                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                output.uv1 = input.texCoord1;
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
                                                #define VARYINGS_NEED_TEXCOORD1
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
                                                    float4 texCoord1;
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
                                                    float4 uv1;
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
                                                    output.interp0.xyzw = input.texCoord0;
                                                    output.interp1.xyzw = input.texCoord1;
                                                    output.interp2.xyzw = input.color;
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
                                                    output.texCoord1 = input.interp1.xyzw;
                                                    output.color = input.interp2.xyzw;
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
                                                float4 Color_3C818018;
                                                float4 Texture2D_78672357_TexelSize;
                                                float Vector1_E1B5B4BB;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    TEXTURE2D(Texture2D_78672357);
                                                    SAMPLER(samplerTexture2D_78672357);
                                                    SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                    // Graph Functions

                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Power_float(float A, float B, out float Out)
                                                    {
                                                        Out = pow(A, B);
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
                                                        float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                                                        float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                        float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                                                        Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                                                        float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                                                        Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                                                        float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                        float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                        float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                        float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                        float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                        float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                        Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                        float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                        Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                        float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                        Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                        float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                        float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                        Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                        surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                                                        surface.Emission = float3(0, 0, 0);
                                                        surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                        surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                        output.uv1 = input.texCoord1;
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
                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                        #define ATTRIBUTES_NEED_COLOR
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_TEXCOORD1
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
                                                            float4 uv1 : TEXCOORD1;
                                                            float4 color : COLOR;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                            float4 positionCS : SV_POSITION;
                                                            float4 texCoord0;
                                                            float4 texCoord1;
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
                                                            float4 uv1;
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
                                                            output.interp0.xyzw = input.texCoord0;
                                                            output.interp1.xyzw = input.texCoord1;
                                                            output.interp2.xyzw = input.color;
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
                                                            output.texCoord1 = input.interp1.xyzw;
                                                            output.color = input.interp2.xyzw;
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
                                                        float4 Color_3C818018;
                                                        float4 Texture2D_78672357_TexelSize;
                                                        float Vector1_E1B5B4BB;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            TEXTURE2D(Texture2D_78672357);
                                                            SAMPLER(samplerTexture2D_78672357);
                                                            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                            // Graph Functions

                                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_OneMinus_float(float In, out float Out)
                                                            {
                                                                Out = 1 - In;
                                                            }

                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Power_float(float A, float B, out float Out)
                                                            {
                                                                Out = pow(A, B);
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
                                                                float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                                                                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                                                                Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                                                                float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                                                                Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                                                                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                                                                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                output.uv1 = input.texCoord1;
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
                                                                #define VARYINGS_NEED_TEXCOORD1
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
                                                                    float4 texCoord1;
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
                                                                    float4 uv1;
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
                                                                    float4 interp5 : TEXCOORD5;
                                                                    float3 interp6 : TEXCOORD6;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    float2 interp7 : TEXCOORD7;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    float3 interp8 : TEXCOORD8;
                                                                    #endif
                                                                    float4 interp9 : TEXCOORD9;
                                                                    float4 interp10 : TEXCOORD10;
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
                                                                    output.interp4.xyzw = input.texCoord1;
                                                                    output.interp5.xyzw = input.color;
                                                                    output.interp6.xyz = input.viewDirectionWS;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    output.interp7.xy = input.lightmapUV;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    output.interp8.xyz = input.sh;
                                                                    #endif
                                                                    output.interp9.xyzw = input.fogFactorAndVertexLight;
                                                                    output.interp10.xyzw = input.shadowCoord;
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
                                                                    output.texCoord1 = input.interp4.xyzw;
                                                                    output.color = input.interp5.xyzw;
                                                                    output.viewDirectionWS = input.interp6.xyz;
                                                                    #if defined(LIGHTMAP_ON)
                                                                    output.lightmapUV = input.interp7.xy;
                                                                    #endif
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    output.sh = input.interp8.xyz;
                                                                    #endif
                                                                    output.fogFactorAndVertexLight = input.interp9.xyzw;
                                                                    output.shadowCoord = input.interp10.xyzw;
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
                                                                float4 Color_3C818018;
                                                                float4 Texture2D_78672357_TexelSize;
                                                                float Vector1_E1B5B4BB;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    TEXTURE2D(Texture2D_78672357);
                                                                    SAMPLER(samplerTexture2D_78672357);
                                                                    SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                                    // Graph Functions

                                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                    {
                                                                        Out = 1 - In;
                                                                    }

                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Power_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = pow(A, B);
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
                                                                        float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                                                                        float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                        float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                                                                        Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                                                                        float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                                                                        Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                                                                        float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                        float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                        float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                        float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                        float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                        float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                        Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                        float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                        Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                        float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                        Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                        float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                        float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                        Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                        surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                                                                        surface.NormalTS = IN.TangentSpaceNormal;
                                                                        surface.Emission = float3(0, 0, 0);
                                                                        surface.Metallic = 0;
                                                                        surface.Smoothness = 0.5;
                                                                        surface.Occlusion = 1;
                                                                        surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                        surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                        output.uv1 = input.texCoord1;
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
                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_TEXCOORD1
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
                                                                            float4 uv1 : TEXCOORD1;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                            float4 positionCS : SV_POSITION;
                                                                            float4 texCoord0;
                                                                            float4 texCoord1;
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
                                                                            float4 uv1;
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
                                                                            output.interp1.xyzw = input.texCoord1;
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
                                                                            output.texCoord1 = input.interp1.xyzw;
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
                                                                        float4 Color_3C818018;
                                                                        float4 Texture2D_78672357_TexelSize;
                                                                        float Vector1_E1B5B4BB;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            TEXTURE2D(Texture2D_78672357);
                                                                            SAMPLER(samplerTexture2D_78672357);
                                                                            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                                            // Graph Functions

                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Power_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = pow(A, B);
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
                                                                                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                                output.uv1 = input.texCoord1;
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
                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_TEXCOORD1
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
                                                                                    float4 uv1 : TEXCOORD1;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                    float4 positionCS : SV_POSITION;
                                                                                    float4 texCoord0;
                                                                                    float4 texCoord1;
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
                                                                                    float4 uv1;
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
                                                                                    output.interp1.xyzw = input.texCoord1;
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
                                                                                    output.texCoord1 = input.interp1.xyzw;
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
                                                                                float4 Color_3C818018;
                                                                                float4 Texture2D_78672357_TexelSize;
                                                                                float Vector1_E1B5B4BB;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    TEXTURE2D(Texture2D_78672357);
                                                                                    SAMPLER(samplerTexture2D_78672357);
                                                                                    SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                                                    // Graph Functions

                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Power_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = pow(A, B);
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
                                                                                        float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                                        float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                                        float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                                        float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                                        float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                                        float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                                        float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                                        Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                                        float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                        Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                                        float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                                        Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                                        float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                                        float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                                        Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                                        surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                        surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                                        output.uv1 = input.texCoord1;
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
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                        #define VARYINGS_NEED_TEXCOORD1
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
                                                                                            float4 texCoord1;
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
                                                                                            float4 uv1;
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
                                                                                            output.interp3.xyzw = input.texCoord1;
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
                                                                                            output.texCoord1 = input.interp3.xyzw;
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
                                                                                        float4 Color_3C818018;
                                                                                        float4 Texture2D_78672357_TexelSize;
                                                                                        float Vector1_E1B5B4BB;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            TEXTURE2D(Texture2D_78672357);
                                                                                            SAMPLER(samplerTexture2D_78672357);
                                                                                            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                                                            // Graph Functions

                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                            {
                                                                                                Out = 1 - In;
                                                                                            }

                                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Power_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = pow(A, B);
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
                                                                                                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                                                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                                                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                                                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                                                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                                                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                                                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                                                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                                                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                                                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                                                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                                                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                                                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                                                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                                                output.uv1 = input.texCoord1;
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
                                                                                                #define VARYINGS_NEED_TEXCOORD1
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
                                                                                                    float4 texCoord1;
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
                                                                                                    float4 uv1;
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
                                                                                                    output.interp0.xyzw = input.texCoord0;
                                                                                                    output.interp1.xyzw = input.texCoord1;
                                                                                                    output.interp2.xyzw = input.color;
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
                                                                                                    output.texCoord1 = input.interp1.xyzw;
                                                                                                    output.color = input.interp2.xyzw;
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
                                                                                                float4 Color_3C818018;
                                                                                                float4 Texture2D_78672357_TexelSize;
                                                                                                float Vector1_E1B5B4BB;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    TEXTURE2D(Texture2D_78672357);
                                                                                                    SAMPLER(samplerTexture2D_78672357);
                                                                                                    SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                                                                    // Graph Functions

                                                                                                    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = 1 - In;
                                                                                                    }

                                                                                                    void Unity_Multiply_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Power_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = pow(A, B);
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
                                                                                                        float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                                                                                                        float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                                                        float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                                                        float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                                                                                                        Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                                                                                                        float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                                                                                                        Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                                                                                                        float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                                                        float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                                                        float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                                                        float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                                                        float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                                                        float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                                                        Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                                                        float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                                        Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                                                        float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                                                        Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                                                        float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                                                        float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                                                        Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                                                        surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                        surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                                        surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                                                        output.uv1 = input.texCoord1;
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
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                        #define ATTRIBUTES_NEED_COLOR
                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                        #define VARYINGS_NEED_TEXCOORD1
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
                                                                                                            float4 uv1 : TEXCOORD1;
                                                                                                            float4 color : COLOR;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                            float4 positionCS : SV_POSITION;
                                                                                                            float4 texCoord0;
                                                                                                            float4 texCoord1;
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
                                                                                                            float4 uv1;
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
                                                                                                            output.interp0.xyzw = input.texCoord0;
                                                                                                            output.interp1.xyzw = input.texCoord1;
                                                                                                            output.interp2.xyzw = input.color;
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
                                                                                                            output.texCoord1 = input.interp1.xyzw;
                                                                                                            output.color = input.interp2.xyzw;
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
                                                                                                        float4 Color_3C818018;
                                                                                                        float4 Texture2D_78672357_TexelSize;
                                                                                                        float Vector1_E1B5B4BB;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            TEXTURE2D(Texture2D_78672357);
                                                                                                            SAMPLER(samplerTexture2D_78672357);
                                                                                                            SAMPLER(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_Sampler_3_Linear_Repeat);

                                                                                                            // Graph Functions

                                                                                                            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = 1 - In;
                                                                                                            }

                                                                                                            void Unity_Multiply_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Power_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = pow(A, B);
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
                                                                                                                float4 _Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0 = Color_3C818018;
                                                                                                                float4 _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_78672357, samplerTexture2D_78672357, IN.uv0.xy);
                                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.r;
                                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_G_5 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.g;
                                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_B_6 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.b;
                                                                                                                float _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7 = _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0.a;
                                                                                                                float4 _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2;
                                                                                                                Unity_Multiply_float(_Property_e65f4d87cee08f81985c3c5d2e71d9c9_Out_0, _SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_RGBA_0, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2);
                                                                                                                float4 _Multiply_c2524e0e381272859efba277991efd60_Out_2;
                                                                                                                Unity_Multiply_float(IN.VertexColor, _Multiply_d2608630efb9ff82a72711fa91a436dd_Out_2, _Multiply_c2524e0e381272859efba277991efd60_Out_2);
                                                                                                                float4 _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0 = IN.uv1;
                                                                                                                float _Split_f7d955b813c1878287ff28380676f765_R_1 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[0];
                                                                                                                float _Split_f7d955b813c1878287ff28380676f765_G_2 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[1];
                                                                                                                float _Split_f7d955b813c1878287ff28380676f765_B_3 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[2];
                                                                                                                float _Split_f7d955b813c1878287ff28380676f765_A_4 = _UV_b295b9eaccad7a89aec6b7ada3947e6b_Out_0[3];
                                                                                                                float _OneMinus_a547371832d51c898a596950415fd5be_Out_1;
                                                                                                                Unity_OneMinus_float(_Split_f7d955b813c1878287ff28380676f765_R_1, _OneMinus_a547371832d51c898a596950415fd5be_Out_1);
                                                                                                                float _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                                                Unity_Multiply_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_A_7, _OneMinus_a547371832d51c898a596950415fd5be_Out_1, _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2);
                                                                                                                float _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1;
                                                                                                                Unity_OneMinus_float(_SampleTexture2D_8a89266ba6ed43828747af6e74c6205b_R_4, _OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1);
                                                                                                                float _Property_668d742d94139a8b88e33070f910d9ad_Out_0 = Vector1_E1B5B4BB;
                                                                                                                float _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
                                                                                                                Unity_Power_float(_OneMinus_a97920110be7d48d8f6c582293b428b7_Out_1, _Property_668d742d94139a8b88e33070f910d9ad_Out_0, _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2);
                                                                                                                surface.BaseColor = (_Multiply_c2524e0e381272859efba277991efd60_Out_2.xyz);
                                                                                                                surface.Alpha = _Multiply_4e5d858b27dd2e8b932b572c068451b4_Out_2;
                                                                                                                surface.AlphaClipThreshold = _Power_3baeb1b638f6b087b9569d78960ef9b9_Out_2;
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
                                                                                                                output.uv1 = input.texCoord1;
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
