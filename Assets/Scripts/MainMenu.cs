using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class MainMenu : MonoBehaviour
{
    public OptionsController options;
    public TextMeshProUGUI accuracyLabel;

    public TextMeshProUGUI iterationsLabel;
    
    public void StartProgram(){
        SceneManager.LoadScene(1);
    }

    public void ExitProgram(){
        Debug.Log("quit");
        Application.Quit();
    }

    public void ChangeAccuracy(float val){
        options.accuracy = val;
        accuracyLabel.text = Math.Round(val,3).ToString();
    }

    public void ChangeIterNumber(float iterations){
        options.iterations = iterations;
        iterationsLabel.text = iterations.ToString();

    }

    public void ChangeShadowStatus(bool isOn){
        options.shadowIsOn = isOn;
    }
}
