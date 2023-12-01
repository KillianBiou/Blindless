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

    private bool hasWin = false;


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
                transfoText.text = $"{transfoList.Count - count} / firewall remaining.";
                return;
            }
            count++;
        }
        transfoText.text = $"{transfoList.Count - count} / firewall remaining.";
        Win();
    }

    public void StartTransfo()
    {
        transfoText.gameObject.SetActive(true);
        foreach (GameObject t in transfoList)
        {
            t.SetActive(true);
        }
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
        NetWorldManager.Instance.EscalatePrivilege();
        hasWin = true;
        Debug.Log("transfo win");
        transfoBaseText.text = "Suffisant privileges, launch escalation for root.";
    }

    public void LaunchEscalation()
    {
    }
}
