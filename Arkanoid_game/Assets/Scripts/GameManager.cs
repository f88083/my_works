using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    public GameObject ballPrefab;
    public GameObject playerPrefab;
    public Text scoreText;
    public Text ballsText;
    public Text levelText;
    public Text highscoreText;
    public Text levelCompletedText;
    public Text gameOverText;

    public GameObject panelMenu;
    public GameObject panelPlay;
    public GameObject panelLevelCompleted;
    public GameObject panelGameOver;
    public GameObject panelPause;

    public GameObject[] levels;

    public static GameManager Instance { get; private set; }

    public enum State { MENU, INIT, PLAY, LEVELCOMPLETED, LOADLEVEL, GAMEOVER}
    State gameState;

    public GameObject currentBall;
    public GameObject currentLevel;
    bool isSwitchingState;

    private float changeStateTime = 2.0f;

    public AudioSource backgroundMusic;
    public AudioSource playButtonSound;
    public AudioSource gameLevelUpSound;
    public AudioSource ballMissedSound;
    public AudioSource gameWinSound;
    public AudioSource gameOverSound;

    public Material playerWhite;
    private Material playerOrigin;
    Renderer playerRenderer;

    public Material ballWhite;
    private Material ballOrigin;
    Renderer ballRenderer;

    private int[] barrierNumInLevel = new int[] { 0, 0, 2, 1, 2 };


    // For updating text
    private int score;
    public int Score
    {
        get { return score; }
        set { score = value;
            scoreText.text = "Score: " + score;
        }
    }

    private int level;

    public int Level
    {
        get { return level; }
        set { level = value;
            levelText.text = "LEVEL: " + (level + 1);
        }
    }

    private int balls;

    public int Balls
    {
        get { return balls; }
        set { balls = value;
            ballsText.text = "BALLS: " + balls;
        }
    }

    private int biggerPaddle = 0;

    public int BiggerPaddle
    {
        get { return biggerPaddle; }
        set { biggerPaddle = value; }
    }

    private int speedBallChange;

    public int SpeedBallChange
    {
        get { return speedBallChange; }
        set { speedBallChange = value; }
    }

    private float originballSpeed;

    public float OriginBallSpeed
    {
        get { return originballSpeed; }
        set { originballSpeed = value; }
    }




    // User clicks
    public void PlayClicked()
    {
        playButtonSound.Play();
        SwitchState(State.INIT);
    }

    // Start is called before the first frame update
    void Start()
    {
        Instance = this;
        SwitchState(State.MENU);
        /* To reset the high score */
        //PlayerPrefs.DeleteKey("highscore");
    }

    public void SwitchState(State newState, float delay = 0)
    {
        StartCoroutine(SwitchDelay(newState, delay));
    }

    // For delay to the next level
    IEnumerator SwitchDelay(State newState, float delay)
    {
        isSwitchingState = true;
        yield return new WaitForSeconds(delay);
        EndState();
        gameState = newState;
        BeginState(newState);
        isSwitchingState = false;
    }

    void BeginState(State newState)
    {
        switch (newState)
        {
            case State.MENU:
                backgroundMusic.Play();
                Cursor.visible = true;
                highscoreText.text = "HIGHESTSCORE: " + PlayerPrefs.GetInt("highscore");
                panelMenu.SetActive(true);
                break;
            case State.INIT:
                Cursor.visible = false;
                panelPlay.SetActive(true);
                Score = 0;
                Level = 0;
                Balls = 3;
                if (currentLevel != null)
                {
                    Destroy(currentLevel);
                }
                Instantiate(playerPrefab);
                SwitchState(State.LOADLEVEL);
                backgroundMusic.Play();
                break;
            case State.PLAY:
                break;
            case State.LEVELCOMPLETED:
                Destroy(currentBall);
                Destroy(currentLevel);
                Level++;
                if (Level < levels.Length)
                {
                    gameLevelUpSound.Play();
                    levelCompletedText.text = "Level" + level + " Completed!\nProceeding to next level";
                }
                else
                {
                    levelCompletedText.text = "";
                    changeStateTime = 0;
                }
                panelLevelCompleted.SetActive(true);
                SwitchState(State.LOADLEVEL, changeStateTime);
                break;
            case State.LOADLEVEL:
                if (Level >= levels.Length)
                {
                    SwitchState(State.GAMEOVER);
                }
                else
                {
                    currentLevel = Instantiate(levels[Level]);
                    SwitchState(State.PLAY);
                }
                break;
            case State.GAMEOVER:
                backgroundMusic.Pause();
                if (Score > PlayerPrefs.GetInt("highscore"))
                {
                    PlayerPrefs.SetInt("highscore", Score);
                }
                if (balls >= 1)
                {
                    gameWinSound.Play();
                    gameOverText.text = "Congratulations!\nYou've passed all levels" +
                        "\nPress any key to play again";
                }
                else
                {
                    gameOverSound.Play();
                    gameOverText.text = "You lose!\nPress any key to play again";
                }
                panelGameOver.SetActive(true);
                Destroy(GameObject.Find("Player(Clone)"));
                break;
        }

    }

    // Update is called once per frame
    void Update()
    {
        switch (gameState)
        {
            case State.MENU:
                if (Input.GetKey("escape"))
                {
                    Application.Quit();
                }
                break;
            case State.INIT:
                break;
            case State.PLAY:
                if (biggerPaddle == 1)
                {
                    Invoke("PlayerTurnWhite", 9.0f);
                    Invoke("DelayRestorePlayer", 10.0f);
                    biggerPaddle = 0;
                }

                if (speedBallChange == 1)
                {
                    if (currentBall != null)
                    {
                        originballSpeed = GameObject.Find("Ball(Clone)").GetComponent<Ball>().speed;
                        GameObject.Find("Ball(Clone)").GetComponent<Ball>().speed = 20f;
                        ballRenderer = GameObject.Find("Ball(Clone)").GetComponent<Renderer>();
                        ballOrigin = ballRenderer.sharedMaterial;
                        Invoke("RestoreBallSpeed", 6.0f);
                        Invoke("TurnBallWhite", 5.0f);
                        speedBallChange = 0;
                    }
                }

                if (currentLevel != null && currentLevel.transform.childCount == barrierNumInLevel[level] && !isSwitchingState)
                {
                    SwitchState(State.LEVELCOMPLETED);
                }

                if (currentBall == null)
                {
                    
                    if (Balls > 0)
                    {
                        currentBall = Instantiate(ballPrefab, new Vector3(0, -12f, 0), new Quaternion(0, 0, 0, 0));
                    }
                    else
                    {
                        SwitchState(State.GAMEOVER);
                    }
                }

                if (Input.GetKeyUp(KeyCode.Space))
                {
                    if (Time.timeScale == 1)
                    {
                        panelPause.SetActive(true);
                        Time.timeScale = 0;
                    }
                    else
                    {
                        Time.timeScale = 1;
                        panelPause.SetActive(false);
                    }
                }

                if (Input.GetKeyUp(KeyCode.Escape))
                {
                    if (Time.timeScale == 0)
                    {
                        Time.timeScale = 1;
                        panelPause.SetActive(false);
                    }
                    backgroundMusic.Pause();
                    Destroy(GameObject.Find("Player(Clone)"));
                    panelPlay.SetActive(false);
                    panelGameOver.SetActive(false);
                    SwitchState(State.MENU, 0.0f);
                }
                
                break;
            case State.LEVELCOMPLETED:
                break;
            case State.LOADLEVEL:
                break;
            case State.GAMEOVER:
                if (Input.anyKeyDown)
                {
                    gameWinSound.Pause();
                    SwitchState(State.MENU);
                }
                break;
        }
    }


    // For delay restore player
    void DelayRestorePlayer()
    {
        GameObject.Find("Player(Clone)").transform.localScale = new Vector3(1.5f, 1.5f, 1.5f);
        biggerPaddle = 0;
    }
    
    // Turn white before the paddle back to origin
    void PlayerTurnWhite()
    {
        playerRenderer = GameObject.Find("Player(Clone)").GetComponent<Renderer>();
        playerOrigin = playerRenderer.sharedMaterial;
        playerRenderer.sharedMaterial = playerWhite;
        Invoke("PlayerBackToOrigin", 1.0f);
    }

    // Turn the paddle back to origin
    void PlayerBackToOrigin()
    {
        playerRenderer.sharedMaterial = playerOrigin;
    }

    // Restore the speed of the ball
    void RestoreBallSpeed()
    {
        GameObject.Find("Ball(Clone)").GetComponent<Ball>().speed = originballSpeed;
    }

    // Turn ball to white
    void TurnBallWhite()
    {
        if (ballRenderer != null)
        {
            ballRenderer.sharedMaterial = ballWhite;
        }
        Invoke("TurnBallToOrigin", 1.0f);
    }

    // Turn ball back to origin
    void TurnBallToOrigin()
    {
        if (ballRenderer != null)
        {
            ballRenderer.sharedMaterial = ballOrigin;
        }
    }
    

    void EndState()
    {
        switch (gameState)
        {
            case State.MENU:
                panelMenu.SetActive(false);
                break;
            case State.INIT:
                break;
            case State.PLAY:
                break;
            case State.LEVELCOMPLETED:
                panelLevelCompleted.SetActive(false);
                break;
            case State.LOADLEVEL:
                break;
            case State.GAMEOVER:
                panelPlay.SetActive(false);
                panelGameOver.SetActive(false);
                break;
        }
    }
}
