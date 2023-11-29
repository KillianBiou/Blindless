using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct Wave
{
    public int enemyNumber;
    public float cdBetweenEnemy;
}

public class DeamonManager : MonoBehaviour
{
    [Header("Gameflow parameters")]
    [SerializeField]
    private List<Wave> wavesList;

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
    private Vector3 baseAngle;

    private Vector3 targetDir;
    private Wave currentWave;
    private Queue<Wave> waveQueue;

    private void Start()
    {
        baseAngle = player.transform.eulerAngles;
        waveQueue = new Queue<Wave>(wavesList);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            GetRandomPointInArc();
            //ProjectPointForward();
        }
        Debug.DrawRay(player.transform.position, targetDir, Color.red);
    }

    private void StartGame()
    {
        StartCoroutine(RunWave());
    }

    void GetRandomPointInArc()
    {
        float radius = Random.Range(distanceMinMax.x, distanceMinMax.y);

        float randomAngle = Random.Range(-maxAngle / 2f, maxAngle / 2f);
        float radianAngle = randomAngle * Mathf.Deg2Rad;

        float x = player.transform.position.x + radius * Mathf.Sin(radianAngle + player.transform.localEulerAngles.y * Mathf.Deg2Rad);
        float z = player.transform.position.z + radius * Mathf.Cos(radianAngle + player.transform.localEulerAngles.y * Mathf.Deg2Rad);

        targetDir = new Vector3(x, player.transform.position.y, z);

        Instantiate(daemonPrefab, targetDir, Quaternion.identity);
    }

    private IEnumerator RunWave()
    {
        currentWave = waveQueue.;
        int currentEnemyCount = 0;
        while(currentEnemyCount < currentWave.enemyNumber)
        {
            currentEnemyCount++;
        }

        yield return null;
    }
}
