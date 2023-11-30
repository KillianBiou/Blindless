using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class TransfoManager : MonoBehaviour
{
    [SerializeField] private List<GameObject> transfoList = new List<GameObject>();

    public static TransfoManager instance;

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
        foreach (GameObject go in transfoList)
        {
            if (go.activeSelf)
            {
                return;
            }
        }
        Win();
    }

    public void StartTransfo()
    {
        foreach (GameObject t in transfoList)
        {
            t.SetActive(true);
        }
    }
    public void StopTransfo()
    {
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
