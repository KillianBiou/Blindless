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
    private Vector3 basePos;

    private List<PlayerSubscriber> subscriberList = new List<PlayerSubscriber>();

    public static Player Instance;

    private void Start()
    {
        Instance = this;
        hp = maxHp;
        basePos = transform.position;
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

    /*public IEnumerator MovePlayerTo(Vector3 targetPos, float speed)
    {
        basePos = transform.position;
        float t = 0;
        while(t < 1f)
        {
            transform.position = new Vector3(Mathf.Lerp(basePos.x, targetPos.x, t / 1f), Mathf.Lerp(basePos.y, targetPos.y, t / 1f), Mathf.Lerp(basePos.z, targetPos.z, t / 1f));
            yield return new WaitForEndOfFrame();
            t += Time.deltaTime * speed;
        }
    }*/
}
