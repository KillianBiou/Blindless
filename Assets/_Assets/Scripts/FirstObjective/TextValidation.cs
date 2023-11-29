using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class TextValidation : MonoBehaviour
{
    [SerializeField] private string password = "cacahuete";
    [SerializeField] private TMP_Text passwordText;

    private string answer = "";
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
            gameObject.SetActive(false);
            Debug.Log("gagné");
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
}
