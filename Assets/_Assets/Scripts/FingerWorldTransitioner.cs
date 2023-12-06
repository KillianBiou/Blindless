using OVR.OpenVR;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FingerWorldTransitioner : MonoBehaviour
{
    [Header("Fingers")]
    [SerializeField] private Transform thumb1;
    [SerializeField] private Transform thumb2;
    [SerializeField] private Transform index1;
    [SerializeField] private Transform index2;

    [SerializeField][Range(0, 0.1f)] private float fingerCollisionThreshold = 0.05f;

    [Header("Lock parameters")]
    [SerializeField] private float lockDuration = 2f;
    private bool lockTemp = false;
    private float lockTempAlert = 0;
    private bool canChangeWorld = false;
    [SerializeField] private Transform eyeTransform;
    [SerializeField] private float frustrumThreshold = 0.7f;

    public static FingerWorldTransitioner instance;
    private bool firstNet = true;

    private void Awake()
    {
        instance = this;
    }

    // Update is called once per frame
    void Update()
    {
        if (!CheckIfFingersInFrustrum())
        {
            return;
        }

        if (CheckFingerFormation())
        {
            if (!lockTemp)
            {
                lockTemp = true;
                lockTempAlert = Time.time + lockDuration;
            }
        }
        else
        {
            if (canChangeWorld && !NetWorldManager.Instance.AreDeamonsTriggered())
            {
                WorldManager.instance.CycleWorld();
                canChangeWorld = false;
                if (!firstNet)
                {
                    firstNet = true;
                    OverlayManager.instance.HideNetTuto();
                }
            }
            lockTemp = false;
        }

        if (lockTemp && Time.time > lockTempAlert)
        {
            canChangeWorld = true;
            lockTemp = false;
        }
    }

    private bool CheckFingerFormation()
    {
        float thumbDistance = Vector3.Distance(thumb1.position, thumb2.position);
        float indexDistance = Vector3.Distance(index1.position, index2.position);

        if (thumbDistance < fingerCollisionThreshold && indexDistance < fingerCollisionThreshold)
        {
            return true;
        }
        return false;
    }

    private bool CheckIfFingersInFrustrum()
    {
        Vector3 handsDirection = (thumb1.position - eyeTransform.position).normalized;
        float dot = Vector3.Dot(handsDirection, eyeTransform.forward);
        if (dot > frustrumThreshold)
        {
            return true;
        }
        return false;
    }

    public void SetFirstNet(bool value)
    {
        firstNet = value;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawLine(eyeTransform.position, eyeTransform.position + eyeTransform.forward);
        Gizmos.DrawLine(eyeTransform.position, thumb1.position);
    }
}
