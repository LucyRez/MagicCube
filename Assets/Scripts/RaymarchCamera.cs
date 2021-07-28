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

    public float maxDistance;

    public Color mainColor;

    public Vector4 sphere;
    public Vector4 box;
    public Vector3 modInterval;

    public Transform directionalLight;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        raymarchMaterial.SetMatrix("camFrustum", CameraFrustum(_camera));
        raymarchMaterial.SetMatrix("camToWorld", _camera.cameraToWorldMatrix);
        raymarchMaterial.SetFloat("maxDistance", maxDistance);
        raymarchMaterial.SetVector("sphere", sphere);
        raymarchMaterial.SetVector("box", box);
        raymarchMaterial.SetVector("modInterval", modInterval);
        raymarchMaterial.SetVector("lightDirection", directionalLight ? directionalLight.forward : Vector3.down);
        raymarchMaterial.SetColor("mainColor", mainColor);

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
