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
    [SerializeField]
    private AudioSource alarmAudioSource;

    private int deamonCount = 0;

    [Header("Instanciation Parameters")]
    [SerializeField]
    private Vector2 distanceMinMax;
    [SerializeField]
    private float maxAngle;
    [SerializeField]
    private float downOffset;

    public static DeamonManager instance;

    private Vector3 targetDir;
    private Wave currentWave;
    private Stack<Wave> waveQueue;
    private bool playerDead = false;

    private void Awake()
    {
        instance = this;
    }

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

    public void StartGame()
    {
        MonologueManager.Instance.PlayDeamonsAttackClip();
        alarmAudioSource.Play();
        WorldManager.instance.TriggerNet();
        PinchGun.instance.SetLockDuration(1f);
        PinchGun.instance.SetLockDistance(4f);
        player.transform.position += 20 * Vector3.up;
        NetWorldManager.Instance.CommuteNetStatus();
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
        MonologueManager.Instance.PlayDeamonsVanishedClip();
        alarmAudioSource.Stop();
        Debug.Log("Daemon Defeated");
        NetWorldManager.Instance.SetDeamonTrigger(false);
        player.transform.position -= 20 * Vector3.up;
        NetWorldManager.Instance.CommuteNetStatus();
        WorldManager.instance.TriggerNet();
    }

    private void TriggerLose()
    {
        alarmAudioSource.Stop();
        NetWorldManager.Instance.SetDeamonTrigger(false);
        player.transform.position -= 20 * Vector3.up;
        foreach (Deamon d in GameObject.FindObjectsOfType<Deamon>()){
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
            AddDeamon();
            Deamon deamon = Instantiate(daemonPrefab, GetRandomPointInArc() + Vector3.down * downOffset, Quaternion.identity).GetComponent<Deamon>();
            deamon.Instantiate(deamonMaxHealth, deamonSpeed, player.transform, downOffset);
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
            while(deamonCount != 0)
            {
                yield return new WaitForSeconds(.1f);
            }
            TriggerWin();
        }
    }

    public void NotifyDeath()
    {
        playerDead = true;
    }

    public void AddDeamon()
    {
        deamonCount++;
    }

    public void RemoveDeamon()
    {
        deamonCount--;
        TutorialManager.instance.DeamonKilled();
    }
}
