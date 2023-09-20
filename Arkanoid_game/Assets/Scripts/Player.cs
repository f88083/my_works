using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    Rigidbody paddleRigidbody;

    public AudioSource panelHitSound;

    // Start is called before the first frame update
    void Start()
    {
        paddleRigidbody = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        paddleRigidbody.MovePosition(new Vector3(Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, 0, 50)).x, -17, 0));
    }

    private void OnCollisionEnter(Collision collision)
    {
        panelHitSound.Play();
    }
}
