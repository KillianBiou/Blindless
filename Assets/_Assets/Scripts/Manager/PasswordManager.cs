using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class PasswordManager : MonoBehaviour
{
    [SerializeField] private string password = "cacahuete";
    [SerializeField] private TMP_Text passwordText;

    private string answer = "";

    [SerializeField] private Animator hatchAnimator;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void AddStringToPassword(string text)
    {
        answer += text;
        UpdateDisplay();
    }

    public void Backspace()
    {
        if (answer == "")
        {
            return;
        }

        answer = answer.Remove(answer.Length - 1, 1);
        UpdateDisplay();
    }

    public void CheckAnswer()
    {
        if (answer == password)
        {
            Win();
        }
        else
        {
            Debug.Log("NON");
        }
        answer = "";
        UpdateDisplay();
    }

    private void UpdateDisplay()
    {
        passwordText.text = answer;
    }

    private void Win()
    {
        this.enabled = false;
        hatchAnimator.SetTrigger("Open");
        TransfoManager.instance.StartTransfo();
    }
}
