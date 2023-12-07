using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UITranslation : MonoBehaviour
{
    [SerializeField]
    private Vector3 translationDirection;
    [SerializeField]
    private float translationSpeed;

    private Vector3 basePos;
    private RectTransform rect;
    private float t;

    private void Awake()
    {
        basePos = transform.position;
        rect = GetComponent<RectTransform>();
    }

    private void OnEnable()
    {
        transform.position = basePos;
    }

    private void Update()
    {
        rect.position += translationDirection * translationSpeed * Time.deltaTime;
    }
}
