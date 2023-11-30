Shader "Shader Graphs/Shader_dissolve"
{
    Properties
    {
        [NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
        [NoScaleOffset]_Normal("Normal", 2D) = "white" {}
        [NoScaleOffset]_AO("AO", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (1, 1, 1, 0)
        _Metallic("Metallic", Float) = 0
        _Smoothness("Smoothness", Float) = 0
        _NormalStrenght("NormalStrenght", Float) = 0
        _DissolveAmount("DissolveAmount", Range(0, 1)) = 0
        _DissolveScale("DissolveScale", Float) = 30
        _GlitchDensity("GlitchDensity", Float) = 0
        _GitchVelocity("GitchVelocity", Float) = 5
        [HDR]_GlitchColor("GlitchColor", Color) = (0, 0, 0, 0)
        [NonModifiableTextureData][NoScaleOffset]_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D("Texture2D", 2D) = "black" {}
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType"="Opaque"
            "BuiltInMaterialType" = "Lit"
            "Queue"="AlphaTest"
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="BuiltInLitSubTarget"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
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
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV : INTERP0;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP1;
            #endif
             float4 tangentWS : INTERP2;
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float4 shadowCoord : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.shadowCoord.xyzw = input.shadowCoord;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.shadowCoord = input.shadowCoord.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
            float4 _Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Albedo);
            float4 _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.tex, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.samplerstate, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_R_4_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_G_5_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_B_6_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_A_7_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.a;
            float4 _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4, _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4, _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4);
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float4 _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4, _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4);
            float4 _Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4);
            float4 _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4, _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4);
            UnityTexture2D _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal);
            float4 _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.tex, _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.samplerstate, _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4);
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_R_4_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.r;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_G_5_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.g;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_B_6_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.b;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_A_7_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.a;
            float _Property_52795695c79a4b119bb340931832fa60_Out_0_Float = _NormalStrenght;
            float3 _NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.xyz), _Property_52795695c79a4b119bb340931832fa60_Out_0_Float, _NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3);
            float3 _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3, (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4.xyz), _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3);
            float _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 3, _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float);
            float4 _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4);
            float4 _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4, _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4, _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4);
            float4 _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4;
            Unity_Multiply_float4_float4((_FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float.xxxx), _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4, _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4);
            float _Property_b1f0ccaa62f447f8b67e53b8c4fa968f_Out_0_Float = _Metallic;
            float _Property_d079ec0ddaee4485b1bc73929a1a7940_Out_0_Float = _Smoothness;
            UnityTexture2D _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_AO);
            float4 _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.tex, _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.samplerstate, _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_R_4_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.r;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_G_5_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.g;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_B_6_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.b;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_A_7_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.a;
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.BaseColor = (_Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4.xyz);
            surface.NormalTS = _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3;
            surface.Emission = (_Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4.xyz);
            surface.Metallic = _Property_b1f0ccaa62f447f8b67e53b8c4fa968f_Out_0_Float;
            surface.Smoothness = _Property_d079ec0ddaee4485b1bc73929a1a7940_Out_0_Float;
            surface.Occlusion = (_SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4).x;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
        
        // Render State
        Blend SrcAlpha One, One One
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdadd_fullshadows
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
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
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD_ADD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV : INTERP0;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP1;
            #endif
             float4 tangentWS : INTERP2;
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float4 shadowCoord : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.shadowCoord.xyzw = input.shadowCoord;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.shadowCoord = input.shadowCoord.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
            float4 _Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Albedo);
            float4 _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.tex, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.samplerstate, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_R_4_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_G_5_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_B_6_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_A_7_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.a;
            float4 _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4, _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4, _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4);
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float4 _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4, _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4);
            float4 _Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4);
            float4 _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4, _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4);
            UnityTexture2D _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal);
            float4 _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.tex, _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.samplerstate, _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4);
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_R_4_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.r;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_G_5_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.g;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_B_6_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.b;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_A_7_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.a;
            float _Property_52795695c79a4b119bb340931832fa60_Out_0_Float = _NormalStrenght;
            float3 _NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.xyz), _Property_52795695c79a4b119bb340931832fa60_Out_0_Float, _NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3);
            float3 _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3, (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4.xyz), _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3);
            float _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 3, _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float);
            float4 _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4);
            float4 _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4, _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4, _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4);
            float4 _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4;
            Unity_Multiply_float4_float4((_FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float.xxxx), _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4, _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4);
            float _Property_b1f0ccaa62f447f8b67e53b8c4fa968f_Out_0_Float = _Metallic;
            float _Property_d079ec0ddaee4485b1bc73929a1a7940_Out_0_Float = _Smoothness;
            UnityTexture2D _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_AO);
            float4 _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.tex, _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.samplerstate, _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_R_4_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.r;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_G_5_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.g;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_B_6_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.b;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_A_7_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.a;
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.BaseColor = (_Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4.xyz);
            surface.NormalTS = _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3;
            surface.Emission = (_Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4.xyz);
            surface.Metallic = _Property_b1f0ccaa62f447f8b67e53b8c4fa968f_Out_0_Float;
            surface.Smoothness = _Property_d079ec0ddaee4485b1bc73929a1a7940_Out_0_Float;
            surface.Occlusion = (_SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4).x;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn Deferred"
            Tags
            {
                "LightMode" = "Deferred"
            }
        
        // Render State
        Cull Back
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
        #pragma multi_compile_instancing
        #pragma exclude_renderers nomrt
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
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
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEFERRED
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV : INTERP0;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP1;
            #endif
             float4 tangentWS : INTERP2;
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float4 shadowCoord : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.shadowCoord.xyzw = input.shadowCoord;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.shadowCoord = input.shadowCoord.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
            float4 _Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Albedo);
            float4 _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.tex, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.samplerstate, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_R_4_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_G_5_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_B_6_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_A_7_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.a;
            float4 _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4, _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4, _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4);
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float4 _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4, _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4);
            float4 _Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4);
            float4 _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4, _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4);
            UnityTexture2D _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal);
            float4 _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.tex, _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.samplerstate, _Property_6aacdc6a95d1486eb3961f7f7c100b87_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4);
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_R_4_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.r;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_G_5_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.g;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_B_6_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.b;
            float _SampleTexture2D_25c61307384645f7be3196e29b1d7880_A_7_Float = _SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.a;
            float _Property_52795695c79a4b119bb340931832fa60_Out_0_Float = _NormalStrenght;
            float3 _NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_25c61307384645f7be3196e29b1d7880_RGBA_0_Vector4.xyz), _Property_52795695c79a4b119bb340931832fa60_Out_0_Float, _NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3);
            float3 _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3;
            Unity_Multiply_float3_float3(_NormalStrength_c1fa4df631274c41b1eeec4aecf6153e_Out_2_Vector3, (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4.xyz), _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3);
            float _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 3, _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float);
            float4 _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4);
            float4 _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4, _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4, _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4);
            float4 _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4;
            Unity_Multiply_float4_float4((_FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float.xxxx), _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4, _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4);
            float _Property_b1f0ccaa62f447f8b67e53b8c4fa968f_Out_0_Float = _Metallic;
            float _Property_d079ec0ddaee4485b1bc73929a1a7940_Out_0_Float = _Smoothness;
            UnityTexture2D _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_AO);
            float4 _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.tex, _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.samplerstate, _Property_fa48b6b05b9c47ae88b4083db31ede54_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_R_4_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.r;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_G_5_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.g;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_B_6_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.b;
            float _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_A_7_Float = _SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4.a;
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.BaseColor = (_Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4.xyz);
            surface.NormalTS = _Multiply_03db21b8b52c40eabebcfc1958b471f9_Out_2_Vector3;
            surface.Emission = (_Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4.xyz);
            surface.Metallic = _Property_b1f0ccaa62f447f8b67e53b8c4fa968f_Out_0_Float;
            surface.Smoothness = _Property_d079ec0ddaee4485b1bc73929a1a7940_Out_0_Float;
            surface.Occlusion = (_SampleTexture2D_55d7bf8a2593408ba27a58b5447b5a05_RGBA_0_Vector4).x;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"
        
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
        Cull Back
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
        #pragma target 3.0
        #pragma multi_compile_shadowcaster
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 positionWS;
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
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
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
        Cull Back
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
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 positionWS;
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
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
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
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 positionWS;
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
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
            float4 _Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4 = _BaseColor;
            UnityTexture2D _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Albedo);
            float4 _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.tex, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.samplerstate, _Property_0362d1b1ee52488eb4c0a4081b89441e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_R_4_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_G_5_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_B_6_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_A_7_Float = _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4.a;
            float4 _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_79996b630298407aa13496a50fde2fd1_Out_0_Vector4, _SampleTexture2D_bb126b4fde78407b8700b9a81a179735_RGBA_0_Vector4, _Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4);
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float4 _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_76f973998b6f49e99777cdd4b08526e9_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4, _Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4);
            float4 _Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_3eee76c42df44ce080a4ee1eedb0928b_Out_0_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4);
            float4 _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a0e15fc999d74d9aa3908ab7cf3cbed9_Out_2_Vector4, _Multiply_07afa1d147ac483cb4a45f2885291dc7_Out_2_Vector4, _Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4);
            float _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 3, _FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float);
            float4 _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4);
            float4 _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GlitchColor) : _GlitchColor;
            float4 _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_f80339120ad34125a21998b2babfd3ed_Out_2_Vector4, _Property_5870763f614a446e96860a57c077cabe_Out_0_Vector4, _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4);
            float4 _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4;
            Unity_Multiply_float4_float4((_FresnelEffect_59f9fcbec4b34adfa4667bc926335c40_Out_3_Float.xxxx), _Multiply_1d8d89b2cc9a44efba9d8887d4d56cdf_Out_2_Vector4, _Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4);
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.BaseColor = (_Add_49cfa1236ff443b481998d232e4f1f3b_Out_2_Vector4.xyz);
            surface.Emission = (_Multiply_1bfc26c299c04f93b97db7f856fe3a2d_Out_2_Vector4.xyz);
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.texcoord2  = attributes.uv2;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SceneSelectionPass
        #define BUILTIN_TARGET_API 1
        #define SCENESELECTIONPASS 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 positionWS;
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
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS ScenePickingPass
        #define BUILTIN_TARGET_API 1
        #define SCENEPICKINGPASS 1
        #define _BUILTIN_AlphaClip 1
        #define _BUILTIN_ALPHATEST_ON 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
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
             float3 positionWS;
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
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpaceViewDirection;
             float3 TangentSpaceViewDirection;
             float4 uv0;
             float3 TimeParameters;
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
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D_TexelSize;
        float4 _Albedo_TexelSize;
        float4 _AO_TexelSize;
        float4 _BaseColor;
        float _Metallic;
        float _Smoothness;
        float _NormalStrenght;
        float4 _Normal_TexelSize;
        float _DissolveAmount;
        float _DissolveScale;
        float _GlitchDensity;
        float _GitchVelocity;
        float4 _GlitchColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        SAMPLER(sampler_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D);
        TEXTURE2D(_Albedo);
        SAMPLER(sampler_Albedo);
        TEXTURE2D(_AO);
        SAMPLER(sampler_AO);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
        
        // Graph Functions
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
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
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float2 _ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2 = UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy) + ParallaxMappingChannel(TEXTURE2D_ARGS(UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).samplerstate), IN.TangentSpaceViewDirection, 15 * 0.01, UnityBuildTexture2DStructNoScale(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_Heightmap_1_Texture2D).GetTransformedUV(IN.uv0.xy), 1);
            float _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float = _GitchVelocity;
            float _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, _Property_fb52e4e028f140a89e29a6328aed27f8_Out_0_Float, _Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float);
            float2 _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2;
            Unity_TilingAndOffset_float(_ParallaxMapping_4f59d0b1eb0d42c795f6bdaeeec486a5_ParallaxUVs_0_Vector2, float2 (1, 7), (_Divide_b5c9f80529264d409bc279bd735e33f8_Out_2_Float.xx), _TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2);
            float4 _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_47bca66db1d0424281736091037c4228_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_83ba33d66d75486195fe50dd0274cf53_Out_3_Vector2) );
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_R_4_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.r;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_G_5_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.g;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_B_6_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.b;
            float _SampleTexture2D_47bca66db1d0424281736091037c4228_A_7_Float = _SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4.a;
            float _Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float = _DissolveScale;
            float2 _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3c196d7690d14c70a107364bcbd5c5fd_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2);
            float4 _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_56783c04940b4d36a912f898583af251_Out_3_Vector2) );
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_R_4_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.r;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_G_5_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.g;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_B_6_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.b;
            float _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_A_7_Float = _SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4.a;
            float _Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float = _DissolveAmount;
            float4 _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4;
            Unity_Step_float4(_SampleTexture2D_aa9793440f2d4df988f5ebcbec4e4f65_RGBA_0_Vector4, (_Property_0ef061a0e052486ba9508747c29d4a6f_Out_0_Float.xxxx), _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4);
            float4 _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_47bca66db1d0424281736091037c4228_RGBA_0_Vector4, _Step_37bbcc34ad394ec6a9d450fa0f3715e2_Out_2_Vector4, _Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4);
            float4 _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_ee440f93325d4faca54b64875b113d69_Out_2_Vector4, _OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4);
            float _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float = _GlitchDensity;
            surface.Alpha = (_OneMinus_267aafc118084a6b8c9ec98547427b1d_Out_1_Vector4).x;
            surface.AlphaClipThreshold = _Property_aad91b997d784a3cb22f2e74ee31c3c4_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
            output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
    FallBack "Hidden/Shader Graph/FallbackError"
}