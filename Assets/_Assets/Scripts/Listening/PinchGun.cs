using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PinchGun : MonoBehaviour
{
    [Header("Finger parameters")]
    [SerializeField] private Transform thumb;
    [SerializeField] private Transform index;

    [SerializeField][Range(0,0.1f)] private float pinchThreshold = 0.01f;

    [SerializeField] private GameObject maskObject;

    [Header("Lock parameters")]
    [SerializeField] private Transform objectToMove;
    [SerializeField] private float lockDetectionDistance = 1.5f;
    [SerializeField] private LayerMask destroyableObjectLayerMask;

    [Header("Eye parameters")]
    [SerializeField] private Transform leftEyeTransform;

    [Header("Lock parameters")]
    [SerializeField] private float lockDuration = 5f;
    private bool lockTemp = false;
    private float lockTempAlert = 0;

    public static PinchGun instance;

    private Collider[] hitColliders;

    /*private Camera mainCamera;
    private float initialFOV = 90;
    [SerializeField] private float FOVDelta = 5;*/
    // Start is called before the first frame update

    private void Awake()
    {
        instance = this;
    }

    void Start()
    {
        /*mainCamera = Camera.main;
        initialFOV = mainCamera.fieldOfView;*/
    }

    // Update is called once per frame
    void Update()
    {
        if (CheckPinch() && WorldManager.instance.GetCurrentWorldType() == WorldType.REAL)
        {
            maskObject.SetActive(true);
            hitColliders = Physics.OverlapSphere(objectToMove.position, lockDetectionDistance, destroyableObjectLayerMask);
            if (hitColliders.Length != 0 && Physics.Raycast(leftEyeTransform.position, leftEyeTransform.forward, Mathf.Infinity, destroyableObjectLayerMask))
            {
                if (!lockTemp)
                {
                    lockTemp = true;
                    lockTempAlert = Time.time + lockDuration;
                }
                //mainCamera.fieldOfView = Mathf.Lerp(mainCamera.fieldOfView, initialFOV - FOVDelta, Time.deltaTime);
            }

            else
            {
                lockTemp = false;
            }
        }

        else
        {
            lockTemp = false;
            maskObject.SetActive(false);
        }

        if (lockTemp && Time.time > lockTempAlert)
        {
            foreach (Collider collider in hitColliders)
            {
                collider.gameObject.SetActive(false);
            }
            //mainCamera.fieldOfView = initialFOV;
            lockTemp = false;
            TransfoManager.instance.CheckState();
        }
    }

    private bool CheckPinch()
    {
        if (Vector3.Distance(thumb.position, index.position) < pinchThreshold)
        {
            return true;
        }
        return false;
    }

    public void SetLockDuration(float newDuration)
    {
        lockDuration = newDuration;
    }

    public void SetLockDistance(float newDistance)
    {
       lockDetectionDistance = newDistance;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(leftEyeTransform.position, leftEyeTransform.position + 10 * leftEyeTransform.forward);
        Gizmos.DrawWireSphere(objectToMove.position, lockDetectionDistance);
    }
}
