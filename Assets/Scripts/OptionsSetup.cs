using System;
using System.Collections.Generic;
using UnityEngine;

public class OptionsSetup : MonoBehaviour
{
    private OptionsController options;
    public RaymarchCamera cameraCube;
    public RaymarchCamera cameraPyramid;
    public RaymarchCamera cameraSphere;
    public RaymarchCamera cameraSlice;

    // Start is called before the first frame update
    void Start()
    {
        options = GameObject.FindWithTag("Options").GetComponent<OptionsController>();

        bool shadow = options.shadowIsOn;
        cameraCube.useShadow = shadow;
        cameraPyramid.useShadow = shadow;
        cameraSphere.useShadow = shadow;
        cameraSlice.useShadow = shadow;

        int iterations = int.Parse(options.iterations.ToString());
        cameraCube.iterations = iterations;
        cameraPyramid.iterations = iterations;
        cameraSphere.iterations = iterations;
        cameraSlice.iterations = iterations;

        float accuracy = options.accuracy;

        cameraCube.precision = accuracy;
        cameraPyramid.precision = accuracy;
        cameraSlice.precision = accuracy;
        cameraSphere.precision = accuracy;
    }
}
