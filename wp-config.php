<?php

define( 'WP_CACHE', true ); // Simple Cache

require 'wp-content/vendor/autoload.php';

function getenv_docker($env, $default) {
	if (($val = getenv($env)) !== false) {
		return $val;
	}
	else {
		return $default;
	}
}

define( 'DB_NAME', getenv_docker('WORDPRESS_DB_NAME', 'wordpress') );
define( 'DB_USER', getenv_docker('WORDPRESS_DB_USER', 'example username') );
define( 'DB_PASSWORD', getenv_docker('WORDPRESS_DB_PASSWORD', 'example password') );
define( 'DB_HOST', getenv_docker('WORDPRESS_DB_HOST', 'mysql') );
define( 'DB_CHARSET', getenv_docker('WORDPRESS_DB_CHARSET', 'utf8') );
define( 'DB_COLLATE', getenv_docker('WORDPRESS_DB_COLLATE', '') );

define( 'AUTH_KEY',         getenv_docker('WORDPRESS_AUTH_KEY',         'put your unique phrase here') );
define( 'SECURE_AUTH_KEY',  getenv_docker('WORDPRESS_SECURE_AUTH_KEY',  'put your unique phrase here') );
define( 'LOGGED_IN_KEY',    getenv_docker('WORDPRESS_LOGGED_IN_KEY',    'put your unique phrase here') );
define( 'NONCE_KEY',        getenv_docker('WORDPRESS_NONCE_KEY',        'put your unique phrase here') );
define( 'AUTH_SALT',        getenv_docker('WORDPRESS_AUTH_SALT',        'put your unique phrase here') );
define( 'SECURE_AUTH_SALT', getenv_docker('WORDPRESS_SECURE_AUTH_SALT', 'put your unique phrase here') );
define( 'LOGGED_IN_SALT',   getenv_docker('WORDPRESS_LOGGED_IN_SALT',   'put your unique phrase here') );
define( 'NONCE_SALT',       getenv_docker('WORDPRESS_NONCE_SALT',       'put your unique phrase here') );

$table_prefix = getenv_docker('WORDPRESS_TABLE_PREFIX', 'wp_');

define( 'WP_DEBUG', !!getenv_docker('WORDPRESS_DEBUG', '') );

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
	$_SERVER['HTTPS'] = 'on';
}

if ($configExtra = getenv_docker('WORDPRESS_CONFIG_EXTRA', '')) {
	eval($configExtra);
}

if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') {
	define('URL_SCHEME','https://');
} else {
	define('URL_SCHEME','http://');
}

# https://developer.wordpress.org/apis/wp-config-php/#wp-siteurl
# main WP url, with folder, without ending / (override db value)
define( 'WP_SITEURL', URL_SCHEME . $_SERVER['HTTP_HOST'] . '/wp');

# blog url (visitors), without leading /
define( 'WP_HOME', URL_SCHEME . $_SERVER['HTTP_HOST']);

// content path
define( 'WP_CONTENT_DIR', dirname(__FILE__) . '/wp-content') ;
define( 'WP_CONTENT_URL', URL_SCHEME . $_SERVER['HTTP_HOST'] . '/wp-content' );

// disable auto update (read only filesystem, updated via docker image build)
define( 'AUTOMATIC_UPDATER_DISABLED', true );

// humanmade/S3-Uploads
define('S3_UPLOADS_BUCKET', getenv("S3_BUCKET") );
define('S3_UPLOADS_REGION', getenv("S3_REGION") );
define('S3_UPLOADS_ENDPOINT', getenv("S3_ENDPOINT") );
define('S3_UPLOADS_KEY', getenv("S3_ACCESS_KEY"));
define('S3_UPLOADS_SECRET', getenv("S3_SECRET"));
define('S3_UPLOADS_BUCKET_URL', getenv("S3_ENDPOINT")."/".getenv("S3_BUCKET") );
// give backend type to mu-plugin/s3-endpoint.php
define('S3_PROVISIONNER', getenv("S3_PROVISIONNER") );

require_once ABSPATH . 'wp-settings.php';

