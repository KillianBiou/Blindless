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

    public static OverlayManager instance;

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        targetTuto.SetActive(false);
        netTuto.SetActive(false);
        eyeTuto.SetActive(false);
    }

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.K)) {
            RequestTrial(0, 5f);
        }
        if(Input.GetKeyDown(KeyCode.L))
        {
            RequestTrial(1, 5f);
        }
        if(Input.GetKeyDown(KeyCode.M)) {
            RequestTrial(2, 5f);
        }
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

    public void RequestTrial(int number, float duration)
    {
        switch (number)
        {
            case 0:
                StartCoroutine(FirstTrial(duration));
                break;
            case 1:
                StartCoroutine(SecondTrial(duration));
                break;
            case 2:
                StartCoroutine(ThirdTrial(duration));
                break;
        }
    }

    private IEnumerator FirstTrial(float duration)
    {
        yield return new WaitForSeconds(.1f);

        ShowEyeTuto();
        yield return new WaitForSeconds(duration);
        HideEyeTuto();

        ShowNetTuto();
        yield return new WaitForSeconds(duration);
        HideNetTuto();
    }

    private IEnumerator SecondTrial(float duration)
    {
        yield return new WaitForSeconds(.1f);

        ShowNetTuto();
        yield return new WaitForSeconds(duration);
        HideNetTuto();

        ShowTargetTuto();
        yield return new WaitForSeconds(duration);
        HideTargetTuto();
    }

    private IEnumerator ThirdTrial(float duration)
    {
        yield return new WaitForSeconds(.1f);

        ShowTargetTuto();
        yield return new WaitForSeconds(duration);
        HideTargetTuto();
    }
}
