using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestEye : MonoBehaviour
{
    [Header("Eye References")]
    [SerializeField]
    private OVREyeGaze leftEye;
    [SerializeField]
    private OVREyeGaze rightEye;

    private void Update()
    {
       /* if(leftEye)
        {
            Debug.Log("Left Eye Confidence : " + leftEye._currentEyeGazesState.EyeGazes[0].IsValid);
        }
        if (rightEye)
        {
            Debug.Log("Left Eye Confidence : " + rightEye._currentEyeGazesState.EyeGazes[0].IsValid);
        }*/
    }
}
