using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NetShaderAnimation : MonoBehaviour
{
    private Color baseColor;
    private Color baseColorTwo;

    private Color triggeredColor;
    private Color triggeredColorTwo;

    private Color currentColor;
    private Color currentColorTwo;

    private bool doLerp;
    private Material mat;

    private void Start()
    {
        mat = GetComponent<MeshRenderer>().material;
        currentColor = baseColor;
        currentColorTwo = baseColorTwo;
    }

    private void Update()
    {
        if(doLerp)
        {
            mat.SetColor("_GlitchColor", Color.Lerp(currentColor, currentColorTwo, Mathf.Abs(Mathf.Sin(Time.time * WorldManager.instance.materialColorSpeed))));
        }
    }

    public void Setup(Color baseColor, Color baseColorTwo, Color triggeredColor, Color triggeredColorTwo)
    {
        this.baseColor = baseColor;
        this.baseColorTwo = baseColorTwo;
        this.triggeredColor = triggeredColor;
        this.triggeredColorTwo = triggeredColorTwo;
    }

    public void ChangeTrigger(bool state)
    {
        if (state)
        {
            currentColor = triggeredColor;
            currentColorTwo = triggeredColorTwo;
        }
        else
        {
            currentColor = baseColor;
            currentColorTwo = baseColorTwo;
        }
    }

    public void SetDoLerp(bool doLerp)
    {
        this.doLerp = doLerp;
        if(doLerp == false && mat)
            mat.SetColor("_GlitchColor", baseColor);
    }
}
