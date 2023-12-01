Shader "Unlit/StencilMask"
{
    Properties
    {
        _StencilValue ("Stencil value", Range(0,255)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        ZWrite Off
        ColorMask 0

        Pass
        {
            Stencil
            {
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }
        }
    }
}
