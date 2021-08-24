using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OptionsController : MonoBehaviour
{
    public static OptionsController instance;

    public float accuracy;

    public float iterations;

    public bool shadowIsOn;

    void Awake(){
        if(instance == null){
            instance = this;
        }else{
            Destroy(gameObject);
            return;
        }

        accuracy = 0.001f;
        iterations = 1;
        shadowIsOn = false;

        DontDestroyOnLoad(gameObject);
    }
}
