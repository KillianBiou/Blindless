using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NetWorldManager : MonoBehaviour
{

    private List<WorldItem> worldItems = new List<WorldItem>();
    public static NetWorldManager Instance;

    private void Awake()
    {
        Instance = this;
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
}
