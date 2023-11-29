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

    // Start is called before the first frame update
    void Start()
    {
        health = maxHealth;
    }

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(target);
        transform.position = Vector3.Lerp(transform.position, target.position, speed * Time.deltaTime);
    }
}
