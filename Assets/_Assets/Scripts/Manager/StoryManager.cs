using Oculus.Interaction.PoseDetection.Debug;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StoryManager : MonoBehaviour
{
    [SerializeField] private List<AudioClip> dialogueAudioClips = new List<AudioClip>();
    private AudioSource audioSource;

    [SerializeField] private GameObject player;

    private AudioListener listener;
    // Start is called before the first frame update
    void Start()
    {
        if (!TryGetComponent<AudioSource>(out audioSource))
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }

        if (!TryGetComponent<AudioListener>(out listener))
        {
            listener = gameObject.AddComponent<AudioListener>();
        }
        audioSource.loop = false;

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
        player.SetActive(false);
        audioSource.clip = dialogueAudioClips[0];
        audioSource.Play();
    }

    private void StopIntro()
    {
        player.SetActive(true);
        audioSource.Stop();
    }
}
