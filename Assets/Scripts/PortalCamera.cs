using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalCamera : MonoBehaviour
{
    public Transform playerCamera;

    public Transform portal;

    public Transform otherPortal;

    // Update is called once per frame
    void LateUpdate()
    {
        Vector3 playerOffset = playerCamera.position - otherPortal.position;
        transform.position = portal.position + playerOffset;

        float angularDifferenceRotation = Quaternion.Angle(portal.rotation, otherPortal.rotation);
        Quaternion portalRotationDifference = Quaternion.AngleAxis(angularDifferenceRotation, Vector3.up);
        Vector3 newCameraDirection = portalRotationDifference * playerCamera.forward;

        transform.rotation = Quaternion.LookRotation(newCameraDirection, Vector3.up);
    }
}
