using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;

public class TransfoManager : MonoBehaviour
{
    [SerializeField] private List<GameObject> transfoList = new List<GameObject>();

    public static TransfoManager instance;

    [SerializeField] private TMP_Text transfoText;

    private void Awake()
    {
        if (instance == null)
            instance = this;
    }

    private void Start()
    {
        StopTransfo();
    }

    public void CheckState()
    {
        int count = 0;
        foreach (GameObject go in transfoList)
        {
            if (go.activeSelf)
            {
                transfoText.text = $"{count} / {transfoList.Count}";
                return;
            }
            count++;
        }
        transfoText.text = $"{count} / {transfoList.Count}";
        Win();
    }

    public void StartTransfo()
    {
        transfoText.gameObject.SetActive(true);
        CheckState();
        foreach (GameObject t in transfoList)
        {
            t.SetActive(true);
        }
    }
    public void StopTransfo()
    {
        transfoText.gameObject.SetActive(false);
        foreach (GameObject t in transfoList)
        {
            t.SetActive(false);
        }
    }

    private void Win()
    {
        Debug.Log("transfo win");
    }
}
