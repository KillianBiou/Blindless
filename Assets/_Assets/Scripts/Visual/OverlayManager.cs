using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OverlayManager : MonoBehaviour
{
    [Header("Tuto References")]
    [SerializeField]
    private GameObject targetTuto;
    [SerializeField]
    private GameObject netTuto;
    [SerializeField]
    private GameObject eyeTuto;

    private void Start()
    {
        targetTuto.SetActive(false);
        netTuto.SetActive(false);
        eyeTuto.SetActive(false);
    }

    public void ShowTargetTuto()
    {
        targetTuto.SetActive(true);
    }

    public void HideTargetTuto()
    {
        targetTuto.SetActive(false);
    }

    public void ShowNetTuto()
    {
        netTuto.SetActive(true);
    }

    public void HideNetTuto()
    {
        netTuto.SetActive(false);
    }

    public void ShowEyeTuto()
    {
        eyeTuto.SetActive(true);
    }

    public void HideEyeTuto()
    {
        eyeTuto.SetActive(false);
    }

    public IEnumerator FirstTrial(float duration)
    {
        ShowEyeTuto();
        yield return new WaitForSeconds(duration);
        HideEyeTuto();

        ShowNetTuto();
        yield return new WaitForSeconds(duration);
        HideEyeTuto();

        yield return null;
    }
}
