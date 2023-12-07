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
    [SerializeField] private TMP_Text transfoBaseText;
    [SerializeField] private GameObject helpButton;

    private bool hasWin = false;
    private bool hasStarted = false;


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
                transfoText.text = $"{transfoList.Count - count} / {transfoList.Count} remaining.";
                return;
            }
            count++;
        }
        transfoText.text = $"{transfoList.Count - count} / {transfoList.Count} firewall remaining.";
        Win();
    }

    public void StartTransfo()
    {
        OverlayManager.instance.RequestTrial(1, 5f);
        transfoText.gameObject.SetActive(true);
        foreach (GameObject t in transfoList)
        {
            t.SetActive(true);
        }
        hasStarted = true;
        CheckState();
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
        if (!hasWin)
        {
            MonologueManager.Instance.PlayTransformerDestroyedClip();
            helpButton.SetActive(true);
        }
        hasWin = true;
        Debug.Log("transfo win");
        transfoBaseText.text = "Suffisant privileges, you can launch escalation for root.";
    }

    public bool HasStarted()
    {
        return hasStarted;
    }

    public bool HasWon()
    {
        return hasWin;
    }
}
