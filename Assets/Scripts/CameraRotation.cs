using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotation : MonoBehaviour
{
    public float speed;

    public GameObject centralObject;
    private Transform currentCamera;

    // Start is called before the first frame update
    void Start()
    {
        currentCamera = GetComponent<Transform>();
        currentCamera.LookAt(centralObject.GetComponent<Transform>());
    }

    // Update is called once per frame
    void Update()
    {
        transform.RotateAround (centralObject.transform.position, Vector3.up, speed * Time.deltaTime);
    }
}
