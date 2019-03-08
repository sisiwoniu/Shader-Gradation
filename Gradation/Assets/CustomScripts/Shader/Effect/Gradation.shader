Shader "Custom/Gradation"
{
    Properties
    {
        [PerRendererData]
        _MainTex("Texture", 2D) = "white" {}

        [Toggle]
        _ShowAnim("Show Anim", float) = 0 

        _Rate("Gradation Rate", Range(0, 1)) = 0.5
 
        _TopCol("Top Color", Color) = (1, 1, 1, 1)

        _TopYPos("Top Color Y Pos", Range(0, 1)) = 0.5

        _GradationStrength("Gradation Strength", Range(1, 10)) = 1

        _ExpandValue("Expand Value", Range(1, 10)) = 1

        _Speed("Speed", Range(-5, 5)) = 1

        //アウトラインシェーダーで使用するパラメーター
        //_OutLineColor("OutLine Color", Color) = (0, 0, 0, 1)

        //_OutLineSize("OutLine Size", Range(0, 10)) = 2
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderQueue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        //UsePass "Custom/Unlit2DOutLine/2DOUTLINE"

        Pass
        {
            Name "GRADATION"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _SHOWANIM_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;

            fixed4 _TopCol;

            fixed _Rate;

            fixed _TopYPos;

            fixed _GradationStrength;

            fixed _ExpandValue;

            fixed _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                fixed4 col = tex2D(_MainTex, i.uv);

                //テクスチャの色をベース色として取得
                col *= i.color;

                #ifdef _SHOWANIM_ON

                _TopYPos = frac(_TopYPos + _Time.y * _Speed);

                #endif

                //0に近づけば近づくほどグラデーションが強くなる
                fixed amount = clamp(abs(_TopYPos - i.uv.y / _ExpandValue) + (1 - _Rate / _ExpandValue), 0, 1);

                _TopCol.rbg *= _GradationStrength;

                i.color.rgb = lerp(_TopCol.rgb, col.rgb, amount);

                i.color.a = col.a;

                return i.color;
            }
            ENDCG
        }
    }
}
