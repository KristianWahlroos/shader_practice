// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Tut1Shader" {
	Properties {
		_Tint ("Tint", Color) = (1, 1, 1, 1)
	}
	
	SubShader {

		Pass {
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 MyVertexProgram (float4 position : POSITION) : SV_POSITION {
				return UnityObjectToClipPos(position);;
			}

			float4 MyFragmentProgram (float4 position: SV_POSITION) : SV_TARGET {
				return float4(0.5, 0.3, 0.4,1);
			}

			ENDCG
		}
	}
}