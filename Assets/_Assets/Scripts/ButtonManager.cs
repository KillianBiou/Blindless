using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButtonManager : MonoBehaviour
{
    public void TryEscalatePriviledges()
    {
        Debug.Log("Escalate");
        if (TransfoManager.instance.HasWon())
        {
            NetWorldManager.Instance.EscalatePrivilege();
        }
    }
}
