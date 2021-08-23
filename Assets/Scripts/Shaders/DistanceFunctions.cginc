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

	return min(max(d.x, max(d.y, d.z)), 0.0) +
		length(max(d, 0.0));
}

float sd2DBox(in float2 p , in float2 b){
	float2 d = abs(p) - b;
	return length(max(d, float2(0,0))) + min(max(d.x, d.y), 0.0);

}

float sdCross(in float3 p, float b){

	float da = sd2DBox(p.xy, float2(b,b));
	float db = sd2DBox(p.yz, float2(b,b));
	float dc = sd2DBox(p.zx, float2(b,b));

	return min(da, min(db,dc));
}

float pMod(float p, float size){
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(p-halfsize,size)+halfsize;
	return p;
}

float2 sdMenger(in float3 p, float b, int iterations, float3 offsetMod, 
float4x4 globalTransform,  float scaleFactor){

	p = mul(globalTransform, float4(p,1)).xyz;
	float2 d = float2(sdBox(p, float3(b, b, b)), 0);

	float s = 1.0;

	for(int m = 0; m<iterations; m++){

		p.x = pMod(p.x, b*offsetMod.x * 2/s);
		p.y = pMod(p.y, b*offsetMod.y * 2/s);
		p.z = pMod(p.z, b*offsetMod.z * 2/s);
		s*= scaleFactor * 3.0;

		float3 r = p * s;

		float c = sdCross(r, b) / s;

		if(-c > d.x){
			d.x = -c;
			d = float2(d.x, m);
		}
	}

	return d;
}

float sdPyramid(float3 p, float h){
	float m2 = h*h + 0.25;

	p.xz = abs(p.xz);
	p.xz = (p.z > p.x) ? p.zx : p.xz;
	p.xz -= 0.5;

	float3 q = float3(p.z, h*p.y - 0.5*p.x, h*p.x + 0.5 * p.y);

	float s = max(-q.x, 0.0);

	float t = clamp((q.y - 0.5*p.z)/(m2+0.25), 0.0, 1.0);
	float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
	float b = m2*(q.x+0.5*t)*(q.x + 0.5*t) + (q.y - m2*t)*(q.y-m2*t);

	float d2 = min(q.y, -q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);

	return sqrt((d2+q.z*q.z)/m2) * sign(max(q.z, -p.y));
}

float sdTrianglePrism(float2 p, float2 h){
	 p.y = p.y;
    p.y += h.x;
    const float k = sqrt(3.0);
    h.x *= 0.5*k;
    p.xy /= h.x;
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x+k*p.y>0.0 ) p.xy=float2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    float d1 = length(p.xy)*sign(-p.y)*h.x;
    float d2 = -h.y;
    return length(max(float2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}

float sdTriangleCross(in float3 p, float2 b ){
	float da = sdTrianglePrism(p.xy, float2(b.x, b.y*0.2));
	float db = sdTrianglePrism(p.zy, float2(b.x, b.y*0.2));
	return min(da,db);
}

float2 sdSierpinski(in float3 p, float b, int iterations, float3  offsetMod,
float4x4 globalTransform,  float scaleFactor, float4x4 rotate45){

	b = 2*b;
	p = mul(globalTransform, float4(p,1)).xyz;

	float2 d = float2(sdPyramid(p/b, sqrt(3)/2)*b, 0);

	float s = 1.0;

	for(int m = 0; m<iterations; m++){

		p.x = pMod(p.x, b*offsetMod.x * 0.5/s);
		p.y = pMod(p.y, b*offsetMod.y * (sqrt(3)/2)/s);
		p.z = pMod(p.z, b*offsetMod.z * 0.5/s);
		s*= scaleFactor * 2;

		float3 r = p * s;

		float c = (sdTriangleCross(float3(r.x, -r.y, r.z), b / sqrt(3))) / s;

		if(-c > d.x){
			d.x = -c;
			d = float2(d.x, m);
		}
	}
	return d;

}

float sdCylinder(float2 p, float c){
	return length(p) - c;
}

float sdCylinderCross(in float3 p, float b){
	float da = sdCylinder(p.xy, b);
	float db = sdCylinder(p.yz, b);
	float dc = sdCylinder(p.zx, b);

	return (min(da,min(db,dc)));
}

float2 sdMengerSphere(in float3 p, float b, int iterations, float3 offsetMod, 
float4x4 globalTransform, float scaleFactor){
	p = mul(globalTransform, float4(p,1)).xyz;

	float2 d = float2(sdSphere(p, float3(b,b,b)), 0);

	float s = 1.0;

	for(int m = 0; m<iterations; m++){

		p.x = pMod(p.x, b*offsetMod.x * 2/s);
		p.y = pMod(p.y, b*offsetMod.y * 2/s);
		p.z = pMod(p.z, b*offsetMod.z * 2/s);
		s*= scaleFactor * 3;

		float3 r = p * s;

		float c = (sdCylinderCross(r, b))/s;

		if(-c > d.x){
			d.x = -c;
			d = float2(d.x, m);
		}
	}
	return d;

}

float sdPlane(float3 p, float4x4 globalTransform){
	float plane = mul(globalTransform, float4(p,1)).x;
	return plane;
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
