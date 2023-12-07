using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class PasswordManager : MonoBehaviour
{
    [SerializeField] private string password = "cacahuete";
    [SerializeField] private TMP_Text passwordText;
    [SerializeField] private AudioSource doorSource;

    private string answer = "";

    [SerializeField] private Animator hatchAnimator;

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
        DeactivateKeyboard();
        hatchAnimator.SetTrigger("Open");
        doorSource.loop = false;
        doorSource.Stop();
        NetWorldManager.Instance.EscalatePrivilege();
        //NetWorldManager.Instance.DeleteKeyboard();
        TransfoManager.instance.StartTransfo();
    }

    private void DeactivateKeyboard()
    {
        MonologueManager.Instance.PlayPasswordPassedClip();
        this.enabled = false;
    }
}
