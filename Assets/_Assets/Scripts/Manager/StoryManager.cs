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

    [SerializeField] private Light mainLight;
    [SerializeField] private GameObject UIHolder;
    [SerializeField] private GameObject UICreditHolder;

    [SerializeField] private List<AudioSource> audioSources;

    [SerializeField] private bool debug = false;

    public static StoryManager Instance;
    // Start is called before the first frame update
    private bool hasStopped = false;

    private void Awake()
    {
        Instance = this;
    }

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
        {
            PlayIntro();
        }
        else
        {
            StopIntro();
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (!debug && !hasStopped && !audioSource.isPlaying)
        {
            StopIntro();
        }
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            StartOutro();
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
        mainLight.gameObject.SetActive(false);
    }

    private void StopIntro()
    {
        hasStopped = true;
        //cam.gameObject.SetActive(true);
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
        mainLight.gameObject.SetActive(true);
        GetComponent<TutorialManager>().StartTuto();
    }

    public void StartOutro()
    {
        mainLight.gameObject.SetActive(false);
        UIHolder.SetActive(false);
        UICreditHolder.SetActive(true);
        MonologueManager.Instance.PlayShooting();
        StartCoroutine(CloseApplication(25f));
    }

    private IEnumerator CloseApplication(float delay)
    {
        yield return new WaitForSeconds(delay);
        Application.Quit();
    }
}
