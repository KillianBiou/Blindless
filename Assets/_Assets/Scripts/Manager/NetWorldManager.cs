using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class NetWorldManager : MonoBehaviour
{
    [Header("References")]
    [SerializeField]
    private TextMeshProUGUI currentAccessText;
    [SerializeField]
    private Transform keyboard;

    [SerializeField]
    private GameObject netStatus;
    [SerializeField]
    private GameObject firstNetObjectives;
    [SerializeField]
    private GameObject secondNetObjectives;
    [SerializeField]
    private GameObject thirdNetObjectives;

    private List<WorldItem> worldItems = new List<WorldItem>();
    public static NetWorldManager Instance;

    private NetAccess currentAccess;
    private bool triggerDaemon = false;
    private Vector3 basePas;
    private GameObject currentHolder;

    private void Awake()
    {
        Instance = this;
        currentAccess = NetAccess.OUTSIDER;
        basePas = keyboard.position;
        currentHolder = firstNetObjectives;
        UpdateText();
    }

    private void Update()
    {
        if(Input.GetKeyUp(KeyCode.W)) {
            EscalatePrivilege();
        }
    }

    public void Register(WorldItem item)
    {
        worldItems.Add(item);
    }

    public void Load(float duration)
    {
        currentHolder.SetActive(true);
        netStatus.SetActive(true);

        if (!triggerDaemon && currentAccess == NetAccess.ADMINISTRATOR)
        {
/*            triggerDaemon = true;
            DeamonManager.instance.StartGame();*/
        }
        else
        {
            ShowKeyboard();
        }
    }

    public void Unload(float duration)
    {
        /*foreach (WorldItem item in worldItems)
        {
            item.OnUnload(duration);
        }*/
        foreach(Transform g in transform)
        {
            g.gameObject.SetActive(false);
        }
        netStatus.SetActive(false);
        HideKeyboard();
    }

    public void ForceUnload()
    {
        /*foreach(WorldItem item in worldItems)
        {
            item.ForceUnload();
        }*/
        foreach (Transform g in transform)
        {
            g.gameObject.SetActive(false);
        }
        netStatus.SetActive(false);
        HideKeyboard();
    }

    public void EscalatePrivilege()
    {
        switch (currentAccess)
        {
            case NetAccess.OUTSIDER:
                currentAccess = NetAccess.GUEST;
                firstNetObjectives.SetActive(false);
                secondNetObjectives.SetActive(true);
                currentHolder = secondNetObjectives;
                break;
            case NetAccess.GUEST:
                currentAccess = NetAccess.ADMINISTRATOR;
                secondNetObjectives.SetActive(false);
                currentHolder = thirdNetObjectives;
                DeamonManager.instance.StartGame();
                break;
            case NetAccess.ADMINISTRATOR:

                currentAccess = NetAccess.ROOT;
                break;
            default:
                break;
        }
        UpdateText();
    }

    private void UpdateText()
    {
        switch (currentAccess)
        {
            case NetAccess.OUTSIDER:
                currentAccessText.text = "OUTSIDER";
                break;
            case NetAccess.GUEST:
                currentAccessText.text = "GUEST";
                break;
            case NetAccess.ADMINISTRATOR:
                currentAccessText.text = "ADMINISTRATOR";
                break;
            case NetAccess.ROOT:
                currentAccessText.text = "ROOT";
                break;
        }
    }

    public void CommuteNetStatus()
    {
        if (currentAccessText.gameObject.activeInHierarchy)
        {
            currentAccessText.transform.parent.gameObject.SetActive(false);
        }
        else
        {
            currentAccessText.transform.parent.gameObject.SetActive(true);
        }
    }

    private void ShowKeyboard()
    {
        if(keyboard)
            keyboard.position = basePas;
    }
    private void HideKeyboard()
    {
        if(keyboard)
            keyboard.position = basePas + Vector3.down * 100f;
    }

    public void DeleteKeyboard()
    {
        Destroy(keyboard.gameObject);
    }


    public enum NetAccess
    {
        OUTSIDER,
        GUEST,
        ADMINISTRATOR,
        ROOT
    }

    public bool AreDeamonsTriggered()
    {
        return triggerDaemon;
    }

    public NetAccess GetCurrentAccess()
    {
        return currentAccess;
    }

    public void SetDeamonTrigger(bool value)
    {
        triggerDaemon = value;
    }
}
