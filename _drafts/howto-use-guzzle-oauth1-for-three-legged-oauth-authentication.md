---
layout: post
title: "HOWTO: Use Guzzle oauth-subscriber for OAuth 1.0a Three-legged OAuth Authentication"
date: 2015-12-23 17:26:50 +0000
tags:
-
type: post
published: true
---

Whilst updating [phpSmug](https://phpsmug.com) to use the latest and greatest [SmugMug API](https://api.smugmug.com/api/v2/doc/index.html), I decided to switch to using [Guzzle 6](https://guzzlephp.org/) for my HTTP requests rather than continuing maintaining my own code (Guzzle is used by a load of other projects and maintained by way smarter people than me).

As part of this update, I needed to implement the [three-legged OAuth 1.0a procedure](https://oauthbible.com/#oauth-10a-three-legged) used by SmugMug, and many other sites, but I couldn't find a publicly documented procedure to so do.  I found [Guzzle oauth-subscriber](https://github.com/guzzle/oauth-subscriber) which seemed to tick all the boxes by I couldn't find how to use it for a three-legged OAuth authentication process.

Well, I'm pleased to say after a lot of code diving and testing, phpSmug now has a [public implementation](https://github.com/lildude/phpSmug/blob/master/examples/example-oauth.php).  phpSmug implements this using a few helper functions to make devs' lives easier which may not be instantly obvious, so here it is in a single simplified representation, without phpSmug's helper functions or specifics:

```php
<?php
if (session_id() == '') {
    session_start();
}
require_once 'vendor/autoload.php';

$APIKey = 'YOUR_API_KEY';
$OAuthSecret = 'YOUR_OAUTH_SECRET';
$AppName = 'YOUR_APP_NAME/VER (URL)';
$callbackUrl = 'https://YOUR_CALL_BACK_URL';
$authorisationUrl = 'https://YOUR_DESTINATION_SERVICE_AUTHORISATION_URL';
?>
<html>
<?php

try {

    // Perform the 3 step OAuth Authorisation process.
    // NOTE: This is a very simplified example that does NOT store the final token.
    // You will need to ensure your application does.
    if (!isset($_SESSION['RequestToken'])) {

        // Step 1: Get a request token using an optional callback URL back to ourselves
        $request_token = $client->getRequestToken($callbackUrl);
        $_SESSION['RequestToken'] = serialize($request_token);

        // Step 2: Get the User to login to the destination site and authorise this demo
        echo '<p>Click <a href="'.$authorisationUrl.'"><strong>HERE</strong></a> to Authorize This Demo.</p>';
        // Alternatively, automatically direct your visitor by commenting out the above line in favour of this:
        //header("Location:".$authorisationUrl);
    } else {
        $reqToken = unserialize($_SESSION['RequestToken']);
        unset($_SESSION['RequestToken']);

        // Step 3: Use the Request token obtained in step 1 to get an access token
        $client->setToken($reqToken['oauth_token'], $reqToken['oauth_token_secret']);
        $oauth_verifier = $_GET['oauth_verifier'];  // This comes back with the callback request.
        $token = $client->getAccessToken($oauth_verifier);  // The results of this call is what your application needs to store.
    }
} catch (Exception $e) {
    echo "{$e->getMessage()} (Error Code: {$e->getCode()})";
}
?>
</html>
```


```php
$me = 'https://local.wordpress.dev/wp-json/wp/v2/users/me';
$oauth_key = 'YOURKEY';
$oauth_secret = 'YOURSECRET';

$oauth_token = false;
if(isset($_GET['oauth_token'])){
	$oauth_token = $_GET['oauth_token'];
}
if(!$oauth_token){
	/*
	 *
	 * Leg 1 - Request Temporary token to redirect User
	 *
	 */
	//Container for Oauth keys
	$oauth = new GuzzleHttp\Subscriber\Oauth\Oauth1([
	    'consumer_key'    => $oauth_key,
	    'consumer_secret' => $oauth_secret,
	    'token'           => '',
	    'token_secret'    => ''
	]);

	$HandlerStack = new GuzzleHttp\HandlerStack;

	$stack = $HandlerStack::create();
	$stack->push($oauth);
	//handler associates the new Oauth middleware to our client
	$client = new GuzzleHttp\Client([
	    'handler' => $stack
	]);
	$callback = 'https://local.wordpress.dev/wp-api-examples/oauth1/index.php';
	//Note we are using Try/Catch in this example as Oauth1 has lots of places to break ;)
	try {
		$token = $client->post('https://local.wordpress.dev/oauth1/request', [
		    'form_params' => [
		    	'oauth_callback' => $callback
		    ],
		    'auth' => 'oauth'
		]);

		$token_array_parts = explode('&',$token->getBody());
		//@todo write a better example of splitting
		$token_array = array();
		foreach($token_array_parts as $token_part)
		{
			$token_parts = explode('=',$token_part);
			$token_array[] = $token_parts[1];
		}

	    /*
		 *
		 * Leg 2 - Redirect user and return token to verify
		 *
		 */
	    header("Location: https://local.wordpress.dev/oauth1/authorize?oauth_token={$token_array[0]}&oauth_callback=".$callback);

	} catch (Exception $e) {
    	var_dump($e);
	}
}
else{
	/*
	 *
	 * Leg 3 - Verify the returned token and recieve real Oauth token and secret
	 *
	 */
	$oauth_token = $_GET['oauth_token'];
	$oauth_verify = $_GET['oauth_verifier'];
	//New container, with updated credentials, including temporary token
	$oauth = new GuzzleHttp\Subscriber\Oauth\Oauth1([
	    'consumer_key'    => $oauth_key,
	    'consumer_secret' => $oauth_secret,
	    'token'           => $oauth_token,
	    'token_secret'    => ''
	]);

	$HandlerStack = new GuzzleHttp\HandlerStack;

	$stack = $HandlerStack::create();
	$stack->push($oauth);

	$client = new GuzzleHttp\Client([
	    'handler' => $stack
	]);
	try {
		$verify = $client->post('https://local.wordpress.dev/oauth1/access', [
		    'form_params' => [
		    	'oauth_verifier' => $oauth_verify
		    ],
		    'auth' => 'oauth'
		]);
		$token_array_parts = explode('&',$verify->getBody());
		$token_array = array();
		foreach($token_array_parts as $token_part)
		{
			$token_parts = explode('=',$token_part);
			$token_array[] = $token_parts[1];
		}
		/*
		 *
		 * Make API Request
		 *
		 */
		//Full container, with correct tokens, we probably should store these for future calls
		$oauth = new GuzzleHttp\Subscriber\Oauth\Oauth1([
		    'consumer_key'    => $oauth_key,
		    'consumer_secret' => $oauth_secret,
		    'token'           => $token_array[0],
		    'token_secret'    => $token_array[1]
		]);
		$HandlerStack = new GuzzleHttp\HandlerStack;

		$stack = $HandlerStack::create();
		$stack->push($oauth);

		$client = new GuzzleHttp\Client([
		    'handler' => $stack
		]);
		try{
			$json = $client->get($me, [
			    'auth' => 'oauth'
			]);
			$json = json_decode($json->getBody());
			var_dump($json);
		}
		catch(Exception $e)
		{
			var_dump($e);
		}
	}
	catch(Exception $e) {	    
    }
}
```
