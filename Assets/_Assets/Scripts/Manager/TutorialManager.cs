using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialManager : MonoBehaviour
{
    [Header("Tutorial Parameters")]
    [SerializeField]
    private float initialDelay;
    [SerializeField]
    private float minDelayTarget;

    public static TutorialManager instance;

    private bool hasStarted = false;
    private bool start = false;
    private bool isDisplayed = false;

    private bool closedEyes = false;
    private bool usedNetGesture = false;
    private bool pinchedFinger = false;
    private bool deamonKilled = false;
    private bool transfomerDestroyed = false;

    private float timestamp = 0f;

    private int currentState = 0;

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        //StartCoroutine(InitialDelay());
    }

    private void Update()
    {
        if (start)
        {
            StartCoroutine(InitialDelay());
            start = false;
        }
        if (hasStarted)
        {
            if(isDisplayed == false)
            {
                switch (currentState)
                {
                    case 0:
                        OverlayManager.instance.ShowNetTuto();
                        isDisplayed = true;
                        FingerWorldTransitioner.instance.SetCanChange(true);
                        break;
                    case 1:
                        if (WorldManager.instance.GetCurrentWorldType() == WorldType.REAL)
                        {
                            OverlayManager.instance.ShowEyeTuto();
                            isDisplayed = true;
                        }
                        break;
                    case 2:
                        if (WorldManager.instance.GetCurrentWorldType() == WorldType.REAL && TransfoManager.instance.HasStarted())
                        {
                            OverlayManager.instance.ShowTargetTuto();
                            isDisplayed = true;
                            timestamp = Time.time;
                        }
                        break;
                    case 3:
                        if (NetWorldManager.Instance.AreDeamonsTriggered())
                        {
                            OverlayManager.instance.ShowTargetTuto();
                            isDisplayed = true;
                        }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                switch (currentState)
                {
                    case 0:
                        if (usedNetGesture)
                        {
                            MonologueManager.Instance.PlayFindPasswordClip();
                            OverlayManager.instance.HideNetTuto();
                            currentState++;
                            isDisplayed = false;
                        }
                        break;
                    case 1:
                        if (closedEyes)
                        {
                            OverlayManager.instance.HideEyeTuto();
                            currentState++;
                            isDisplayed = false;
                        }
                        break;
                    case 2:
                        if (transfomerDestroyed)
                        {
                            OverlayManager.instance.HideTargetTuto();
                            currentState++;
                            isDisplayed = false;
                        }
                        break;
                    case 3:
                        if (deamonKilled)
                        {
                            OverlayManager.instance.HideTargetTuto();
                            currentState++;
                            isDisplayed = false;
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        closedEyes = false;
        usedNetGesture = false; 
        pinchedFinger = false;
        deamonKilled = false;
        transfomerDestroyed = false;
    }

    public void StartTuto()
    {
        start = true;
    }

    private IEnumerator InitialDelay()
    {
        yield return new WaitForSeconds(initialDelay);
        hasStarted = true;
    }

    public void CloseEye()
    {
        closedEyes = true;
    }

    public void NetGesture()
    {
        usedNetGesture = true;
    }

    public void PinchFinger()
    {
        pinchedFinger = true;
    }

    public void TransformerDestroyed()
    {
        transfomerDestroyed = true;
    }

    public void DeamonKilled()
    {
        deamonKilled = true;
    }
}
