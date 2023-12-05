using Oculus.Interaction.PoseDetection.Debug;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StoryManager : MonoBehaviour
{
    [SerializeField] private List<AudioClip> dialogueAudioClips = new List<AudioClip>();
    private AudioSource audioSource;

    [SerializeField] private List<MonoBehaviour> scriptList;

    private AudioListener listener;

    private Camera cam;

    [SerializeField] private List<AudioSource> audioSources;

    [SerializeField] private bool debug = false;
    // Start is called before the first frame update
    void Start()
    {
        cam = Camera.main;
        if (!TryGetComponent<AudioSource>(out audioSource))
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }

        if (!TryGetComponent<AudioListener>(out listener))
        {
            listener = gameObject.AddComponent<AudioListener>();
        }
        audioSource.loop = false;
        
        if (!debug)
            PlayIntro();
    }

    // Update is called once per frame
    void Update()
    {
        if (!audioSource.isPlaying)
        {
            StopIntro();
        }
    }

    private void PlayIntro()
    {
        //cam.gameObject.SetActive(false);
        foreach( var script  in scriptList ) 
        {
            script.enabled = false;
        }

        foreach (var audio in audioSources ) 
        { 
        
            audio.enabled = false;
        }
        audioSource.clip = dialogueAudioClips[0];
        audioSource.Play();
    }

    private void StopIntro()
    {
        cam.gameObject.SetActive(true);
        foreach (var script in scriptList)
        {
            script.enabled = true;
        }
        foreach (var audio in audioSources)
        {

            audio.enabled = true;
        }
        audioSource.Stop();
        listener.enabled = false;
        audioSource.enabled = false;
    }
}
