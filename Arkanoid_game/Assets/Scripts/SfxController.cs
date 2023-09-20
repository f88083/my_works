using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SfxController : MonoBehaviour
{
    public AudioSource woodHitSound;
    public AudioSource brickCrackSound;
    public AudioClip brickCrackSoundClip;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnCollisionEnter(Collision collision)
    {
        woodHitSound.Play();
    }
}
