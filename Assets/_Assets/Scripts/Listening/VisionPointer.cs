using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VisionPointer : MonoBehaviour
{
    [Header("Eyes")]
    [SerializeField]
    private Transform eyeTransform;
    [SerializeField]
    private Transform centerEye;

    [Header("Target Pose Lerp")]
    [SerializeField]
    private bool doLerp;
    [SerializeField]
    private float lerpSpeed;
    [SerializeField]
    private float snappingDistance;

    [Header("Raycast Info")]
    [SerializeField] private Transform objectToMove;
    [SerializeField] private LayerMask targetLayer;

    private Vector3 targetPos;

    // Update is called once per frame
    void FixedUpdate()
    {
        Ray ray = new Ray(eyeTransform.position, eyeTransform.forward);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, Mathf.Infinity, targetLayer))
        {
            targetPos = hit.point;
        }

        if (doLerp)
        {
            if(Vector3.Distance(targetPos, objectToMove.position) > snappingDistance)
            {
                objectToMove.position += (targetPos - objectToMove.position) * lerpSpeed;
            }
            else
                objectToMove.position = targetPos;
        }
        else
            objectToMove.position = targetPos;
    }
}
