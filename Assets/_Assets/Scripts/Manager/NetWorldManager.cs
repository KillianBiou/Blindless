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
    private GameObject firstNetObjectives;
    [SerializeField]
    private GameObject secondNetObjectives;

    private List<WorldItem> worldItems = new List<WorldItem>();
    public static NetWorldManager Instance;

    private NetAccess currentAccess;

    private void Awake()
    {
        Instance = this;
        currentAccess = NetAccess.OUTSIDER;
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
        foreach (WorldItem item in worldItems) {
            item.OnLoad(duration);
        }
    }

    public void Unload(float duration)
    {
        foreach (WorldItem item in worldItems)
        {
            item.OnUnload(duration);
        }
    }

    public void ForceUnload()
    {
        foreach(WorldItem item in worldItems)
        {
            item.ForceUnload();
        }
    }

    public void EscalatePrivilege()
    {
        switch (currentAccess)
        {
            case NetAccess.OUTSIDER:
                currentAccess = NetAccess.GUEST;
                firstNetObjectives.SetActive(false);
                secondNetObjectives.SetActive(true);
                break;
            case NetAccess.GUEST:
                currentAccess = NetAccess.ADMINISTRATOR;
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

    public enum NetAccess
    {
        OUTSIDER,
        GUEST,
        ADMINISTRATOR,
        ROOT
    }
}
