using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Brick : MonoBehaviour
{
    public int hits = 1;
    public int points = 100;
    public Vector3 rotator;
    public Material hitMaterial;
    public int brickTypeNum = 0;

    Material originMaterial;
    Renderer brickRenderer;

    public enum BrickType { EXTRALIFE }
    BrickType brickType;

    public AudioSource brickCrackSound;
    public AudioSource specialBrickHitSound;

    // Start is called before the first frame update
    void Start()
    {
        // Bricks rotate from various initialization
        transform.Rotate(rotator * (transform.position.x + transform.position.y) * 0.09f);
        brickRenderer = GetComponent<Renderer>();
        originMaterial = brickRenderer.sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(rotator * Time.deltaTime);
    }

    private void OnCollisionEnter(Collision collision)
    {
        hits--;

        // Determine brick type
        switch (brickTypeNum)
        {
            // Slow the ball down
            case 3:
                specialBrickHitSound.Play();
                GameManager.Instance.SpeedBallChange = 1;
                break;
            // Larger paddle
            case 2:
                specialBrickHitSound.Play();
                GameObject.Find("Player(Clone)").transform.localScale = new Vector3(4, 1.5f, 1.5f);
                GameManager.Instance.BiggerPaddle = 1;
                break;
            // Extra life
            case 1:
                specialBrickHitSound.Play();
                GameManager.Instance.Balls += 1;

                /* For testing */
                

                break;
            // Normal brick
            case 0:
                brickCrackSound.Play();
                break;
        }

        // Destroy block after hit
        if (hits <= 0)
        {
            GameManager.Instance.Score += points;
            gameObject.transform.localScale = new Vector3(0, 0, 0);
            gameObject.transform.position = new Vector3(0, 0, 10);
            
            // Destroy ball after complete a level to prevent ball falls
            if (GameManager.Instance.currentLevel.transform.childCount == 1)
            {
                Destroy(GameManager.Instance.currentBall);
            }
            Invoke("DelayDelete", 1.0f);
        }

        brickRenderer.sharedMaterial = hitMaterial;
        Invoke("RestoreMaterial", 0.5f);
    }

    void RestoreMaterial()
    {
        brickRenderer.sharedMaterial = originMaterial;
    }

    void DelayDelete()
    {
        Destroy(gameObject);
    }

    // Restore the paddle
    /*void RestorePlayer()
    {
        GameObject.Find("Player(Clone)").transform.localScale = new Vector3(1.5f, 1.5f, 1.5f);
    }*/

}
