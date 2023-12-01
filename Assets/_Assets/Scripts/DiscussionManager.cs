using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class DiscussionManager : MonoBehaviour
{
    [SerializeField][Range(0f,1000f)] private float lowCutoffFrequency = 250f;
    [SerializeField][Range(1000f,20000f)] private float highCutoffFrequency = 1500f;
    [SerializeField][Range(0f,10f)] private float cutoffFrequencyBlend = 1f;
    private AudioLowPassFilter lowPassFilter;

    private bool muffled = true;

    private AudioSource mAudioSource;
    // Start is called before the first frame update
    void Start()
    {
        mAudioSource = GetComponent<AudioSource>();

        if (!TryGetComponent<AudioLowPassFilter>(out lowPassFilter))
        {
            lowPassFilter = gameObject.AddComponent<AudioLowPassFilter>();
        }

        lowPassFilter.cutoffFrequency = lowCutoffFrequency;
    }

    // Update is called once per frame
    void Update()
    {
        float currentCutoffFrequency = lowPassFilter.cutoffFrequency;

        if (!muffled)
        {
            lowPassFilter.cutoffFrequency = Mathf.Lerp(currentCutoffFrequency, highCutoffFrequency, Time.deltaTime * cutoffFrequencyBlend);
        }

        else
        {
            lowPassFilter.cutoffFrequency = Mathf.Lerp(currentCutoffFrequency, lowCutoffFrequency, Time.deltaTime * 10);
        }
    }

    public void MuffleDiscussion(bool value)
    {
        if (!value)
        {
            mAudioSource.Stop();
            mAudioSource.Play();
        }

        muffled = value;
    }
}
