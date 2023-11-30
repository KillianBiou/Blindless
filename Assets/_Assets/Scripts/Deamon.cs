using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Jobs;

public class Deamon : MonoBehaviour
{
    [SerializeField] private int maxHealth = 20;
    private int health = 0;
    [SerializeField] private float speed;

    [SerializeField] private Transform target;

    // Update is called once per frame
    void Update()
    {
        if (target)
        {
            transform.LookAt(target);
            transform.position = Vector3.Lerp(transform.position, target.position, speed * Time.deltaTime);
            if(Vector3.Distance(transform.position, target.position) < 1f)
            {
                target.GetComponent<Player>().TakeDamage(1);
                Destroy(gameObject);
            }
        }
    }

    public void Instantiate(int maxHealth, float speed, Transform target)
    {
        this.maxHealth = maxHealth;
        this.health = maxHealth;
        this.speed = speed;
        this.target = target;
    }
}
