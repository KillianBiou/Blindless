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

    [Header("Weakpoint Parameters")]
    [SerializeField]
    private List<GameObject> weakPointList;

    private Animator animator;

    private float velocity;
    private Vector3 lastPos;
    private float downOffset;

    private void Start()
    {
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (target)
        {
            transform.LookAt(target.position + Vector3.down * downOffset);
            transform.position = Vector3.Lerp(transform.position, target.position + Vector3.down * downOffset, speed * Time.deltaTime);
            lastPos = transform.position;
            if(Vector3.Distance(transform.position, target.position) < 20f)
            {
                DeamonManager.instance.RemoveDeamon();
                target.GetComponent<Player>().TakeDamage(1);
                Destroy(gameObject);
            }

            if (!CheckWeakpoints())
            {
                DeamonManager.instance.RemoveDeamon();
                Destroy(gameObject);
            }
        }
    }

    public void Instantiate(int maxHealth, float speed, Transform target, float downOffset)
    {
        this.maxHealth = maxHealth;
        this.health = maxHealth;
        this.speed = speed;
        this.target = target;
        this.downOffset = downOffset;
    }

    private bool CheckWeakpoints()
    {
        foreach(GameObject weakPoint in weakPointList)
        {
            if (weakPoint.activeSelf)
                return true;
        }

        return false;
    }
}
