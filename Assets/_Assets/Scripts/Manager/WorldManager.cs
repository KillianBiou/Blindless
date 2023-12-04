using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;

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
    [SerializeField]
    private float transitionTimeToReal;
    public float materialColorSpeed;

    [Header("World Reference")]
    [SerializeField]
    private GameObject realWorldReference;
    [SerializeField]
    private NetWorldManager netWorldReference;

    [Header("Net Color Parameters")]
    [SerializeField]
    [ColorUsage(true, true)]
    private Color baseColor;
    [SerializeField]
    [ColorUsage(true, true)]
    private Color baseColorTwo;
    [SerializeField]
    [ColorUsage(true, true)]
    private Color triggeredColor;
    [SerializeField]
    [ColorUsage(true, true)]
    private Color triggeredColorTwo;
    [SerializeField]
    [ColorUsage(true, true)]
    private Color realAmbiant;
    [SerializeField]
    [ColorUsage(true, true)]
    private Color netAmbiant;
    [SerializeField]
    private float shrinkExpandFactor;

    [Header("DEBUG ONLY")]
    [SerializeField]
    private bool debugMode;
    [SerializeField]
    private Color realWorldColor;
    [SerializeField]
    private Color netWorldColor;

    public static WorldManager instance;

    private bool triggerCommutator = false;
    private List<Renderer> renderersList;
    private bool init = true;

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        renderersList = sceneParent.GetComponentsInChildren<Renderer>().ToList();
        //renderersList.AddRange(extraRenderer);

        foreach(Renderer r in renderersList)
        {
            NetShaderAnimation temp = r.AddComponent<NetShaderAnimation>();
            temp.Setup(baseColor, baseColorTwo, triggeredColor, triggeredColorTwo);
        }

        renderersList.AddRange(extraRenderer);

        LoadRealWorld();
        netWorldReference.ForceUnload();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
            SwapWorld(WorldType.REAL);
        else if (Input.GetKeyDown(KeyCode.N))
            SwapWorld(WorldType.NET);
        else if (Input.GetKeyDown(KeyCode.T))
            TriggerNet();

    }

    public void CycleWorld()
    {
        switch (currentWorld)
        {
            case WorldType.REAL:
                SwapWorld(WorldType.NET);
                break;
            case WorldType.NET:
                SwapWorld(WorldType.REAL);
                break;
            default:
                Debug.Log("Unknown Error while cycling worlds");
                break;
        }
    }

    private void SwapWorld(WorldType newWorld)
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
        if (!init)
        {
            if (debugMode)
            {
                StartCoroutine(MaterialsLerpDebug(realWorldColor));
            }
            else
            {
                StartCoroutine(ToRealLerp());
            }

            foreach (Renderer temp in renderersList)
            {
                NetShaderAnimation nsa = temp.GetComponent<NetShaderAnimation>();
                nsa.SetDoLerp(false);
            }
        }
        if (realWorldReference)
            realWorldReference.SetActive(true);

        init = false;
    }

    private void UnloadRealWorld()
    {
        Debug.Log("UNLOAD REAL WORLD NOT YET IMPLEMENTED");
        if(realWorldReference)
            realWorldReference.SetActive(false);
    }

    private void LoadNetWorld()
    {
        Debug.Log("LOAD NET WORLD NOT YET IMPLEMENTED");
        if (debugMode)
        {
            StartCoroutine(MaterialsLerpDebug(netWorldColor));
        }
        else
        {
            StartCoroutine(ToNetLerp());
        }

        foreach (Renderer temp in renderersList)
        {
            NetShaderAnimation nsa;
            if(temp.TryGetComponent<NetShaderAnimation>(out nsa))
                nsa.SetDoLerp(true);
        }

        if (netWorldReference)
        {
            netWorldReference.Load(transitionTime);
        }
    }

    private void UnloadNetWorld()
    {
        Debug.Log("UNLOAD NET WORLD NOT YET IMPLEMENTED");
        if (netWorldReference)
            netWorldReference.Unload(transitionTime);
    }

    public void TriggerNet() 
    {
        triggerCommutator = !triggerCommutator;
        foreach (Renderer temp in renderersList)
        {
            NetShaderAnimation nsa;
            if (temp.TryGetComponent<NetShaderAnimation>(out nsa))
                nsa.SetDoLerp(false);
        }

        Animator sceneAnimator = sceneParent.GetComponent<Animator>();
        sceneAnimator.SetFloat("Speed", shrinkExpandFactor);
        sceneAnimator.SetTrigger(triggerCommutator ? "Expand" : "Shrink");
    }

    private IEnumerator ToNetLerp()
    {
        foreach (Renderer r in renderersList)
        {
            r.material.SetFloat("_NormalStrenght", 0f);
        }

        float t = 0f;
        while (t < transitionTime)
        {
            foreach (Renderer r in renderersList)
            {
                r.material.SetFloat("_DissolveAmount", t / transitionTime);
            }

            RenderSettings.ambientLight = Color.Lerp(realAmbiant, netAmbiant, t / transitionTimeToReal);

            yield return new WaitForEndOfFrame();
            t += Time.deltaTime;
        }

        foreach (Renderer r in renderersList)
        {
            r.material.SetFloat("_DissolveAmount", 1f);
        }

        RenderSettings.ambientLight = netAmbiant;

        yield return null;
    }

    private IEnumerator ToRealLerp()
    {
        foreach (Renderer r in renderersList)
        {
            r.material.SetFloat("_NormalStrenght", 1f);
        }

        float t = 0f;
        while (t < transitionTimeToReal)
        {
            foreach (Renderer r in renderersList)
            {
                //r.material.SetFloat("_DissolveAmount", 1 - (t / transitionTime));
                r.sharedMaterial.SetFloat("_DissolveAmount", 1 - (t / transitionTimeToReal));
            }

            RenderSettings.ambientLight = Color.Lerp(netAmbiant, realAmbiant, t / transitionTimeToReal);

            yield return new WaitForEndOfFrame();
            t += Time.deltaTime;
        }

        foreach (Renderer r in renderersList)
        {
            r.material.SetFloat("_DissolveAmount", 0f);
        }

        RenderSettings.ambientLight = realAmbiant;

        yield return null;
    }

    public WorldType GetCurrentWorldType()
    {
        return currentWorld;
    }

    private IEnumerator MaterialsLerpDebug(Color newColor)
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