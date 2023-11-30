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

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
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
            if (canChangeWorld)
            {
                WorldManager.instance.CycleWorld();
                canChangeWorld = false;
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
}
