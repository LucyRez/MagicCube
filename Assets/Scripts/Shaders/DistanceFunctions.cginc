// Sphere
// s: radius
float sdSphere(float3 p, float s)
{
	return length(p) - s;
}

// Union
float opU(float d1, float d2)
{
	return min(d1, d2);
}

// Box
// b: size of box in x/y/z
float sdBox(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return max(max(d.x, d.y), d.z);
	// return min(max(d.x, max(d.y, d.z)), 0.0) +
	// 	length(max(d, 0.0));
}

float sd2DBox(in float2 p , in float2 b){
	float2 d = abs(p) - b;
	return length(max(d, float2(0,0))) + min(max(d.x, d.y), 0.0);

}

float sdCross(in float3 p){

	float inf = 3.0;
	float box1 = sdBox(p, float3(inf, 1.0, 1.0));
	float box2 = sdBox(p, float3(1.0, inf, 1.0));
	float box3 = sdBox(p, float3(1.0, 1.0, inf));

	return min(box1, min(box2, box3));
	// float da = sd2DBox(p.xy, float2(b,b));
	// float db = sd2DBox(p.yz, float2(b,b));
	// float dc = sd2DBox(p.zx, float2(b,b));

	// return min(da, min(db,dc));
}

float pMod(float p, float size){
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(p-halfsize,size)+halfsize;
	return p;
}

float sdMenger(in float3 p){
	float d = sdBox(p, float3(1.0, 1.0, 1.0));

	float s = 1.0;

	for(int m = 0; m<8; m++){
		float3 a = fmod(p*s,2.0) - 1.0;
		s*= 3.0;
		float3 r = 1.0 - 3.0*abs(a);

		float c = sdCross(r) / s;
		d = max(d, c);
	}

	// for(int m = 0; m < 8; m++){

	// 	float3 a = fmod(p*s, 2.0) - 1.0;
	// 	s*= 3.0;
	// 	float3 r = abs(1.0 - 3.0*abs(a));

	// 	float da = max(r.x, r.y);
	// 	float db = max(r.y, r.z);
	// 	float dc = max(r.z, r.x);
	// 	float c = (min(da, min(db, dc) - 1.0))/s;

	// 	d = max(d,c);
	// }

	return d;
}

// BOOLEAN OPERATORS //



// Subtraction
float opS(float d1, float d2)
{
	return max(-d1, d2);
}

// Intersection
float opI(float d1, float d2)
{
	return max(d1, d2);
}

// Mod Position Axis
float pMod1 (inout float p, float size)
{
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(-p+halfsize,size)-halfsize;
	return c;
}
