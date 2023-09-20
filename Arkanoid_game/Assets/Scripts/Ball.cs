using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ball : MonoBehaviour
{
    Rigidbody ballRigidbody;
    Vector3 velocity;
    Renderer ballRenderer;

    public float speed = 30f;


    // Start is called before the first frame update
    void Start()
    {
        ballRigidbody = GetComponent<Rigidbody>();
        ballRenderer = GetComponent<Renderer>();
        Invoke("Launch", 0.5f);
    }

    // When the ball being initialized
    void Launch()
    {
        ballRigidbody.velocity = Vector3.up * speed;
    }

    // Update is called once per frame
    void Update()
    {
        if (ballRenderer.isVisible)
        {
            if (Input.GetKeyUp(KeyCode.B))
            {
                Destroy(gameObject);
            }
        }
    }

    // For physic stuff, 100Hz/s
    private void FixedUpdate()
    {
        ballRigidbody.velocity = ballRigidbody.velocity.normalized * speed;
        velocity = ballRigidbody.velocity;

        if (!ballRenderer.isVisible)
        {
            GameManager.Instance.Balls--;
            GameManager.Instance.ballMissedSound.Play();
            Destroy(gameObject);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        ballRigidbody.velocity = Vector3.Reflect(velocity, collision.GetContact(0).normal);
    }
}
