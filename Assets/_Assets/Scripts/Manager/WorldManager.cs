using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum WorldType
{
    REAL = 0,
    NET = 1,

    UNKNOWN = 2
};

public class WorldManager : MonoBehaviour
{
    [Header("State")]
    [SerializeField]
    private WorldType currentWorld;

    public static WorldManager instance;

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        LoadRealWorld();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
            SwapWorld(WorldType.REAL);
        else if (Input.GetKeyDown(KeyCode.N))
            SwapWorld(WorldType.NET);
    }

    public void SwapWorld(WorldType newWorld)
    {
        if (newWorld == currentWorld)
            return;

        switch (newWorld)
        {
            case WorldType.REAL:
                LoadRealWorld();
                break;
            case WorldType.NET:
                LoadNetWorld();
                break;
            default:
                Debug.LogError("Unkown World Type");
                break;
        }

        UnloadOldWorld();
        currentWorld = newWorld;
    }

    private void UnloadOldWorld()
    {
        switch (currentWorld)
        {
            case WorldType.REAL:
                UnloadRealWorld();
                break;
            case WorldType.NET:
                UnloadNetWorld();
                break;
            default:
                Debug.LogError("Unkown World Type");
                break;
        }
    }

    private void LoadRealWorld()
    {
        Debug.Log("LOAD REAL WORLD NOT YET IMPLEMENTED");
    }

    private void UnloadRealWorld()
    {
        Debug.Log("UNLOAD REAL WORLD NOT YET IMPLEMENTED");
    }

    private void LoadNetWorld()
    {
        Debug.Log("LOAD NET WORLD NOT YET IMPLEMENTED");
    }

    private void UnloadNetWorld()
    {
        Debug.Log("UNLOAD NET WORLD NOT YET IMPLEMENTED");
    }
}