<?php

const TOKEN = 'YOUR_DEVICE_TOKEN';
const AUTH_KEY_PATH = '/path/to/AuthKey_AUTH_KEY_ID.p8';
const AUTH_KEY_ID = 'YOUR_AUTH_KEY_ID';
const TEAM_ID = 'YOUR_TEAM_ID';
const TOPIC = 'com.raywenderlich.PushNotifications';

# ---- Shouldn't need any changes below this line ----

$payload = [
  'aps'  => [
    'alert' => [
      'title' => str_rot13('Your Target'),
      'body' => str_rot13('This is your next assignment.')
    ],
    'badge' => 1,
    'mutable-content' => 1,
    'sound' => 'default',
  ],
  "media-url" => str_rot13('https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4')
];

function generateAuthenticationHeader() {
    $header = base64_encode(json_encode(['alg' => 'ES256', 'kid' => AUTH_KEY_ID]));
    $claims = base64_encode(json_encode(['iss' => TEAM_ID, 'iat' => time()]));

    $pkey = openssl_pkey_get_private('file://' . AUTH_KEY_PATH);
    openssl_sign("$header.$claims", $signature, $pkey, 'sha256');

    $signed = base64_encode($signature);
    return "$header.$claims.$signed";
}

$ch = curl_init();
curl_setopt($ch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
  'apns-topic: ' . TOPIC,
  'Authorization: Bearer ' . generateAuthenticationHeader(),
  'apns-push-type: alert'
]);

$url = 'https://api.development.push.apple.com/3/device/' . TOKEN;
curl_setopt($ch, CURLOPT_URL, "{$url}");

$response = curl_exec($ch);
if ($response === false) {
  echo "Failed to send push notification\n";
}

$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
if ($code === 400) {
  $json = @json_decode($response);
  var_dump($json);
}

curl_close($ch);
