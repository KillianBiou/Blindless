using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;
using static System.TimeZoneInfo;

public class FadeOutNetWorldItem : MonoBehaviour, WorldItem
{
    List<TextMeshProUGUI> textList = new List<TextMeshProUGUI>();
    List<Image> imageList = new List<Image>();
    List<Renderer> renderersList = new List<Renderer>();
    [SerializeField]
    private List<GameObject> listToDisable;
    [SerializeField]
    private OVRVirtualKeyboard ovrK;

    protected void Start()
    {
        NetWorldManager.Instance.Register(this);

        textList.AddRange(transform.GetComponentsInChildren<TextMeshProUGUI>());
        imageList.AddRange(transform.GetComponentsInChildren<Image>());
        renderersList.AddRange(transform.GetComponentsInChildren<Renderer>());
    }

    public void OnLoad(float duration)
    {
        StartCoroutine(StartFade(duration, 0f, 1f));
    }

    public void OnUnload(float duration)
    {
        StartCoroutine(StartFade(duration, 1f, 0f));
    }

    private IEnumerator StartFade(float duration, float baseAlpha, float endAlpha)
    {
        float t = 0f;
        while (t < duration)
        {
            float tempAlpha = Mathf.Lerp(baseAlpha, endAlpha, t / duration);

            foreach (TextMeshProUGUI text in textList)
            {
                Color tempColor = text.color;
                tempColor.a = tempAlpha;
                text.color = tempColor;
            }
            foreach (Image image in imageList)
            {
                Color tempColor = image.color;
                tempColor.a = tempAlpha;
                image.color = tempColor;
            }

            foreach (Renderer mesh in renderersList)
            {
                Color tempColor = mesh.material.color;
                tempColor.a = tempAlpha;
                mesh.material.color = tempColor;
            }

            yield return new WaitForEndOfFrame();
            t += Time.deltaTime;
        }
        foreach (TextMeshProUGUI text in textList)
        {
            Color tempColor = text.color;
            tempColor.a = endAlpha;
            text.color = tempColor;
        }
        foreach (Image image in imageList)
        {
            Color tempColor = image.color;
            tempColor.a = endAlpha;
            image.color = tempColor;
        }

        foreach (Renderer mesh in renderersList)
        {
            Color tempColor = mesh.material.color;
            tempColor.a = endAlpha;
            mesh.material.color = tempColor;
        }

        if(endAlpha == 0)
        {
            foreach (GameObject go in listToDisable)
            {
                go.SetActive(false);
            }
        }
        else
        {
            foreach (GameObject go in listToDisable)
            {
                go.SetActive(true);
            }
        }
    }

    public void ForceUnload()
    {
        foreach (TextMeshProUGUI text in textList)
        {
            Color tempColor = text.color;
            tempColor.a = 0;
            text.color = tempColor;
        }
        foreach (Image image in imageList)
        {
            Color tempColor = image.color;
            tempColor.a = 0;
            image.color = tempColor;
        }

        foreach (Renderer mesh in renderersList)
        {
            Color tempColor = mesh.material.color;
            tempColor.a = 0;
            mesh.material.color = tempColor;
        }
        foreach (GameObject go in listToDisable)
        {
            go.SetActive(false);
        }
        if (ovrK)
        {
        }
    }
}
