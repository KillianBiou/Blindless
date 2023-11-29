using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PinchDetector : MonoBehaviour
{
    [SerializeField] private Transform thumb;
    [SerializeField] private Transform index;

    [SerializeField][Range(0,0.1f)] private float pinchThreshold = 0.01f;

    [SerializeField] private GameObject maskObject;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (CheckPinch())
        {
            maskObject.SetActive(true);
        }

        else
        {
            maskObject.SetActive(false);
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
}
