using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class DiscussionManager : MonoBehaviour
{
    [SerializeField][Range(0,1000)] private float cutoffFrequency = 200;
    private AudioLowPassFilter lowPassFilter;

    private bool muffled = true;
    // Start is called before the first frame update
    void Start()
    {
        if (!TryGetComponent<AudioLowPassFilter>(out lowPassFilter))
        {
            lowPassFilter = gameObject.AddComponent<AudioLowPassFilter>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            muffled = !muffled;
        }

        if (muffled)
        {
            lowPassFilter.cutoffFrequency = cutoffFrequency;
        }

        else
        {
            lowPassFilter.cutoffFrequency = 2000;
        }
    }
}
