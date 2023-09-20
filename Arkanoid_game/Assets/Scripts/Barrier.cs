using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Barrier : MonoBehaviour
{
    public Vector3 rotator = new Vector3(60, 0, 0);
    public AudioSource hitSound;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(rotator * Time.deltaTime);
    }

    private void OnCollisionEnter(Collision collision)
    {
        hitSound.Play();
    }
}
