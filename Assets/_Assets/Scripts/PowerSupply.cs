using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerSupply : MonoBehaviour
{

    [SerializeField] private AudioSource staticAudioSource;
    [SerializeField] private AudioClip destroySound;
    [SerializeField] [Range(0f, 1f)] private float destroySoundVolume;

    private void OnDisable()
    {
        DestroyElement();
    }

    public void DestroyElement()
    {
        if(staticAudioSource)
            Destroy(staticAudioSource);
        if (destroySound)
        {
            GameObject go = Instantiate(new GameObject(), transform.position, transform.rotation);
            AudioSource au = go.AddComponent<AudioSource>();

            au.clip = destroySound;
            au.volume = destroySoundVolume;
            au.Play();

            Destroy(go, destroySound.length);
            Destroy(this);
        }
    }
}
