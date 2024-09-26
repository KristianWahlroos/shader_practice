#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

float4 _Tint;
sampler2D _MainTex, _DetailTex;
float4 _MainTex_ST, _DetailTex_ST;
float _Metallic;
float _Smoothness;

sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;

struct Interpolators {
	float4 position : SV_POSITION;
	float4 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD3;
	#endif
};

struct VertexData {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};

void ComputeVertexLightColor (inout Interpolators i) {
	#if defined(VERTEXLIGHT_ON)
		i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		);
	#endif
}

Interpolators MyVertexProgram (VertexData v) {
	Interpolators i;
	i.position = UnityObjectToClipPos(v.position);
	i.worldPos = mul(unity_ObjectToWorld, v.position);
	i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
	i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
	i.normal = UnityObjectToWorldNormal(v.normal);
	ComputeVertexLightColor(i);
	return i;
}

UnityLight CreateLight (Interpolators i) {
	UnityLight light;
	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif
	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb* attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

UnityIndirect CreateIndirectLight (Interpolators i) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif
	#if defined(FORWARD_BASE_PASS)
		indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
	#endif
	return indirectLight;
}

void InitializeFragmentNormal(inout Interpolators i) {	
	i.normal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
	i.normal =
		UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
	i.normal = i.normal.xzy;
	i.normal = normalize(i.normal);
}

float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
	InitializeFragmentNormal(i);
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
	float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Tint.rgb;
	albedo *= tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;
	
	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);
	return UNITY_BRDF_PBS(
		albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		CreateLight(i), CreateIndirectLight(i)
	);
}

#endif