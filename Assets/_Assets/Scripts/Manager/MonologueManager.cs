using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class MonologueManager : MonoBehaviour
{
    public static MonologueManager Instance;
    [SerializeField] private List<AudioClip> monologuesList;

    private AudioSource audioSource;

    [SerializeField] private GameObject overlayImage;
    // Start is called before the first frame update
    void Start()
    {
        Instance = this;
        audioSource = GetComponent<AudioSource>();
        overlayImage.SetActive(false);
    }

    public void PlayFindPasswordClip()
    {
        PlayClip(0);
    }
    public void PlayPasswordPassedClip()
    {
        PlayClip(1);
    }

    public void PlayTransformerDestroyedClip()
    {
        PlayClip(2);
    }

    public void PlayDeamonsAttackClip()
    {
        PlayClip(3);
    }

    public void PlayDeamonsVanishedClip()
    {
        PlayClip(4);
    }

    public void PlayShooting()
    {
        PlayClip(5);
    }

    private void PlayClip(int index)
    {
        audioSource.Stop();
        audioSource.clip = monologuesList[index];
        audioSource.Play();
        overlayImage.SetActive(true);
        StartCoroutine(WaitUntilClipEnds());
    }

    private IEnumerator WaitUntilClipEnds()
    {
        yield return new WaitUntil(() => audioSource.isPlaying == false );
        overlayImage.SetActive(false);
    }
}
