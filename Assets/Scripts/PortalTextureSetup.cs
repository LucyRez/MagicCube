using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalTextureSetup : MonoBehaviour
{

    public Camera cameraCube;
    public Camera cameraPyramid;
    public Camera cameraSphere;
    public Camera cameraSlice;

    public Material cameraMatCube;
    public Material cameraMatPyramid;
    public Material cameraMatSphere;
    public Material cameraMatSlice;

    // Start is called before the first frame update
    void Start()
    {
        if(cameraCube.targetTexture != null){
            cameraCube.targetTexture.Release();
        }

        cameraCube.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
        cameraMatCube.mainTexture = cameraCube.targetTexture;

        if(cameraPyramid.targetTexture != null){
            cameraPyramid.targetTexture.Release();
        }

        cameraPyramid.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
        cameraMatPyramid.mainTexture = cameraPyramid.targetTexture;

        if(cameraSphere.targetTexture != null){
            cameraSphere.targetTexture.Release();
        }

        cameraSphere.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
        cameraMatSphere.mainTexture = cameraSphere.targetTexture;

        if(cameraSlice.targetTexture != null){
            cameraSlice.targetTexture.Release();
        }

        cameraSlice.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
        cameraMatSlice.mainTexture = cameraSlice.targetTexture;
    }

}
