using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface WorldItem
{
    public void OnLoad(float duration);
    public void OnUnload(float duration);
    public void ForceUnload();
}
