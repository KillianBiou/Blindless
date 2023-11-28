using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(OVRFaceExpressions))]
public class VisionPointer : MonoBehaviour
{
    [Header("Eyes")]
    [SerializeField]
    private Transform eyeTransform;
    [SerializeField]
    private Transform centerEye;
    [SerializeField]
    [Range(0f, 1f)]
    private float closedEyeValue;
    [SerializeField]
    private float eyeClosedDuration;

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
    private OVRFaceExpressions faceExpression;
    private bool closedEye;
    private bool eyeTemp;
    private float eyeTimestamp;

    private void Start()
    {
        faceExpression = GetComponent<OVRFaceExpressions>();
        eyeTimestamp = Time.time - eyeClosedDuration;
    }

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
        CheckEyeState();

    }

    private void CheckEyeState()
    {
        if (faceExpression[OVRFaceExpressions.FaceExpression.EyesClosedR] >= closedEyeValue && faceExpression[OVRFaceExpressions.FaceExpression.EyesClosedR] >= closedEyeValue)
        {
            if (eyeTemp == false)
                eyeTimestamp = Time.time + eyeClosedDuration;

            eyeTemp = true;

            if (!closedEye && Time.time > eyeTimestamp)
            {
                TriggerClosedEye();
                closedEye = true;
            }
        }
        else if (faceExpression[OVRFaceExpressions.FaceExpression.EyesClosedR] < closedEyeValue && faceExpression[OVRFaceExpressions.FaceExpression.EyesClosedR] < closedEyeValue)
        {
            if (eyeTemp == false)
                eyeTimestamp = Time.time + eyeClosedDuration;

            eyeTemp = false;

            if (closedEye && Time.time > eyeTimestamp)
            {
                TriggerOpenEye();
                closedEye = false;
            }
        }
    }

    private void TriggerClosedEye()
    {
        Debug.Log("Eye Closed");
    }

    private void TriggerOpenEye()
    {
        Debug.Log("Eye Openeed");
    }
}
