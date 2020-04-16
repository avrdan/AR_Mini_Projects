using UnityEngine;
using System.Collections;

public class BallGun : MonoBehaviour {

    [SerializeField]
    private GameObject projectile;
    [SerializeField]
    private Transform projectilePlaceHolder;

    private GameObject ballFireAudio;

    private GameObject trackable;
    
    // Use this for initialization
	void Start () {
        ballFireAudio = this.gameObject.transform.FindChild("BallFireAudio").gameObject;
        trackable = GameObject.Find("ImageTarget").gameObject;
	}
	
	// Update is called once per frame
	void Update () {
	    if (Input.GetMouseButtonDown(0))
        {
            ballFireAudio.audio.Play();
            GameObject obj = Instantiate(projectile, projectilePlaceHolder.position, this.gameObject.transform.rotation) as GameObject;
            obj.gameObject.rigidbody.AddRelativeForce(Vector3.forward * Time.deltaTime * 1100000);
            obj.transform.parent = trackable.transform;
            Destroy(obj.gameObject, 5f);
        }
	}
}
