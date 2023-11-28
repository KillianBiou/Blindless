using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestFace : MonoBehaviour
{
    private OVRFaceExpressions exp;

    private void Start()
    {
        exp = GetComponent<OVRFaceExpressions>();
    }

    private void Update()
    {
        Debug.Log(exp.FaceTrackingEnabled);
        Debug.Log(exp[OVRFaceExpressions.FaceExpression.EyesClosedR]);
    }
}
