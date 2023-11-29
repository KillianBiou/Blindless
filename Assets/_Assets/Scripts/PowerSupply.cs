using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerSupply : MonoBehaviour
{
    [SerializeField] private int maxHealth = 20;
    private int health = 0;
    // Start is called before the first frame update
    void Start()
    {
        health = maxHealth;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            TakeDamage();
        }
    }

    public void TakeDamage()
    {
        if (health == 0)
        {
            return;
        }

        if (health - 1 <= 0)
        {
            health = 0;
            Debug.Log("Power supply dead !");
            return;
        }
        health--;
    }
}
