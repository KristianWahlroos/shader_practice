Shader "Custom/Tut1Shader" {
	SubShader {

		Pass {
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			void MyVertexProgram () {

			}

			void MyFragmentProgram () {

			}

			ENDCG
		}
	}
}