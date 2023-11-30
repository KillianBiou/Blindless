using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct Wave
{
    public int enemyNumber;
    public float cdBetweenEnemy;
}

public class DeamonManager : MonoBehaviour, PlayerSubscriber
{
    [Header("Gameflow parameters")]
    [SerializeField]
    private List<Wave> wavesList;
    [SerializeField]
    private float timeBetweenWave;

    [Header("Deamon Parameters")]
    [SerializeField]
    private int deamonMaxHealth;
    [SerializeField]
    private float deamonSpeed;

    [Header("Reference")]
    [SerializeField]
    private GameObject daemonPrefab;
    [SerializeField]
    private GameObject player;

    [Header("Instanciation Parameters")]
    [SerializeField]
    private Vector2 distanceMinMax;
    [SerializeField]
    private float maxAngle;

    private Vector3 targetDir;
    private Wave currentWave;
    private Stack<Wave> waveQueue;
    private bool playerDead = false;

    private void Start()
    {
        waveQueue = new Stack<Wave>(wavesList);
        player.GetComponent<Player>().AddSubscriber(this);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            StartGame();
        }
    }

    private void StartGame()
    {
        StartCoroutine(RunWave());
    }

    Vector3 GetRandomPointInArc()
    {
        float radius = Random.Range(distanceMinMax.x, distanceMinMax.y);

        float randomAngle = Random.Range(-maxAngle / 2f, maxAngle / 2f);
        float radianAngle = randomAngle * Mathf.Deg2Rad;

        float x = player.transform.position.x + radius * Mathf.Sin(radianAngle + player.transform.localEulerAngles.y * Mathf.Deg2Rad);
        float z = player.transform.position.z + radius * Mathf.Cos(radianAngle + player.transform.localEulerAngles.y * Mathf.Deg2Rad);

        targetDir = new Vector3(x, player.transform.position.y, z);

        return targetDir;
    }

    private void TriggerWin()
    {
        Debug.Log("Daemon Defeated");
    }

    private void TriggerLose()
    {
        foreach(Deamon d in GameObject.FindObjectsOfType<Deamon>()){
            Destroy(d.gameObject);
        }
        Debug.Log("Player got fucked");
    }

    private IEnumerator RunWave()
    {
        currentWave = waveQueue.Pop();
        int currentEnemyCount = 0;
        while(currentEnemyCount < currentWave.enemyNumber && !playerDead)
        {
            currentEnemyCount++;
            Deamon deamon = Instantiate(daemonPrefab, GetRandomPointInArc(), Quaternion.identity).GetComponent<Deamon>();
            deamon.Instantiate(deamonMaxHealth, deamonSpeed, player.transform);
            float waitT = 0f;
            while(waitT < currentWave.cdBetweenEnemy && !playerDead)
            {
                waitT += Time.deltaTime;
                yield return new WaitForEndOfFrame();
            }
        }

        if(playerDead)
        {
            TriggerLose();
            yield return null;
        }

        Wave nullWave;
        if(waveQueue.TryPeek(out nullWave))
        {
            yield return new WaitForSeconds(timeBetweenWave);
            StartCoroutine(RunWave());
        }
        else if (!playerDead)
        {
            TriggerWin();
        }
    }

    public void NotifyDeath()
    {
        playerDead = true;
    }
}
