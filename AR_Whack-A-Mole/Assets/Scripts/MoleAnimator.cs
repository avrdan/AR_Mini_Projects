using UnityEngine;
using System.Collections;

public class MoleAnimator : MonoBehaviour {

    private ParticleSystem dust;
    private GameObject moleHitAudio;
    private MoleTrackableEventHandler trackableHandler;

	// Use this for initialization
	void Start () {
        moleHitAudio = GameObject.Find("ARCamera").transform.FindChild("MoleHitAudio").gameObject;
        dust = this.gameObject.transform.parent.transform.FindChild("Dust").gameObject.GetComponent<ParticleSystem>();
        trackableHandler = GameObject.Find("ImageTarget").gameObject.GetComponent<MoleTrackableEventHandler>();

        iTween.MoveBy(gameObject, iTween.Hash("y", 40, "easeType", "easeInOutQuad", 
            "speed", 20, "delay", Random.Range(0.3f, 5f), "oncomplete", "animComplete_Up"));
	}

    // Function called when animation below ground is complete
    public void animComplete_Down()
    {
        // Only make the mole visible if the Trackable is visible
        // This is to avoid having the mole character visible with no detected Trackable
        if (trackableHandler.trackableVisible())
        {
            this.gameObject.renderer.enabled = true;
            this.gameObject.collider.enabled = true;
        }

        iTween.MoveBy(gameObject, iTween.Hash("y", 40, "easeType", "easeInOutQuad",
            "speed", 20, "delay", Random.Range(0.3f, 5f), "oncomplete", "animComplete_Up"));
    }

    // Function called when animation above ground is complete
	public void animComplete_Up()
    {
        iTween.MoveBy(gameObject, iTween.Hash("y", -40, "easeType", "easeInOutQuad",
            "speed", 20, "delay", Random.Range(0.3f, 1f), "oncomplete", "animComplete_Down"));
    }

	void OnCollisionEnter(Collision collision)
    {
        dust.Play();
        moleHitAudio.audio.Play();
        this.gameObject.renderer.enabled = false;
        this.gameObject.collider.enabled = false;
    }
}
