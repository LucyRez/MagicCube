using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RaymarchCamera : SceneViewFilter
{
    [SerializeField]
    private Shader shader;

    private Material raymarchMat;

    private Camera cam;

    public Material raymarchMaterial
    {
        get
        {
            if (!raymarchMat && shader)
            {
                raymarchMat = new Material(shader);
                raymarchMat.hideFlags = HideFlags.HideAndDontSave; // Material shouldn't be disposed by garbage collector
            }
            return raymarchMat;
        }
    }

    public Camera _camera
    {
        get
        {
            if (!cam)
            {
                cam = GetComponent<Camera>();
            }

            return cam;
        }
    }

    public Transform directionalLight;
    public float maxDistance;
    public float precision;

    // bool values are converted to int
    public bool useShadow;
    public bool useModul;
    public bool drawMenger;
    public bool drawMengerSphere;
    public bool drawSierpinski;
    public bool drawMengerSlice;
    public int iterations;
    public float scaleFactor;
    public Vector3 modOffset;
    public Vector3 globalPosition;
    public Vector3 globalRotation;
    public float globalScale;
    public bool useSectionPlane;
    public Vector3 sectionPos;
    public Vector3 sectionRot;

    [HideInInspector]
    public int fractalType;
    private int usePlane;
    private int useMod;

    public Vector3 modInterval;
    public Color mainColor;
    public Color secondaryColor;

    [HideInInspector]
    public Matrix4x4 sectionTransform;
    [HideInInspector]
    public Matrix4x4 globalTransform;


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(drawMenger){
            fractalType = 1;
            raymarchMaterial.SetVector("modOffset", modOffset);
        }

        if(drawSierpinski){
            fractalType = 2;
        }

        if(drawMengerSphere){
            fractalType = 4;
        }

        if(drawMengerSlice){
            fractalType = 3;
            useSectionPlane = true;
        }

        if(useModul){
            useMod = 1;
            raymarchMaterial.SetVector("modInterval", modInterval);
        }else{
            useMod = 0;
        }

        if(useSectionPlane){
            usePlane = 1;
            sectionTransform = Matrix4x4.TRS(
                sectionPos,
                Quaternion.identity,
                Vector3.one
            );

            sectionTransform *= Matrix4x4.TRS(
                Vector3.zero, 
                Quaternion.Euler(sectionRot),
                Vector3.one
            );

            raymarchMaterial.SetMatrix("sectionTransform", sectionTransform.inverse);
        }else{
            usePlane = 0;
        }

        globalTransform = Matrix4x4.TRS(
            globalPosition,
            Quaternion.identity,
            Vector3.one
        );

        globalTransform *= Matrix4x4.TRS(
            Vector3.zero,
            Quaternion.Euler(globalRotation),
            Vector3.one
        );

        raymarchMaterial.SetMatrix("globalTransform", globalTransform.inverse);
        raymarchMaterial.SetVector("globalPosition", globalPosition);

        if(useShadow){
            raymarchMaterial.SetInt("useShadow", 1);
        }else{
            raymarchMaterial.SetInt("useShadow", 0);
        }

        if (!raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        raymarchMaterial.SetMatrix("camFrustum", CameraFrustum(_camera));
        raymarchMaterial.SetMatrix("camToWorld", _camera.cameraToWorldMatrix);
        raymarchMaterial.SetFloat("maxDistance", maxDistance);
        raymarchMaterial.SetFloat("precision", precision);
        raymarchMaterial.SetInt("iterations", iterations);
        
        raymarchMaterial.SetFloat("globalScale", globalScale);
        raymarchMaterial.SetFloat("scaleFactor", scaleFactor);
        raymarchMaterial.SetVector("lightDirection", directionalLight ? directionalLight.forward : Vector3.down);
        raymarchMaterial.SetColor("mainColor", mainColor);
        raymarchMaterial.SetColor("secondaryColor", secondaryColor);

        raymarchMaterial.SetInt("fractalType", fractalType);
        raymarchMaterial.SetInt("usePlane", usePlane);
        raymarchMaterial.SetInt("useMod", useMod);

        RenderTexture.active = destination;
        raymarchMaterial.SetTexture("_MainTex", source);

        GL.PushMatrix();
        GL.LoadOrtho();
        raymarchMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        //bottom left

        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);

        //bottom right

        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);

        //top right

        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);

        //top left

        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);


        GL.End();
        GL.PopMatrix();

    }

    private Matrix4x4 CameraFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 up = Vector3.up * fov;
        Vector3 right = Vector3.right * fov * cam.aspect;

        Vector3 topLeft = (-Vector3.forward - right + up);
        Vector3 topRight = (-Vector3.forward + right + up);
        Vector3 bottomRight = (-Vector3.forward + right - up);
        Vector3 bottomLeft = (-Vector3.forward - right - up);

        frustum.SetRow(0, topLeft);
        frustum.SetRow(1, topRight);
        frustum.SetRow(2, bottomRight);
        frustum.SetRow(3, bottomLeft);

        return frustum;
    }

}
