using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Player : MonoBehaviour
{
    [Header("Player Attributes")]
    [SerializeField]
    private int maxHp;
    [SerializeField]
    private int hp;

    private bool dead = false;

    private List<PlayerSubscriber> subscriberList = new List<PlayerSubscriber>();

    public static Player Instance;

    private void Start()
    {
        Instance = this;
        hp = maxHp;
    }

    private void TriggerDeath()
    {
        foreach(PlayerSubscriber p in subscriberList){
            p.NotifyDeath();
            dead = true;
        }
    }

    public void AddSubscriber(PlayerSubscriber subscriber)
    {
        subscriberList.Add(subscriber);
    }

    public void TakeDamage(int damage)
    {
        hp -= damage;
        if (hp <= 0 && !dead)
        {
            TriggerDeath();
        }
    }
}
