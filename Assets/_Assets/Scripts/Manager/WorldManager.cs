using System.Collections;
using System.Collections.Generic;
using System.Linq;
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

    [Header("Renderer References")]
    [SerializeField]
    private Transform sceneParent;
    [SerializeField]
    private List<Renderer> extraRenderer;
    [SerializeField]
    private float transitionTime;

    [Header("World Reference")]
    [SerializeField]
    private GameObject realWorldReference;
    [SerializeField]
    private NetWorldManager netWorldReference;

    [Header("DEBUG ONLY")]
    [SerializeField]
    private bool debugMode;
    [SerializeField]
    private Color realWorldColor;
    [SerializeField]
    private Color netWorldColor;

    public static WorldManager instance;

    private List<Renderer> renderersList;

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        renderersList = sceneParent.GetComponentsInChildren<Renderer>().ToList();
        renderersList.AddRange(extraRenderer);

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
        if (debugMode)
        {
            StartCoroutine(MaterialsLerp(realWorldColor));
        }
        realWorldReference.SetActive(true);
    }

    private void UnloadRealWorld()
    {
        Debug.Log("UNLOAD REAL WORLD NOT YET IMPLEMENTED");
        realWorldReference.SetActive(false);
    }

    private void LoadNetWorld()
    {
        Debug.Log("LOAD NET WORLD NOT YET IMPLEMENTED");
        if (debugMode)
        {
            StartCoroutine(MaterialsLerp(netWorldColor));
        }
        netWorldReference.Load(transitionTime);
    }

    private void UnloadNetWorld()
    {
        Debug.Log("UNLOAD NET WORLD NOT YET IMPLEMENTED");
        netWorldReference.Unload(transitionTime);
    }

    private IEnumerator MaterialsLerp(Color newColor)
    {
        // DEBUG LERP
        Color currentColor = currentWorld == WorldType.REAL ? realWorldColor : netWorldColor;
        float t = 0f;
        while (t < transitionTime)
        {
            Color tempColor = Color.Lerp(currentColor, newColor, t / transitionTime);

            foreach(Renderer r in renderersList)
            {
                r.material.color = tempColor;
            }

            yield return new WaitForEndOfFrame();
            t += Time.deltaTime;
        }

        foreach (Renderer r in renderersList)
        {
            r.material.color = newColor;
        }
    }
}